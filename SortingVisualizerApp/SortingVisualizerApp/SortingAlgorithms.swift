//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

// Collection of sorting algorithms
enum SortingAlgorithms {
    
    // Bubble sort implementation
    static func bubbleSort(
        bars: [SortingViewModel.SortingBar],
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void,
        markAllAsSorted: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) async {
        var localBars = bars
        let n = localBars.count
        var swapped = false
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Check if the task was cancelled
                if Task.isCancelled {
                    return
                }
                
                // Animate comparison
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        localBars[j].state = .comparing
                        localBars[j + 1].state = .comparing
                        
                        // Update the UI inside the animation block for smooth transitions
                        updateBars(localBars)
                    }
                    
                    // Play tone for the first bar being compared (outside animation block)
                    if isAudioEnabled {
                        audioManager.playTone(forValue: localBars[j].value)
                    }
                }
                
                // Delay for visualization
                // Use linear scaling across the entire range (0.1x-20.0x)
                let baseDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
                let scaledDelay = UInt64(Double(baseDelay) / animationSpeed)
                
                try? await Task.sleep(nanoseconds: scaledDelay)
                
                // Play tone for the second bar being compared
                await MainActor.run {
                    if isAudioEnabled {
                        audioManager.playTone(forValue: localBars[j + 1].value)
                    }
                }
                
                if localBars[j].value > localBars[j + 1].value {
                    // Swap the elements
                    await MainActor.run {
                        // Update the UI with the swapped state using proper animation
                        // Use withAnimation to ensure the UI updates smoothly with the swap
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let temp = localBars[j]
                            localBars[j] = localBars[j + 1]
                            localBars[j + 1] = temp
                            
                            // Update the bars inside the animation block to maintain smoothness
                            updateBars(localBars)
                        }
                    }
                    
                    swapped = true
                    
                    // Delay for visualization after swap
                    let swapDelay = scaledDelay // use the same scaled delay calculated above
                    try? await Task.sleep(nanoseconds: swapDelay)
                }
                
                // Reset the state of the compared elements
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        localBars[j].state = .unsorted
                        if j < n - i - 1 {
                            localBars[j + 1].state = .unsorted
                        }
                        
                        // Update the UI inside the animation block for smooth transitions
                        updateBars(localBars)
                    }
                }
            }
            
            // Mark the last element as sorted
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    localBars[n - i - 1].state = .sorted
                    
                    // Update the UI inside the animation block for smooth transitions
                    updateBars(localBars)
                }
                
                // Play a higher tone for sorted element (outside animation block)
                if isAudioEnabled {
                    audioManager.playTone(forValue: 200) // Play the highest tone for sorted elements
                }
            }
            
            // If no swapping occurred in this pass, the array is already sorted
            if !swapped {
                break
            }
        }
        
        // Mark all remaining elements as sorted and show completion animation
        await MainActor.run {
            markAllAsSorted()
            onComplete()
        }
    }
    
    // Add more sorting algorithms here in the future (e.g., quickSort, mergeSort, etc.)
} 