//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

/// A type erasing equality protocol. Works like the good ol' Objective-C `isEqual`.
/// Hashable types just need to add the protocol to their interface without writing any implementation.
/// Example: `extension String: AnyEquatable {}`
public protocol AnyEquatable {
    
    /// :nodoc:
    func isEqual(to thing: Any?) -> Bool
    
    /// :nodoc:
    var hashValue: Int { get }

}

extension Equatable {
    
    /// :nodoc:
    public func isEqual(to thing: Any?) -> Bool {
        if let thing = thing as? Self {
            return self == thing
        }
        return false
    }
    
}

/// :nodoc:
public func ==(lhs: AnyEquatable?, rhs: AnyEquatable?) -> Bool {
    if let lhs = lhs {
        return lhs.isEqual(to: rhs)
    } else if let _ = rhs {
        return false
    } else {
        return true
    }
}

extension String: AnyEquatable {}
extension Bool: AnyEquatable {}
extension Float: AnyEquatable {}
extension Double: AnyEquatable {}
extension CGFloat: AnyEquatable {}
extension Data: AnyEquatable {}
