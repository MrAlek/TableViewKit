//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

/// A typealias for a commonly desired combination of view protocols when dealing with reusability.
public typealias ReusableViewType = DataSetupable & Reusable

/// A protocol for views with a static height for use in height estimation.
/// Note that the view still must construct its own constraints to keep its height.
public protocol StaticHeightType {
    
    /// The static height of this view.
    static var height: CGFloat { get }

}

/// A protocol for views that can be setup and sized with some kind of data model.
public protocol DataSetupable {
    
    /// The data type.
    associatedtype Data: AnyEquatable
    
    /// Sets up the view with the provided data.
    ///
    /// - Parameter data: The data for the view.
    func setup(_ data: Data)
    
    /// FIX-ME: This should be `estimatedSize` instead once collection view support is in for the generic data sources.
    static func estimatedHeight(forWidth width: CGFloat, data: Data) -> CGFloat?
    
}

public extension DataSetupable {
    
    /// :nodoc:
    static func estimatedHeight(forWidth width: CGFloat, data: Data) -> CGFloat? {
        // Default implementation for optionality
        return nil
    }
    
}

/// A protocol for reusable views
public protocol Reusable {
    
    static var staticReuseIdentifier: String { get }
    
}

/// Implements the `Reusable` protocol by setting the `staticReuseIdentifier` to the type name of the implementer of this protocol
public protocol StaticTypeNameReusable: Reusable { }

extension StaticTypeNameReusable {
    
    /// :nodoc:
    public static var staticReuseIdentifier: String {
        return String(describing: self)
    }
    
}

/// Used for `registerClass` in table & collection views
public protocol ReusableViewClass: class, StaticTypeNameReusable { }


/// Used for `registerNib` in table & collection views.
///
/// Assumes there is a nib in the same bundle as the implementor, named the same name as the implementor type.
///
public protocol ReusableViewNib: class, StaticTypeNameReusable {
    
    static var nibName: String { get }
    
}

extension ReusableViewNib {
    
    /// :nodoc:
    public static var nibName: String {
        return staticReuseIdentifier
    }
    
    /// :nodoc:
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }

}
