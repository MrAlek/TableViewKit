//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

///
/// A generic, heterogenous table view data source and delegate.
///
/// After initialization, run the `setup` function with a table view to configure it to use this as its data source and delegate.
public class TableViewDataSource: NSObject {

    /// The current table view sections
    public fileprivate(set) var sections: [TableViewSection]
    fileprivate weak var tableView: UITableView?
    fileprivate let processingQueue = OperationQueue()

    /// The designated initializer
    ///
    /// - Parameter sections: The initial table view sections.
    public init(sections: [TableViewSection] = []) {
        self.sections = sections
        processingQueue.maxConcurrentOperationCount = 1
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(recievedCellNeedsSizeUpdateNotification), name: TVKCellNeedsSizeUpdateNotificationName, object: nil)
    }
    
    /// Sets new sections on the data source and reloads the table view if this is its data source.
    ///
    /// - Parameter newSections: The new sections to set.
    public func reloadData(newSections: [TableViewSection]) {
        sections = newSections
        if isCurrentDataSource {
            tableView?.reloadData()
        }
    }

    /// Updates the table view with new sections synchronously, preserving scroll & selection state.
    /// !!! Uses CPU-intensive calculations on the main queue.
    ///
    /// - Parameter newSections: The new sections to set.
    public func updateSectionsSync(to newSections: [TableViewSection]) {
        let changes = sections.changes(toSections: newSections)
        sections = newSections
        
        guard let tableView = tableView, isCurrentDataSource else { return }
        
        ignoreDidEndDisplayingCells = true
        tableView.applyChanges(changes, rowAnimation: .none, updateHandler: { (cell, cellModel, _, _) in
            cellModel.cellConfigurator?(tableView, cell)
        })
        ignoreDidEndDisplayingCells = false
        
        return
    }
    
    /// Sets new sections on the table view, optionally animating the changes.
    ///
    /// - Parameters:
    ///     - newSections: The new sections to set.
    ///     - animation: When set to anything other than `.none`, computes and animates the changes from the current sections. Defaults to `.automatic`
    ///     - completion: Run when the new sections have been applied.
    public func updateSections(to newSections: [TableViewSection], animation: UITableViewRowAnimation = .automatic , completion: @escaping (() -> Void) = {} ) {

        guard animation != .none else {
            reloadData(newSections: newSections)
            completion()
            return
        }

        // Animated track, let's calculate some changes!
        let processingOperation = BlockOperation()
        processingOperation.addExecutionBlock { [unowned processingOperation, weak self] in
            guard let strongSelf = self else { return } // Not interesting if we have already been deallocated

            // Only compute changes if necessary for animation
            let changes = strongSelf.sections.changes(toSections: newSections)

            guard !processingOperation.isCancelled else { return }
            
            DispatchQueue.main.sync { // Dispatch sync to make sure our changes are applied before any more are incoming
                strongSelf.sections = newSections

                // Make sure we're actually the table view's data source before trying to update it
                guard strongSelf.isCurrentDataSource else { return }
                guard let tableView = strongSelf.tableView else { return }

                strongSelf.ignoreDidEndDisplayingCells = true
                tableView.applyChanges(changes, rowAnimation: animation, updateHandler: { (cell, cellModel, _, _) in
                    cellModel.cellConfigurator?(tableView, cell)
                })
                strongSelf.ignoreDidEndDisplayingCells = false
            }

        }

        processingOperation.completionBlock = completion
        processingQueue.cancelAllOperations() // If user spams UI, and toggles state back and forth, make sure to cancel old state changes and just process the most recent complete state
        processingQueue.addOperation(processingOperation)
    }

    /// Setups the provided table view for use with this datasource
    public func setup(with tableView: UITableView) {
        self.tableView = tableView

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        
        ignoreDidEndDisplayingCells = true
        UIView.performWithoutAnimation {
            if tableView.numberOfSections > 0 {
                tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        ignoreDidEndDisplayingCells = false
    }
    
    /// Finds the index path of the row with a certain identifier.
    ///
    /// - Parameter identifier: The identifier to find.
    /// - Returns: The index path of the row, or `nil` if none was found.
    public func indexPathForRow(identifiedBy identifier: String) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let row = section.items.index(where: { $0.identifier == identifier }) {
                return IndexPath(row: row, section: sectionIndex)
            }
        }
        
        return nil
    }

    fileprivate var isCurrentDataSource: Bool {
        if let dataSource = tableView?.dataSource as? TableViewDataSource, dataSource == self {
            return true
        }
        return false
    }
    
    fileprivate var ignoreDidEndDisplayingCells = false
    
    @objc func recievedCellNeedsSizeUpdateNotification(notification: Notification) {
        guard let cell = notification.object as? UITableViewCell else { return }
        guard let tableView = tableView, tableView.visibleCells.contains(cell) else { return }
        DispatchQueue.main.async { // Without the dispatch the animations looka weird.
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

}

extension TableViewDataSource: UITableViewDataSource {

    /// :nodoc:
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = sections[indexPath]
        cellModel.cellReuseRegistrator?(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellReuseIdentifier, for: indexPath)
        cellModel.cellConfigurator?(tableView, cell)
        return cell
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cellModel = sections[indexPath]
        if tableView.isMultiSelecting {
            return cellModel.isMultiSelectable
        } else {
            return cellModel.editActions?.count ?? 0 > 0
        }
    }

}

