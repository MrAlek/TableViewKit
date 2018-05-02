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

}
