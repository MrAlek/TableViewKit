//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

public extension Array where Element: IdentifiableSection, Element.Identifier == String {
    
    /// Computes the incremental changes needed to apply to this array of sections in order to
    /// end up with the provided new array.
    ///
    /// Both arrays must contain elements implementing the `IdentifiableSection` protocol and be of the same type.
    /// No duplicated identifiers in any of the array sections or items are allowed.
    ///
    /// - Parameter newSections: The array to end up with by applying the resulting changes with.
    /// - Returns: The incremental changes going from this array to the `newArray` divided into section changes and item changes.
    func changes(toSections newSections: Array<Element>) -> ([ArrayChange<Element>], [SectionedArrayChange<Element.Item>]) {
        let sectionChanges = changes(to: newSections)
        
        let flatOldItems = flattenedItems
        let flatNewItems = newSections.flattenedItems
        
        let flatItemChanges = flatOldItems.changes(to: flatNewItems)

        var deletedItems: Set<Element.Item> = []
        var insertedItems: Set<Element.Item> = []
        
        var itemChanges: [SectionedArrayChange<Element.Item>] = flatItemChanges.flatMap { flatChange in
            
            let changeType: SectionedChangeType
            switch flatChange.type {
                case .insert(let newIndex):
                    changeType = .insert(newSections.indexPath(ofItemAtFlattenedIndex: newIndex))
                    insertedItems.insert(flatChange.item)
                case .delete(let oldIndex):
                    changeType = .delete(self.indexPath(ofItemAtFlattenedIndex: oldIndex))
                    deletedItems.insert(flatChange.item)
                case .move(_, _): // Take care of moves separately below
                    return nil
                case .update(let oldIndex, let newIndex):
                    changeType = .update(self.indexPath(ofItemAtFlattenedIndex: oldIndex), newSections.indexPath(ofItemAtFlattenedIndex: newIndex))
            }
            
            return SectionedArrayChange(item: flatChange.item, type: changeType)
        }
        
        // Let's figure out if any moves are necessary
        // For each section, do a manual insertion sort in order to step by step to find of all moves that needs to be made
        var workingCopySections = self
        workingCopySections.applyChanges(sectionChanges)
        
        for sectionIndex in 0..<newSections.count {
            // Filter out any deleted & inserted items already taken care of
            let beforeSectionItems = workingCopySections[sectionIndex].items.filter { !deletedItems.contains($0) && !insertedItems.contains($0) }
            let afterSectionItems = newSections[sectionIndex].items.filter { !insertedItems.contains($0) && !deletedItems.contains($0) }
            
            // Find all necessary moves needed to fix this particular section
            let changesForMovedObjects = beforeSectionItems.changes(to: afterSectionItems)
            
            itemChanges += changesForMovedObjects.flatMap { change in
                
                let identifier = change.item.identifier
                
                let item: Element.Item
                let convertedChangeType: SectionedChangeType
                
                switch change.type {
                    case .insert(_): // Item was moved INTO this section
                        guard let beforeIndexPath = self.indexPath(for: identifier), let afterIndexPath = newSections.indexPath(for: identifier) else {
                            fatalError("Something went horribly wrong while converting insert change into a move")
                        }
                        convertedChangeType = .move(beforeIndexPath, afterIndexPath)
                        item = newSections[afterIndexPath]
                        if let indexPath = workingCopySections.indexPath(for: identifier) {
                            workingCopySections[indexPath.section].items.remove(at: indexPath.item) // Update working copy so we don't try to move this item again in a later section
                        }
                    case .delete(_): // Item was moved FROM this section
                        guard let beforeIndexPath = self.indexPath(for: identifier), let afterIndexPath = newSections.indexPath(for: identifier) else {
                            fatalError("Something went horribly wrong while converting delete change into a move")
                        }
                        convertedChangeType = .move(beforeIndexPath, afterIndexPath)
                        item = newSections[afterIndexPath]
                        if !workingCopySections[afterIndexPath.section].items.map({$0.identifier}).contains(identifier) {
                            workingCopySections[afterIndexPath.section].items.insert(change.item, at:afterIndexPath.item) // Update working copy so we don't try to move this item again in a later section
                        }
                    case .move(_, _): // Item was moved WITHIN this section
                        guard let beforeIndexPath = self.indexPath(for: identifier), let afterIndexPath = newSections.indexPath(for: identifier) else {
                            fatalError("Something went horribly wrong while adding section information to a move change")
                        }
                        convertedChangeType = .move(beforeIndexPath, afterIndexPath)
                        item = newSections[afterIndexPath]
                    case .update(_, _):
                        return nil // Updates have already been taken care of
                }
                
                return SectionedArrayChange(item: item, type: convertedChangeType)
            }
        }
        
        return (sectionChanges, itemChanges)
    }
    
    /// Accesses an item at the provided index path.
    ///
    /// - Parameter indexPath: The index path to access. This must be valid for the array of sections.
    /// - Returns: The item at the provided index path.
    public subscript(indexPath: IndexPath) -> Element.Item {
        return self[indexPath.section].items[indexPath.item]
    }
    
    fileprivate var flattenedItems: [Element.Item] {
        return reduce([], { (flatItems, section) in
            return flatItems + section.items
        })
    }
    
    fileprivate func indexPath(for item: Element.Item) -> IndexPath? {
        for (sectionIndex, section) in enumerated() {
            if let itemIndex = section.items.index(of: item) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    fileprivate func indexPath(for identifier: Element.Item.Identifier) -> IndexPath? {
        for (sectionIndex, section) in enumerated() {
            if let itemIndex = section.items.map({ $0.identifier }).index(of: identifier) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    fileprivate func indexPath(ofItemAtFlattenedIndex index: Int) -> IndexPath {
        var sectionStart = 0 // Marks the starting index of items from the current section in the flattened items array
        
        for (sectionIndex, section) in enumerated() {
            if sectionStart + section.items.count-1 >= index {
                return IndexPath(item: index - sectionStart, section: sectionIndex)
            } else {
                sectionStart += section.items.count
            }
        }
        
        fatalError("Index (\(index)) was higher than what's possible in the flattened array (\(self))!")
    }

}
