//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

/// A model for a table view cell used inside a section.
///
/// - SeeAlso: `TableViewSection`
public struct TableViewCellModel: Identifiable {

    public typealias CellConfigurator = (UITableView, UITableViewCell) -> Void
    public typealias Handler = (UITableView, IndexPath) -> Void
    public typealias CellHandler = (UITableView, UITableViewCell, IndexPath) -> Void

    public enum CellEditActions {
        case none
        case swipeToDelete(handler: Handler?)
        case editActions(actions: [UITableViewRowAction])
    }
    
    internal static let StandardHeight: CGFloat = 44.0
    
    /// A string that uniquely identifies this cell within the table view.
    public var identifier: String
    
    /// The identifier for the table view cell to reuse for this model.
    public var cellReuseIdentifier: String
    
    /// The data for this cell.
    public var data: AnyEquatable?
    
    /// A function that registers this cell for reuse.
    public var cellReuseRegistrator: ((UITableView) -> Void)?

    /// A function that configures the table view cell with data when it is dequeued.
    public var cellConfigurator: CellConfigurator?
    
    /// Determines if the cell is selectable (and highlightable) or not. Defaults to `true`.
    public var isSelectable: Bool
    
    /// Determines if the cell is selectable (and highlightable) or not during multiselection.
    /// If set to false, won't indent during multiselection either. Defaults to `true`.
    public var isMultiSelectable: Bool
    
    /// A function which is called whenever the cell is selected.
    public var selectionHandler: Handler?
    
    /// A function which is called whenever the cell is deselected.
    public var deselectionHandler: Handler?
    
    /// A function called when the cell is about to be displayed.
    public var willDisplayHandler: CellHandler?
    
    /// A function called after this cell has ended displaying.
    /// This handler might not always get called when switching data sources.
    /// Do not put critical cleanup code here.
    public var didEndDisplayHandler: CellHandler?
    
    /// The edit actions for this cell.
    public var editActions: CellEditActions

    /// The optional copy menu action for this cell.
    public var copyAction: CellHandler?

    /// The optional paste menu action for this cell.
    public var pasteAction: CellHandler?
    
    /// The preferred row animation this cell should use when animating in & out of the table view.
    public var preferredAnimation: UITableViewRowAnimation
    
    /// Takes a width, returns a height
    fileprivate let estimatedHeightClosure: (CGFloat) -> CGFloat
    
    /// Returns an estimated height for the cell given the width of the table view.
    public func estimatedHeight(forWidth width: CGFloat) -> CGFloat {
        return estimatedHeightClosure(width)
    }
    
    /// :nodoc:
    public var hashValue: Int {
        return identifier.hashValue
    }
    
    /// A plain initializer to be used with a standard `UITableViewCell`.
    ///
    /// - Parameters:
    ///   - identifier: A string that uniquely identifies this cell model within the table view.
    ///   - cellReuseIdentifier: The identifier for the table view cell to reuse for this model.
    ///   - cellReuseRegistrator: A function that registers this cell for reuse.
    ///   - data: The data for this cell.
    ///   - estimatedHeight: The estimated height for this cell.
    ///   - cellConfigurator: A function that configures the table view cell with data when it is dequeued.
    ///   - isSelectable: Determines if the cell is selectable (and highlightable) or not. Defaults to `true`.
    ///   - isMultiSelectable: Determines if the cell is selectable (and highlightable) or not during multiselection. Defaults to `true`.
    ///   - selectionHandler: A function which is called whenever the cell is selected.
    ///   - deselectionHandler: A function which is called whenever the cell is deselected.
    ///   - willDisplayHandler: A function called when the cell is about to be displayed.
    ///   - didEndDisplayHandler: A function called after this cell has ended displaying.
    ///   - editActions: The optional edit actions for this cell.
    ///   - copyAction: The optional copy menu action for this cell.
    ///   - pasteAction: The optional paste menu action for this cell.
    ///   - preferredAnimation: The preferred row animation this cell should use when animating in & out of the table view.
    public init(
        identifier: String,
        cellReuseIdentifier: String,
        cellReuseRegistrator: ((UITableView) -> Void)? = nil,
        data: AnyEquatable? = nil,
        estimatedHeight: CGFloat? = nil,
        cellConfigurator: CellConfigurator? = nil,
        isSelectable: Bool = true,
        isMultiSelectable: Bool = true,
        selectionHandler: Handler? = nil,
        deselectionHandler: Handler? = nil,
        willDisplayHandler: CellHandler? = nil,
        didEndDisplayHandler: CellHandler? = nil,
        editActions: CellEditActions = .none,
        copyAction: CellHandler? = nil,
        pasteAction: CellHandler? = nil,
        preferredAnimation: UITableViewRowAnimation = .automatic) {
        
        self.identifier = identifier
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellReuseRegistrator = cellReuseRegistrator
        self.data = data
        self.estimatedHeightClosure = { _ in return estimatedHeight ?? TableViewCellModel.StandardHeight }
        self.cellConfigurator = cellConfigurator
        self.isSelectable = isSelectable
        self.isMultiSelectable = isMultiSelectable
        self.selectionHandler = selectionHandler
        self.deselectionHandler = deselectionHandler
        self.willDisplayHandler = willDisplayHandler
        self.didEndDisplayHandler = didEndDisplayHandler
        self.editActions = editActions
        self.copyAction = copyAction
        self.pasteAction = pasteAction
        self.preferredAnimation = preferredAnimation
    }
    
