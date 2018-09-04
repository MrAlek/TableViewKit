//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

public extension TableViewCellModel {
    
    /// A style for cell separators.
    enum SeparatorStyle {
        
        /// An edge-to-edge separator.
        case fullWidth
        
        /// The standard style with separator going from start of content.
        case `default`
        
        /// No separator.
        case none

    }
    
    /// Sets a separator style to a cell by wrapping the original `cellConfigurator`.
    ///
    /// - Parameter style: The style to set
    mutating func setSeparatorStyle(_ style: SeparatorStyle) {
        let oldConfigurator = cellConfigurator
        cellConfigurator = { tableView, cell in
            oldConfigurator?(tableView, cell)
            cell.setSeparatorStyle(style)
        }
    }
    
}

public extension UITableViewCell {
    
    /// Sets a separator style to a cell. Note that setting the `.default` style on an already visible cell which tweaks its separator insets might be flaky.
    ///
    /// - Parameter style: The style to set
    func setSeparatorStyle(_ style: TableViewCellModel.SeparatorStyle) {
        switch style {
            case .fullWidth:
                separatorInset = .zero
            case .none:
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width)
            case .default:
                separatorInset = UIEdgeInsets(top: 0, left: layoutMargins.left, bottom: 0, right: 0)
        }
    }
    
}
