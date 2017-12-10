//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

/// Represents the type of change a `SectionedArrayChange` can have.
///
/// - SeeAlso: `SectionedArrayChange`
public enum SectionedChangeType: Hashable {
    
    /// An insertion.
    case insert(IndexPath)
    
    /// A deletion.
    case delete(IndexPath)
    
    /// A move from an index path to another.
    case move(IndexPath, IndexPath)
    
    /// An update of an object with index paths before and after.
    case update(IndexPath, IndexPath)
    
    /// :nodoc:
    public var hashValue: Int {
        switch self {
            case .insert(let newIndexPath):
                return 1 ^ newIndexPath.hashValue
            case .delete(let oldIndexPath):
                return 2 ^ oldIndexPath.hashValue
            case .move(let oldIndexPath, let newIndexPath):
                return 3 ^ oldIndexPath.hashValue ^ newIndexPath.hashValue
            case .update(let oldIndexPath, let newIndexPath):
                return 4 ^ oldIndexPath.hashValue ^ newIndexPath.hashValue
        }
    }

}

/// :nodoc:
public func ==(lhs: SectionedChangeType, rhs: SectionedChangeType) -> Bool {
    switch (lhs, rhs) {
        case let (.insert(l1), .insert(r1)):
            return l1 == r1
        case let (.delete(l1), .delete(r1)):
            return l1 == r1
        case let (.move(l1, l2), .move(r1, r2)):
            return l1 == r1 && l2 == r2
        case let (.update(l1, l2), .update(r1, r2)):
            return l1 == r1 && l2 == r2
        default:
            return false
    }
}

extension SectionedChangeType: CustomDebugStringConvertible {
    
    /// :nodoc:
    public var debugDescription: String {
        switch self {
            case .insert(let indexPath):
                return "Insert(\(indexPath))"
            case .delete(let indexPath):
                return "Delete(\(indexPath))"
            case .move(let oldIndexPath, let newIndexPath):
                return "Move(\(oldIndexPath), \(newIndexPath))"
            case .update(let oldIndexPath, let newIndexPath):
                return "Update(\(oldIndexPath), \(newIndexPath))"
        }
    }

}

/// Represents an item change in an array of sections.
///
/// - SeeAlso: `IdentifiableSection`
public struct SectionedArrayChange<Item: Identifiable>: Hashable {
    
    /// The item affected by the change
    public var item: Item
    
    /// The type of the change
    public var type: SectionedChangeType
    
    /// The designated initializer.
    ///
    /// - Parameters:
    ///   - item: The item in the array affected by the change.
    ///   - type: Tge type of the change.
    public init(item: Item, type: SectionedChangeType) {
        self.item = item
        self.type = type
    }
    
    /// :nodoc:
    public var hashValue: Int {
        return item.hashValue ^ type.hashValue
    }

}

/// :nodoc:
public func ==<T>(lhs: SectionedArrayChange<T>, rhs: SectionedArrayChange<T>) -> Bool {
    return lhs.type == rhs.type && lhs.item == rhs.item
}
