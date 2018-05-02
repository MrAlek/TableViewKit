//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

/// Represents the type of change an `ArrayChange` can have.
///
/// - SeeAlso: `ArrayChange`
public enum ArrayChangeType: Hashable {
    
    /// An insertion.
    case insert(Int)
    
    /// A deletion.
    case delete(Int)
    
    /// A move from an index to another.
    case move(Int, Int)
    
    /// An update of an object with indexes before and after.
    case update(Int, Int)

}

extension ArrayChangeType: CustomDebugStringConvertible {
    
    /// :nodoc:
    public var debugDescription: String {
        switch self {
            case .insert(let newIndex):
                return "Insert(\(newIndex))"
            case .delete(let oldIndex):
                return "Delete(\(oldIndex))"
            case .move(let oldIndex, let newIndex):
                return "Move(\(oldIndex), \(newIndex))"
            case .update(let oldIndex, let newIndex):
                return "Update(\(oldIndex), \(newIndex))"
        }
    }

}

/// Represents a change in an array of specific type.
public struct ArrayChange<Item: Identifiable>: Hashable {
    
    /// The item in the array affected by the change.
    public var item: Item
    
    /// The type of the change.
    public var type: ArrayChangeType
    
    /// The designated initializer.
    ///
    /// - Parameters:
    ///   - item: The item in the array affected by the change.
    ///   - type: Tge type of the change.
    public init(item: Item, type: ArrayChangeType) {
        self.item = item
        self.type = type
    }

}

extension ArrayChange: CustomDebugStringConvertible {
    
    /// :nodoc:
    public var debugDescription: String {
        return "Id: \(item.identifier), \(type.debugDescription)"
    }

}
