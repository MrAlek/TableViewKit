//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

/// A model representing a section in a `UITableView`.
///
/// - SeeAlso: `TableViewCellModel`
public struct TableViewSection: IdentifiableSection {
    
    /// A string that uniquely identifies this section within the table view.
    public var identifier: String
    
    /// The header view model for this section.
    public var header: TableViewHeaderFooterViewModel?
    
    /// The footer view model for this section.
    public var footer: TableViewHeaderFooterViewModel?
    
    /// The cell models for this section.
    public var items: [TableViewCellModel]
    
    /// The designated initializer.
    ///
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies this section within the table view.
    ///   - header: The header view model for this section.
    ///   - footer: The footer view model for this section.
    ///   - cells: The cell models for this section.
    public init(identifier: String, header: TableViewHeaderFooterViewModel? = nil, footer: TableViewHeaderFooterViewModel? = nil, cells: [TableViewCellModel]) {
        self.identifier = identifier
        self.header = header
        self.footer = footer
        self.items = cells
    }
    
    /// A convenience initializer to use with `DualTitledSectionHeaderView`s as headers and footers.
    ///
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies this section within the table view.
    ///   - headerTitle: The optional header title for this section. Generates a model for a `StandardHeaderFooterView` when not `nil`.
    ///   - footerTitle: The optional footer title for this section. Generates a model for a `StandardHeaderFooterView` when not `nil`.
    ///   - footerDetailTitle: The optional footer detail title for this section. Requires `footerTitle` not to be `nil`. Defaults to `nil`.
    ///   - cells: The cell models for this section.
    ///
    /// - SeeAlso: `StandardHeaderFooterView`
    public init(identifier: String, headerTitle: String?, footerTitle: String? = nil, footerDetailTitle: String? = nil, cells: [TableViewCellModel]) {
        self.identifier = identifier
        self.items = cells
        self.header = headerTitle.flatMap(TableViewHeaderFooterViewModel.init)
        self.footer = footerTitle.flatMap(TableViewHeaderFooterViewModel.init)
    }
}

extension TableViewSection: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        return identifier.hashValue
    }
}

/// :nodoc:
public func ==(lhs: TableViewSection, rhs: TableViewSection) -> Bool {
    return lhs.identifier == rhs.identifier &&
           lhs.header == rhs.header &&
           lhs.footer == rhs.footer
}
