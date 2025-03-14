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
        
        // Scale the range of values based on array size to ensure they're visually appealing
        // For smaller arrays, allow taller bars
        // For larger arrays, keep the height more constrained to avoid overcrowding
        let minHeight = 10
        let maxHeight = min(200, 400 - size * 2) // Reduce max height as array size increases
        
        for _ in 0..<size {
            let randomValue = Int.random(in: minHeight...maxHeight)
            newBars.append(SortingBar(value: randomValue))
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