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
    
    /// The model type.
    associatedtype Model: AnyEquatable
    
    /// Sets up the view with the provided data.
    ///
    /// - Parameter model: The model for the view.
    func setup(_ model: Model)
    
    /// FIX-ME: This should be `estimatedSize` instead once collection view support is in for the generic data sources.
    static func estimatedHeight(forWidth width: CGFloat, model: Model) -> CGFloat?
    
}

public extension DataSetupable {
    
    /// :nodoc:
    static func estimatedHeight(forWidth width: CGFloat, model: Model) -> CGFloat? {
        // Default implementation for optionality
        return nil
    }
    
}

public enum ReusableViewKind {
    case cell, headerFooterView
}

/// A protocol for reusable views
public protocol Reusable {
    
    static var staticReuseIdentifier: String { get }
    
    static func register(viewKind: ReusableViewKind, inTableView tableView: UITableView)

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

extension ReusableViewClass {
    
    public static func register(viewKind: ReusableViewKind, inTableView tableView: UITableView) {
        switch viewKind {
            case .cell:
                tableView.register(Self.self, forCellReuseIdentifier: staticReuseIdentifier)
            case .headerFooterView:
                tableView.register(Self.self, forHeaderFooterViewReuseIdentifier: staticReuseIdentifier)
        }
    }
    
}


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
    public static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
    
    public static func register(viewKind: ReusableViewKind, inTableView tableView: UITableView) {
        switch viewKind {
            case .cell:
                tableView.register(nib, forCellReuseIdentifier: staticReuseIdentifier)
            case .headerFooterView:
                tableView.register(nib, forHeaderFooterViewReuseIdentifier: staticReuseIdentifier)
        }
    }

}
