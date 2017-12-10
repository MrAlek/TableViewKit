//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

public extension Array where Element: Identifiable {

    /// Computes the incremental changes needed to apply to this array in order to
    /// end up with the provided new array.
    /// 
    /// Both arrays must contain elements implementing the `Identifiable` protocol and be of the same type.
    /// No duplicated identifiers in any of the array items are allowed.
    ///
    /// - Parameter newArray: The array to end up with by applying the resulting changes with.
    /// - Returns: The incremental changes going from this array to the `newArray`.
    func changes(to newArray: Array<Element>) -> [ArrayChange<Element>] {
        var changes: [ArrayChange<Element>] = []
        
        // Setup data structures
        
        var firstIdentifiers: [Element.Identifier] = []
        var firstIndexes: [Element.Identifier: Index] = [:]
        for (index, value) in self.enumerated() {
            firstIdentifiers.append(value.identifier)
            firstIndexes[value.identifier] = index
        }
        
        var secondIdentifiers: [Element.Identifier] = []
        var secondIndexes: [Element.Identifier: Index] = [:]
        for (index, value) in newArray.enumerated() {
            secondIdentifiers.append(value.identifier)
            secondIndexes[value.identifier] = index
        }
        
        // Find inserted and removed elements
        
        let set1 = Set(firstIdentifiers)
        let set2 = Set(secondIdentifiers)
        let removed = set1.subtracting(set2)
        
        for identifier in removed {
            let index = firstIndexes[identifier]!
            changes.append(ArrayChange(item: self[index], type: .delete(index)))
        }
        
        let inserted = set2.subtracting(set1)
        
        for identifier in inserted {
            let index = secondIndexes[identifier]!
            changes.append(ArrayChange(item: newArray[index], type: .insert(index)))
        }
        
        // Compare order of intersected identifiers, note that these two intersects will be containing the same identifiers, just maybe in different order
        let firstIntersectIdentifiers = firstIdentifiers.filter { !removed.contains($0) }
        let secondIntersectIdentifiers = secondIdentifiers.filter { !inserted.contains($0) }
        
        // Let's figure out if any moves are necessary
        // Do a manual insertion sort in order to step by step to find of all moves that needs to be made
        var movedIdentifiers = firstIntersectIdentifiers
        for i in 0..<firstIntersectIdentifiers.count {
            
            if movedIdentifiers[i] == secondIntersectIdentifiers[i] {
                // No need to do anything, go to next identifier
                continue
            }
            
            // Get the identifier which SHOULD be on this index
            let identifier = secondIntersectIdentifiers[i]
            
            guard let realFirstIndex = firstIndexes[identifier],
                let realSecondIndex = secondIndexes[identifier] else {
                    fatalError("Intersect identifiers couldn't be found in both old and new arrays") // Shit hit the fan
            }
            
            // Generate change object & append to end result
            changes.append(ArrayChange(item: newArray[realSecondIndex], type: .move(realFirstIndex, realSecondIndex)))
            
            // Make move in iterating array
            movedIdentifiers.remove(at: movedIdentifiers.index(of: identifier)!)
            movedIdentifiers.insert(identifier, at: i)
        }
        
        // Finally let's see if any items have been updated and generate update changes for those
        for identifier in firstIntersectIdentifiers {
            guard let realFirstIndex = firstIndexes[identifier],
                let realSecondIndex = secondIndexes[identifier] else {
                    fatalError("Intersect identifiers couldn't be found in both old and new arrays") // Shouldn't ever happen
            }
            
            if self[realFirstIndex] != newArray[realSecondIndex] {
                changes.append(ArrayChange(item: newArray[realSecondIndex], type: .update(realFirstIndex, realSecondIndex)))
            }
        }
        
        return changes
    }
    
    /// Applies a change to the array by mutating it.
    ///
    /// - Parameter change: The change to apply.
    mutating func applyChange(_ change: ArrayChange<Element>) {
        switch change.type {
            case .insert(let index):
                insert(change.item, at: index)
            case .delete(let index):
                remove(at: index)
            case .move(let oldIndex, let newIndex):
                let movedItem = remove(at: oldIndex)
                insert(movedItem, at: newIndex)
            case .update(_, let afterIndex):
                self[afterIndex] = change.item
        }
    }
    
    /// Applies changes to the array by mutating it.
    ///
    /// - Parameter changes: The changes to apply.
    mutating func applyChanges(_ changes: [ArrayChange<Element>]) {
    
        var workingCopy = self.map { $0 as Element? }
        
        // Treat moves as delete + insert
        
        // First pass: deletions
        for change in changes {
            switch change.type {
                case .delete(let index):
                    workingCopy[index] = nil
                case .move(let oldIndex, _):
                    workingCopy[oldIndex] = nil
                default:
                    break
            }
        }
        
        var newArray = workingCopy.flatMap {$0}
        
        // Second pass: inserts. Sort them in indexed order to avoid trying to insert into an index out of bounds
        let inserts: [(Int, Element)] = changes.flatMap { change in
            switch change.type {
                case .insert(let index):
                    return (index, change.item)
                case .move(_, let newIndex):
                    return (newIndex, change.item)
                default:
                    return nil
            }
        }
        let sortedInsertsByIndex = inserts.sorted { $0.0 < $1.0 }
        sortedInsertsByIndex.forEach { insertChange in
            newArray.insert(insertChange.1, at: insertChange.0)
        }
        
        // Third pass: updates
        for change in changes {
            switch change.type {
                case .update(_, let newIndex):
                    newArray[newIndex] = change.item
                default:
                    break
            }
        }
        
        self = newArray
    }

}
