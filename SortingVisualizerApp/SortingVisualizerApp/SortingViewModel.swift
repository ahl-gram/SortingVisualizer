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
        
        // Generate a new array of random values
        var newBars: [SortingBar] = []
        
        // Define height parameters
        let minHeight = 10
        
        // Use higher maximum heights overall to better utilize vertical space
        // Even with many bars, we want significant height differences
        let maxHeight: Int
        switch size {
        case 10...30:
            maxHeight = 500  // Maximum height for small arrays - increased for more dramatic effect
        case 31...60:
            maxHeight = 450  // Medium-sized arrays - higher than before
        default:
            maxHeight = 400  // Large arrays - significantly higher than before
        }
        
        // For larger arrays, ensure better distribution across the full height range
        if size > 50 {
            // Create a statistical distribution that favors varied heights
            
            // Add a bar with maximum height to ensure we use the full height
            newBars.append(SortingBar(value: maxHeight))
            
            // Add a bar with minimum height
            newBars.append(SortingBar(value: minHeight))
            
            // Add some bars in the upper range (top 25%)
            let upperQuartile = maxHeight - (maxHeight - minHeight) / 4
            for _ in 0..<max(3, size / 20) {
                let value = Int.random(in: upperQuartile...maxHeight)
                newBars.append(SortingBar(value: value))
            }
            
            // Add some bars in the lower range (bottom 25%)
            let lowerQuartile = minHeight + (maxHeight - minHeight) / 4
            for _ in 0..<max(3, size / 20) {
                let value = Int.random(in: minHeight...lowerQuartile)
                newBars.append(SortingBar(value: value))
            }
            
            // Fill the rest with a wider distribution
            // Use a curve that creates more variety
            for _ in 0..<(size - newBars.count) {
                // Use biased randomization to create more variety
                let bias = Double.random(in: 0.0...1.0)
                let biasedRandom: Int
                
                if bias < 0.5 {
                    // Bias toward lower values with some medium ones
                    biasedRandom = Int.random(in: minHeight...(minHeight + (maxHeight - minHeight) / 2))
                } else if bias < 0.8 {
                    // Some middle range values
                    biasedRandom = Int.random(in: (minHeight + (maxHeight - minHeight) / 3)...(minHeight + 2 * (maxHeight - minHeight) / 3))
                } else {
                    // Some higher values
                    biasedRandom = Int.random(in: (minHeight + 2 * (maxHeight - minHeight) / 3)...maxHeight)
                }
                
                newBars.append(SortingBar(value: biasedRandom))
            }
        } else {
            // For smaller arrays, ensure we have full range coverage
            // Add a bar with maximum height
            newBars.append(SortingBar(value: maxHeight))
            
            // Add a bar with minimum height
            newBars.append(SortingBar(value: minHeight))
            
            // Add a few bars at different quartiles to ensure good distribution
            if size > 15 {
                newBars.append(SortingBar(value: minHeight + (maxHeight - minHeight) / 4))  // Q1
                newBars.append(SortingBar(value: minHeight + (maxHeight - minHeight) / 2))  // Q2 (median)
                newBars.append(SortingBar(value: minHeight + 3 * (maxHeight - minHeight) / 4)) // Q3
            }
            
            // Fill the rest with random heights
            for _ in 0..<(size - newBars.count) {
                let randomValue = Int.random(in: minHeight...maxHeight)
                newBars.append(SortingBar(value: randomValue))
            }
        }
        
        // Shuffle the array to randomize the positions
        newBars.shuffle()
        
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
                try? await Task.sleep(nanoseconds: UInt64(500_000_000 / animationSpeed))
                
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
                    
                    // Delay for visualization
                    try? await Task.sleep(nanoseconds: UInt64(500_000_000 / animationSpeed))
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