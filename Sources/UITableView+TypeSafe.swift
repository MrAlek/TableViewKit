//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

public extension UITableView {
    
    /// Register a cell type backed by nibs for reuse.
    ///
    /// - Parameter cellType: The type to be registered. Needs to conform to `ReusableViewNib`.
    ///
    /// - SeeAlso: `ReusableViewNib`
    func register<Cell: UITableViewCell>(_ cellType: Cell.Type) where Cell: ReusableViewNib {
        self.register(Cell.nib, forCellReuseIdentifier: Cell.staticReuseIdentifier)
    }
    
    /// Register a cell class for reuse.
    ///
    /// - Parameter cellType: The type to be registered. Needs to conform to `ReusableViewClass`.
    ///
    /// - SeeAlso: `ReusableViewClass`
    func register<Cell: UITableViewCell>(_ cellType: Cell.Type) where Cell: ReusableViewClass {
        self.register(cellType, forCellReuseIdentifier: Cell.staticReuseIdentifier)
    }
    
    /// Register a header footer view type backed by nibs for reuse.
    ///
    /// - Parameter viewType: The type to be registered. Needs to be a subclass of `UITableViewHeaderFooterView` and conform to `ReusableViewNib`.
    ///
    /// - SeeAlso: `ReusableViewNib`
    func register<View: UITableViewHeaderFooterView>(_ viewType: View.Type) where View: ReusableViewNib {
        self.register(View.nib, forHeaderFooterViewReuseIdentifier: View.staticReuseIdentifier)
    }
    
    /// Register a header footer view type for reuse.
    ///
    /// - Parameter viewType: The type to be registered. Needs to be a subclass of `UITableViewHeaderFooterView` and conform to `ReusableViewClass`.
    ///
    /// - SeeAlso: `ReusableViewClass`
    func register<View: UITableViewHeaderFooterView>(_ viewType: View.Type) where View: ReusableViewClass {
        self.register(View.self, forHeaderFooterViewReuseIdentifier: View.staticReuseIdentifier)
    }
    
}

extension UITableView {
    
    func headerFooterView(for viewModel: TableViewHeaderFooterViewModel) -> UIView? {
        let view = dequeueReusableHeaderFooterView(withIdentifier: viewModel.viewReuseIdentifier)!
        return viewModel.configurator?(view) ?? view
    }
    
}