    /// A type-safe initializer to be used with `UITableViewCell` classes of `ReusableViewType`.
    ///
    /// - Parameters:
    ///   - cellType: The type of cell this cell model represents.
    ///   - identifier: A string that uniquely identifies this cell model within the table view.
    ///   - model: The model for this cell.
    ///   - cellConfigurator: A function to make extra configuration to the cell when it is dequeued (other than setting its data).
    ///   - isSelectable: Determines if the cell is selectable (and highlightable) or not. Defaults to `true`.
    ///   - isMultiSelectable: Determines if the cell is selectable (and highlightable) or not during multiselection. Defaults to `true`.
    ///   - separatorStyle: Sets a separator style on the cell, defaults to `.default`.
    ///   - selectionHandler: A function which is called whenever the cell is selected.
    ///   - deselectionHandler: A function which is called whenever the cell is deselected.
    ///   - willDisplayHandler: A function called when the cell is about to be displayed.
    ///   - didEndDisplayHandler: A function called after this cell has ended displaying.
    ///   - editActions: The edit actions for this cell.
    ///   - copyAction: The optional copy menu action for this cell.
    ///   - pasteAction: The optional paste menu action for this cell.
    ///   - preferredAnimation: The preferred row animation this cell should use when animating in & out of the table view.
    public init<Cell: UITableViewCell>(
        cellType: Cell.Type,
        identifier: String,
        model: Cell.Model,
        cellConfigurator: ((UITableView, Cell) -> Void)? = nil,
        isSelectable: Bool = true,
        isMultiSelectable: Bool = true,
        separatorStyle: SeparatorStyle = .default,
        selectionHandler: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        deselectionHandler: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        willDisplayHandler: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        didEndDisplayHandler: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        editActions: CellEditActions = .none,
        copyAction: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        pasteAction: ((UITableView, IndexPath, Cell) -> Void)? = nil,
        preferredAnimation: UITableViewRowAnimation = .automatic) where Cell: ReusableViewType {
        
        func handlerForTypedHandler(_ typedHandler: @escaping (UITableView, IndexPath, Cell) -> Void) -> Handler {
            return { tableView, indexPath in
                guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { fatalError("Wrong cell type in handler") }
                typedHandler(tableView, indexPath, cell)
            }
        }
        
        func cellHandlerForTypedHandler(_ typedHandler: @escaping (UITableView, IndexPath, Cell) -> Void) -> CellHandler {
            return { tableView, cell, indexPath in
                guard let cell = cell as? Cell else { return } // Silently fails because of didEndDisplay being VERY unreliable
                typedHandler(tableView, indexPath, cell)
            }
        }
        
        self.identifier = identifier
        self.data = model
        self.editActions = editActions
        self.preferredAnimation = preferredAnimation
        self.isSelectable = isSelectable
        self.isMultiSelectable = isMultiSelectable
        
        cellReuseIdentifier = Cell.staticReuseIdentifier
        self.cellReuseRegistrator = { Cell.register(viewKind: .cell, inTableView: $0) }
        
        self.cellConfigurator = { tableView, cell in
            guard let cell = cell as? Cell else { fatalError("Wrong cell type for model") }
            cell.setSeparatorStyle(separatorStyle)
            cellConfigurator?(tableView, cell)
            cell.setup(model)
        }
        
        self.estimatedHeightClosure = { width in
            if let estimatedHeight = cellType.estimatedHeight(forWidth: width, model: model) {
                return estimatedHeight
            } else if let cellType = cellType as? StaticHeightType.Type {
                return cellType.height
            } else {
                return TableViewCellModel.StandardHeight
            }
        }
        
        self.selectionHandler = selectionHandler.flatMap(handlerForTypedHandler)
        self.deselectionHandler = deselectionHandler.flatMap(handlerForTypedHandler)
        self.willDisplayHandler = willDisplayHandler.flatMap(cellHandlerForTypedHandler)
        self.didEndDisplayHandler = didEndDisplayHandler.flatMap(cellHandlerForTypedHandler)
        self.copyAction = copyAction.flatMap(cellHandlerForTypedHandler)
        self.pasteAction = pasteAction.flatMap(cellHandlerForTypedHandler)
    }
}

/// :nodoc:
public func ==(lhs: TableViewCellModel, rhs: TableViewCellModel) -> Bool {
    return lhs.identifier == rhs.identifier &&
           lhs.cellReuseIdentifier == rhs.cellReuseIdentifier &&
           lhs.isSelectable == rhs.isSelectable &&
           lhs.isMultiSelectable == rhs.isMultiSelectable &&
           lhs.editActions == rhs.editActions &&
           lhs.data == rhs.data &&
           lhs.preferredAnimation == rhs.preferredAnimation
}
