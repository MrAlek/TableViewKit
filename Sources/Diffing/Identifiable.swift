//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

/// Signifies a `Hashable`, `Equatable` object with a designated identifier.
public protocol Identifiable: Hashable {
    
    /// The identifier type.
    associatedtype Identifier: Hashable
    
    /// The identifier. This should uniquely indentify this object.
    var identifier: Identifier { get }

}

/// An identifiable section.
public protocol IdentifiableSection: Identifiable {
    
    /// The item type.
    associatedtype Item: Identifiable
    
    /// The items contained within the section.
    var items: [Item] { get set }

}
