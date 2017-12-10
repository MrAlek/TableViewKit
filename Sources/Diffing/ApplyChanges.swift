//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import UIKit

public extension UITableView {
    
    /// Animates row & section changes on the table view.
    ///
    /// - Note: Make sure that the changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - changes: The changes to animate.
    ///   - rowAnimation: The row animation to use for animations. Defaults to `.Automatic`.
    ///   - updateHandler: An optional handler that gets called for every visible row that has an `Update` change. When omitted, `reloadRowsAtIndexPaths` is called instead. Defaults to `nil`.
    func applyChanges<Section: IdentifiableSection, Item>(_ changes: ([ArrayChange<Section>], [SectionedArrayChange<Item>]), rowAnimation: UITableViewRowAnimation = .automatic, updateHandler: ((UITableViewCell, Item, IndexPath, IndexPath) -> Void)? = nil) where Section.Item == Item {
        applyChanges(changes.0, itemChanges: changes.1, rowAnimation: rowAnimation, updateHandler: updateHandler)
    }
    
    
    /// Animates row & section changes on the table view.
    ///
    /// - Note: Make sure that the model changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - sectionChanges: The section changes to animate.
    ///   - itemChanges: The item changes to animate.
    ///   - rowAnimation: The row animation to use for animations. Defaults to `.Automatic`.
    ///   - updateHandler: An optional handler that gets called for every visible row that has an `Update` change. When omitted, `reloadRowsAtIndexPaths` is called instead. Defaults to `nil`.
    ///   - completion: An optional handler that runs after applying the changes. Is always called with a `true` boolean parameter. Defaults to `nil`.
    func applyChanges<Section: IdentifiableSection, Item>(_ sectionChanges: [ArrayChange<Section>], itemChanges: [SectionedArrayChange<Item>], rowAnimation: UITableViewRowAnimation = .automatic, updateHandler: ((UITableViewCell, Item, IndexPath, IndexPath) -> Void)? = nil, completion:  ((Bool) -> Void)? = nil) where Section.Item == Item {
        
        guard sectionChanges.count > 0 || itemChanges.count > 0 else { completion?(true); return }
        
        beginUpdates()
        
        var sectionsInserted: [Int] = []
        var sectionsDeleted: [Int] = []
        
        for change in sectionChanges {
            switch change.type {
                case .insert(let newIndex):
                    sectionsInserted.append(newIndex)
                    insertSections(IndexSet(integer: newIndex), with: .fade)
                case .delete(let oldIndex):
                    sectionsDeleted.append(oldIndex)
                    deleteSections(IndexSet(integer: oldIndex), with: .fade)
                case .move(let oldIndex, let newIndex):
                    sectionsDeleted.append(oldIndex)
                    sectionsInserted.append(newIndex)
                    // TODO: Implement workaround for another table view move bug. Check if any rows are deleted and/or inserted in the section to enable real move
                    insertSections(IndexSet(integer: newIndex), with: .fade)
                    deleteSections(IndexSet(integer: oldIndex), with: .fade)
                case .update(let oldIndex, _):
                    reloadSections(IndexSet(integer: oldIndex), with: .fade)
                }
        }
        
        for change in itemChanges {
            
            var rowAnimation = rowAnimation
            if let cellModel = change.item as? TableViewCellModel {
                rowAnimation = cellModel.preferredAnimation
            }
            
            switch change.type {
                case .insert(let newIndexPath):
                    insertRows(at: [newIndexPath], with: rowAnimation)
                case .delete(let oldIndexPath):
                    deleteRows(at: [oldIndexPath], with: rowAnimation)
                case .move(let oldIndexPath, let newIndexPath):
                    if !sectionsDeleted.contains(oldIndexPath.section) && !sectionsInserted.contains(newIndexPath.section) {
                        moveRow(at: oldIndexPath, to: newIndexPath)
                    } else {
                        // UITableView bug that has been around forever rdar://17684030
                        deleteRows(at: [oldIndexPath], with: rowAnimation)
                        insertRows(at: [newIndexPath], with: rowAnimation)
                    }
                case .update(let oldIndexPath, let newIndexPath):
                    if let visibleIndexPaths = indexPathsForVisibleRows, visibleIndexPaths.contains(oldIndexPath) {
                        if let updateHandler = updateHandler, let cell = cellForRow(at: oldIndexPath) {
                            updateHandler(cell, change.item, oldIndexPath, newIndexPath)
                        } else {
                            reloadRows(at: [oldIndexPath], with: rowAnimation)
                        }
                    }
            }
        }
        
        endUpdates()
        
        completion?(true)
    }
    
    /// Animates row changes in a specific section.
    ///
    /// - Note: Make sure that the changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - changes: The changes to animate.
    ///   - sectionIndex: The section in which the changes have been applied to the data source.
    ///   - rowAnimation: The row animation to use for animations. Defaults to `.Automatic`.
    ///   - updateHandler: An optional handler that gets called for every visible row that has an `Update` change. When omitted, `reloadRowsAtIndexPaths` is called instead. Defaults to `nil`.
    func applyChanges<Item>(_ changes: [ArrayChange<Item>], sectionIndex: Int, rowAnimation: UITableViewRowAnimation = .automatic, updateHandler: ((UITableViewCell, Item, Int, Int) -> Void)? = nil) {
        beginUpdates()
        for change in changes {
            switch change.type {
                case .insert(let index):
                    let indexPath = IndexPath(row: index, section: sectionIndex)
                    insertRows(at: [indexPath], with: rowAnimation)
                case .delete(let index):
                    deleteRows(at: [IndexPath(row: index, section: sectionIndex)], with: rowAnimation)
                case .move(let beforeIndex, let afterIndex):
                    moveRow(at: IndexPath(row: beforeIndex, section: sectionIndex), to: IndexPath(row: afterIndex, section: sectionIndex))
                case .update(let beforeIndex, let afterIndex):
                    let beforeIndexPath = IndexPath(row: beforeIndex, section: sectionIndex)
                    
                    if let rows = self.indexPathsForVisibleRows, rows.contains(beforeIndexPath) {
                        if let updateHandler = updateHandler, let cell = cellForRow(at: beforeIndexPath) {
                            updateHandler(cell, change.item, beforeIndex, afterIndex)
                        } else {
                            reloadRows(at: [IndexPath(row: beforeIndex, section: sectionIndex)], with: rowAnimation)
                        }
                    }
            }
        }
        endUpdates()
    }

}

