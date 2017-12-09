//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

public extension UIView {
    
    /// Load a view from a Nib file.
    ///
    /// - parameter  named: The name of the Nib file.
    /// - parameter bundle: The bundle of the Nib file. Defaults to `nil`.
    public class func loadFromNib<T>(named nibName: String, bundle : Bundle? = nil) -> T? {
        return UINib(
            nibName: nibName,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil).first as? T
    }
    
}
