//
//  SortingViewModel.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

class SortingViewModel: ObservableObject {
    @Published var bars: [SortingBar] = []
    @Published var isSorting: Bool = false
    @Published var isAudioEnabled: Bool = true {
        didSet {
            audioManager.setAudioEnabled(isAudioEnabled)
        }
    }
    @Published var showCompletionAnimation: Bool = false
    
    private var sortingTask: Task<Void, Never>?
    private let audioManager = AudioManager()
    
    // Computed property to detect when bars are being compared
    var hasComparingBars: Bool {
        bars.contains { $0.state == .comparing }
    }
    
    struct SortingBar: Identifiable {
        let id = UUID()
        var value: Int
        var state: BarState = .unsorted
    }
    
    func randomizeArray(size: Int) {
        // Stop any ongoing sorting
        stopSorting()
        
        // Reset completion animation flag
        showCompletionAnimation = false
        
        // Generate a new array of bars with unique, uniformly distributed heights
        var newBars: [SortingBar] = []
        
        // Define height parameters
        let minHeight = 10
        
        // Set maximum height based on array size
        let maxHeight: Int
        switch size {
        case 10...30:
            maxHeight = 500
        case 31...60:
            maxHeight = 450
        default:
            maxHeight = 400
        }
        
        // Calculate the range of heights
        let heightRange = maxHeight - minHeight
        
        // Generate a sequence of uniformly distributed heights
        // by dividing the height range into equal steps
        var heights: [Int] = []
        
        // If the array size is small, we can use the exact step size to get perfect distribution
        if size <= heightRange {
            // Calculate step size to evenly distribute heights
            let step = heightRange / (size - 1)
            
            // Generate heights with uniform distribution
            for i in 0..<size {
                heights.append(minHeight + (i * step))
            }
        } else {
            // When we have more bars than the height range, we need to ensure uniqueness
            // by generating all possible heights and then sampling from them
            
            // Generate all possible heights in the range
            var allPossibleHeights = Array(minHeight...maxHeight)
            
            // Shuffle the heights to randomize selection
            allPossibleHeights.shuffle()
            
            // Select 'size' number of unique heights
            heights = Array(allPossibleHeights.prefix(size))
        }
        
        // Shuffle the heights for final randomization
        heights.shuffle()
        
        // Create bars with the unique heights
        for height in heights {
            newBars.append(SortingBar(value: height))
        }
        
        // Update the bars array
        withAnimation {
            bars = newBars
        }
    }
    
    func startBubbleSort(animationSpeed: Double) {
        // Cancel any existing sorting task
        stopSorting()
        
        // Reset completion animation flag
        showCompletionAnimation = false
        
        // Set sorting flag
        isSorting = true
        
        // Start a new sorting task
        sortingTask = Task {
            await bubbleSort(animationSpeed: animationSpeed)
        }
    }
    
    func stopSorting() {
        sortingTask?.cancel()
        sortingTask = nil
        isSorting = false
        showCompletionAnimation = false
        
        // Reset all bars to unsorted state
        for i in 0..<bars.count {
            bars[i].state = .unsorted
        }
    }
    
    private func bubbleSort(animationSpeed: Double) async {
        let n = bars.count
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
                        bars[j].state = .comparing
                        bars[j + 1].state = .comparing
                    }
                    
                    // Play tone for the first bar being compared
                    if isAudioEnabled {
                        audioManager.playTone(forValue: bars[j].value)
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
                        audioManager.playTone(forValue: bars[j + 1].value)
                    }
                }
                
                if bars[j].value > bars[j + 1].value {
                    // Swap the elements
                    await MainActor.run {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let temp = bars[j]
                            bars[j] = bars[j + 1]
                            bars[j + 1] = temp
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
                        bars[j].state = .unsorted
                        if j < n - i - 1 {
                            bars[j + 1].state = .unsorted
                        }
                    }
                }
            }
            
            // Mark the last element as sorted
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    bars[n - i - 1].state = .sorted
                }
                
                // Play a higher tone for sorted element
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
            showCompletionAnimation = true
            isSorting = false
        }
    }
    
    private func markAllAsSorted() {
        withAnimation(.easeInOut(duration: 1.0)) {
            for i in 0..<bars.count {
                if bars[i].state != .sorted {
                    bars[i].state = .sorted
                    
                    // Play a tone for each newly sorted element
                    if isAudioEnabled {
                        audioManager.playTone(forValue: 200)
                    }
                }
            }
        }
    }
    
    deinit {
        audioManager.cleanup()
    }
} 