extension TableViewDataSource: UITableViewDelegate {

    /// :nodoc:
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        sections[indexPath.section].items[indexPath.row].willDisplayHandler?(tableView, cell, indexPath)
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !ignoreDidEndDisplayingCells else { return }
        // If we're in the middle of a data source switch or section update, we'll get callbacks that those old cells did end displaying and those won't correspond to the models we have currently.
        
        // Sometimes we still get callbacks for cells with index paths that no longer exists.
        guard let section = sections[safe: indexPath.section], let item = section.items[safe: indexPath.row] else { return }
        
        item.didEndDisplayHandler?(tableView, cell, indexPath)
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].items[indexPath.row].estimatedHeight(forWidth: tableView.bounds.width)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].footer.flatMap(tableView.headerFooterView)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].header.flatMap(tableView.headerFooterView)
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footer?.estimatedHeight(forWidth: tableView.bounds.width) ?? 0
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].header?.estimatedHeight(forWidth: tableView.bounds.width) ?? 0
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cellModel = sections[indexPath]
        return tableView.isMultiSelecting ? cellModel.isMultiSelectable : cellModel.isSelectable
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellModel = sections[indexPath]
        if tableView.isMultiSelecting {
            return cellModel.isMultiSelectable ? indexPath : nil
        } else {
            return cellModel.isSelectable ? indexPath : nil
        }
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath].selectionHandler?(tableView, indexPath)
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard !ignoreDidEndDisplayingCells else { return }
        // If we're in the middle of a data source switch or section update, we'll get callbacks that those old cells did end displaying and those won't correspond to the models we have currently.
        
        // Sometimes we still get callbacks for cells with index paths that no longer exists.
        guard let section = sections[safe: indexPath.section], let _ = section.items[safe: indexPath.row] else { return }
        
        sections[indexPath].deselectionHandler?(tableView, indexPath)
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return sections[indexPath.section].items[indexPath.row].editActions
    }

    /// :nodoc:
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return (sections[indexPath].copyAction != nil || sections[indexPath].pasteAction != nil)
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return sections[indexPath].copyAction != nil
        } else if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return sections[indexPath].pasteAction != nil
        } else {
            return false
        }
    }
    
    /// :nodoc:
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            sections[indexPath].copyAction?(tableView, cell, indexPath)
        } else if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            sections[indexPath].pasteAction?(tableView, cell, indexPath)
        }
    }
    
}

internal extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

private extension UITableView {
    
    var isMultiSelecting: Bool {
        return (isEditing && allowsMultipleSelectionDuringEditing) || (!isEditing && allowsMultipleSelection)
    }
    
    func headerFooterView(for viewModel: TableViewHeaderFooterViewModel) -> UIView? {
        viewModel.viewReuseRegistrator?(self)
        let view = dequeueReusableHeaderFooterView(withIdentifier: viewModel.viewReuseIdentifier)!
        return viewModel.configurator?(view) ?? view
    }
    
}

/// Used for custom table view cells to report whenever they need a size update
public let TVKCellNeedsSizeUpdateNotificationName = Notification.Name(rawValue: "TVKCellNeedsSizeUpdateNotification")
