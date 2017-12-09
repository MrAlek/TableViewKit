//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

/// For classes where there is a Nib with the same filename as the class.
public protocol NibLoadable { }

public extension NibLoadable where Self:UIView {
    
    public static func loadFromNib() -> Self {
        return loadFromNib(named: String(describing: self), bundle: Bundle(for: self))!
    }
    
}