// MARK: Bonus: Change animation for collection views.

public extension UICollectionView {
    
    /// Animates item & section changes in the collection view.
    ///
    /// - Note: Make sure that the changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - changes: The changes to animate.
    ///   - updateHandler: An optional handler that gets called for every visible item that has an `Update` change. When omitted, `reloadItemsAtIndexPaths` is called instead. Defaults to `nil`.
    ///   - completion: An optional handler that is called after applying the changes. The boolean parameter signifies if the animations were completed. Defaults to `nil`.
    func applyChanges<Section: IdentifiableSection, Item>(_ changes: ([ArrayChange<Section>], [SectionedArrayChange<Item>]), updateHandler: ((Item, IndexPath, IndexPath) -> Void)? = nil, completion:  ((Bool) -> Void)? = nil) where Section.Item == Item {
        applyChanges(changes.0, itemChanges: changes.1, updateHandler: updateHandler, completion: completion)
    }
    
    /// Animates item & section changes in the collection view.
    ///
    /// - Note: Make sure that the changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - sectionChanges: The section changes to animate.
    ///   - itemChanges: The item changes to animate.
    ///   - updateHandler: An optional handler that gets called for every visible item that has an `Update` change. When omitted, `reloadItemsAtIndexPaths` is called instead. Defaults to `nil`.
    ///   - completion: An optional handler that is called after applying the changes. The boolean parameter signifies if the animations were completed. Defaults to `nil`.
    func applyChanges<Section: IdentifiableSection, Item>(_ sectionChanges: [ArrayChange<Section>], itemChanges: [SectionedArrayChange<Item>], updateHandler: ((Item, IndexPath, IndexPath) -> Void)? = nil, completion:  ((Bool) -> Void)? = nil) where Section.Item == Item {
        
        performBatchUpdates({
            
            for change in sectionChanges {
                switch change.type {
                    case .insert(let index):
                        self.insertSections(IndexSet(integer: index))
                    case .delete(let index):
                        self.deleteSections(IndexSet(integer: index))
                    case .move(let oldIndex, let newIndex):
                        self.moveSection(oldIndex, toSection: newIndex)
                    case .update(let oldIndex, _):
                        self.reloadSections(IndexSet(integer: oldIndex))
                }
            }
            
            for change in itemChanges {
                switch change.type {
                    case .insert(let indexPath):
                        self.insertItems(at: [indexPath])
                        OperationQueue.main.addOperation() {
                            self.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
                        }
                    case .delete(let indexPath):
                        self.deleteItems(at: [indexPath])
                    case .move(let oldIndexPath, let newIndexPath):
                        self.moveItem(at: oldIndexPath, to: newIndexPath)
                    case .update(let oldIndexPath, let newIndexPath):
                        if self.indexPathsForVisibleItems.contains(oldIndexPath) {
                            if let updateHandler = updateHandler {
                                updateHandler(change.item, oldIndexPath, newIndexPath)
                            } else {
                                self.reloadItems(at: [oldIndexPath])
                            }
                        }
                }
            }
            
        }, completion: completion)
    }
    
    /// Animates item changes in a specific section.
    ///
    /// - Note: Make sure that the changes have been applied to the data source before calling this method.
    ///
    /// - Parameters:
    ///   - changes: The changes to animate.
    ///   - sectionIndex: The section in which the changes have been applied to the data source.
    ///   - updateHandler: An optional handler that gets called for every visible item that has an `Update` change. When omitted, `reloadItemsAtIndexPaths` is called instead. Defaults to `nil`.
    ///   - completion: An optional handler that is called after applying the changes. The boolean parameter signifies if the animations were completed. Defaults to `nil`.
    func applyChanges<Item>(_ changes: [ArrayChange<Item>], sectionIndex: Int, updateHandler: ((Item, Int, Int) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        
        performBatchUpdates({ [unowned self] in
            
            for change in changes {
                switch change.type {
                    case .insert(let index):
                        let indexPath = IndexPath(item: index, section: sectionIndex)
                        self.insertItems(at: [indexPath])
                        OperationQueue.main.addOperation() {
                            self.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
                        }
                    case .delete(let index):
                        self.deleteItems(at: [IndexPath(item: index, section: sectionIndex)])
                    case .move(let beforeIndex, let afterIndex):
                        self.moveItem(
                            at: IndexPath(item: beforeIndex, section: sectionIndex),
                            to: IndexPath(item: afterIndex, section: sectionIndex))
                    case .update(let beforeIndex, let afterIndex):
                        if self.indexPathsForVisibleItems.contains(IndexPath(item: beforeIndex, section: sectionIndex)) {
                            if let updateHandler = updateHandler {
                                updateHandler(change.item, beforeIndex, afterIndex)
                            } else {
                                self.reloadItems(at: [IndexPath(item: beforeIndex, section:  sectionIndex)])
                            }
                        }
                    }
            }
        }, completion: completion)
    }

}
