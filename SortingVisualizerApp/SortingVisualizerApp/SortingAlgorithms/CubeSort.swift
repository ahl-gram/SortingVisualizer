import Foundation
import SwiftUI

/// Pure cube sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum CubeSort {
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        let cubeSize = 8 // Same as CUBE_SIZE in the C# example
        var arr = array
        let n = arr.count
        
        // Divide the array into cubes of size cubeSize and sort each cube
        for i in stride(from: 0, to: n, by: cubeSize) {
            let end = min(i + cubeSize, n)
            
            // Highlight the current cube
            for j in i..<end {
                _ = await onStep(.highlight(j), arr)
            }
            
            // Sort the current cube using insertion sort
            for j in (i + 1)..<end {
                let key = arr[j]
                var k = j - 1
                
                while k >= i && arr[k] > key {
                    _ = await onStep(.compare(k, j), arr)
                    _ = await onStep(.swap(k + 1, k), arr)
                    arr[k + 1] = arr[k]
                    k -= 1
                }
                
                arr[k + 1] = key
            }
            
            // Unhighlight the current cube
            for j in i..<end {
                _ = await onStep(.unhighlight(j), arr)
            }
        }
        
        // First merge pass - directly matching the C# implementation
        var temp = arr
        for i in stride(from: 0, to: n, by: cubeSize) {
            let end = min(i + cubeSize, n)
            
            // Highlight the current cube for merging
            for j in i..<end {
                _ = await onStep(.highlight(j), arr)
            }
            
            // Copy segment to temp array
            for j in i..<end {
                temp[j] = arr[j]
            }
            
            // Sort the segment in temp
            // Using insertion sort for visualization
            for j in (i + 1)..<end {
                let key = temp[j]
                var k = j - 1
                
                while k >= i && temp[k] > key {
                    _ = await onStep(.compare(k, j), arr)
                    temp[k + 1] = temp[k]
                    k -= 1
                }
                
                temp[k + 1] = key
            }
            
            // Copy back to original array with visualization
            for j in i..<end {
                arr[j] = temp[j]
                _ = await onStep(.swap(j, j), arr)
            }
            
            // Unhighlight the current cube
            for j in i..<end {
                _ = await onStep(.unhighlight(j), arr)
            }
        }
        
        // Second merge pass - identical to the first, matching the C# implementation
        for i in stride(from: 0, to: n, by: cubeSize) {
            let end = min(i + cubeSize, n)
            
            // Highlight the current cube for merging
            for j in i..<end {
                _ = await onStep(.highlight(j), arr)
            }
            
            // Copy segment to temp array
            for j in i..<end {
                temp[j] = arr[j]
            }
            
            // Sort the segment in temp
            // Using insertion sort for visualization
            for j in (i + 1)..<end {
                let key = temp[j]
                var k = j - 1
                
                while k >= i && temp[k] > key {
                    _ = await onStep(.compare(k, j), arr)
                    temp[k + 1] = temp[k]
                    k -= 1
                }
                
                temp[k + 1] = key
            }
            
            // Copy back to original array with visualization
            for j in i..<end {
                arr[j] = temp[j]
                _ = await onStep(.swap(j, j), arr)
            }
            
            // Unhighlight the current cube
            for j in i..<end {
                _ = await onStep(.unhighlight(j), arr)
            }
        }
        
        // Mark all elements as sorted
        for i in 0..<n {
            _ = await onStep(.markSorted(i), arr)
        }
        
        // Signal completion
        _ = await onStep(.completed, arr)
        
        return arr
    }
}