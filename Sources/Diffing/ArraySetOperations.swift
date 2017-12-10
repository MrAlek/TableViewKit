//
//  TableViewKit
//
//  Copyright (c) 2017 Alek Åström.
//  Licensed under the MIT license, see LICENSE file.
//

import Foundation

internal extension Array where Element: Equatable {
    
    /// Returns an array with provided values filtered out
    ///
    /// Example: `[1,2].subtract([1,3]) == [2]`
    ///
    /// - Parameter values: The values to filter out
    /// - Returns: the filtered array
    func subtract(_ values: [Element]) -> [Element] {
        return self.filter { !values.contains($0) }
    }
    
}

/// Returns the resulting array of subtracting the elements in the right hand side from the left hand side.
///
/// Example: `[1,2] - [1,3] == [2]`
///
/// - Parameters:
///   - lhs: The array to subtract from.
///   - rhs: The array containing the elements to subtract.
/// - Returns: The resulting array.
internal func - <Element: Equatable>(lhs: [Element], rhs: [Element]) -> [Element] {
    return lhs.subtract(rhs)
}
