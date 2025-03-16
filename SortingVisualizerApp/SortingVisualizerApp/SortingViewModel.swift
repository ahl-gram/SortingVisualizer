//
//  SortingViewModel.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI
import ActivityKit

class SortingViewModel: ObservableObject {
    @Published var bars: [SortingBar] = []
    @Published var isSorting: Bool = false
    @Published var isAudioEnabled: Bool = true {
        didSet {
            audioManager.setAudioEnabled(isAudioEnabled)
        }
    }
    @Published var showCompletionAnimation: Bool = false
    @Published var selectedAlgorithm: SortingAlgorithmType = .bubble
    @Published var isLiveActivityEnabled: Bool = true
    
    // MARK: - Private properties
    private var sortingTask: Task<Void, Never>?
    private let audioManager = AudioManager()
    private let liveActivityManager = LiveActivityManager()
    
    // Computed property to detect when bars are being compared
    var hasComparingBars: Bool {
        bars.contains { $0.state == .comparing }
    }
    
    struct SortingBar: Identifiable {
        let id = UUID()
        var value: Int
        var state: BarState = .unsorted
    }
    
    // MARK: - Public methods
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
    
    func startSorting(animationSpeed: Double) {
        // Cancel any existing sorting task
        stopSorting()
        
        // Reset completion animation flag
        showCompletionAnimation = false
        
        // Set sorting flag
        isSorting = true
        
        // Start Live Activity if enabled
        if isLiveActivityEnabled {
            let barValues = bars.map { $0.value }
            liveActivityManager.startLiveActivity(
                algorithmName: selectedAlgorithm.rawValue.capitalized,
                barHeights: barValues
            )
        }
        
        // Start a new sorting task based on selected algorithm
        sortingTask = Task {
            // Add live activity update mechanism
            let updateInterval = animationSpeed > 0.5 ? 0.5 : animationSpeed * 1.5
            var lastUpdateTime = Date()
            
            switch selectedAlgorithm {
            case .bubble:
                await SortingAlgorithms.bubbleSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        guard let self = self else { return }
                        self.bars = updatedBars
                        
                        // Update Live Activity periodically
                        if self.isLiveActivityEnabled && Date().timeIntervalSince(lastUpdateTime) > updateInterval {
                            let barValues = updatedBars.map { $0.value }
                            self.liveActivityManager.updateLiveActivity(barHeights: barValues)
                            lastUpdateTime = Date()
                        }
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        self.showCompletionAnimation = true
                        self.isSorting = false
                        
                        // End live activity when sorting is complete
                        if self.isLiveActivityEnabled {
                            self.liveActivityManager.endLiveActivity()
                        }
                    }
                )
            case .quick:
                await SortingAlgorithms.quickSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        guard let self = self else { return }
                        self.bars = updatedBars
                        
                        // Update Live Activity periodically
                        if self.isLiveActivityEnabled && Date().timeIntervalSince(lastUpdateTime) > updateInterval {
                            let barValues = updatedBars.map { $0.value }
                            self.liveActivityManager.updateLiveActivity(barHeights: barValues)
                            lastUpdateTime = Date()
                        }
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        self.showCompletionAnimation = true
                        self.isSorting = false
                        
                        // End live activity when sorting is complete
                        if self.isLiveActivityEnabled {
                            self.liveActivityManager.endLiveActivity()
                        }
                    }
                )
            case .merge:
                await SortingAlgorithms.mergeSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        guard let self = self else { return }
                        self.bars = updatedBars
                        
                        // Update Live Activity periodically
                        if self.isLiveActivityEnabled && Date().timeIntervalSince(lastUpdateTime) > updateInterval {
                            let barValues = updatedBars.map { $0.value }
                            self.liveActivityManager.updateLiveActivity(barHeights: barValues)
                            lastUpdateTime = Date()
                        }
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        self.showCompletionAnimation = true
                        self.isSorting = false
                        
                        // End live activity when sorting is complete
                        if self.isLiveActivityEnabled {
                            self.liveActivityManager.endLiveActivity()
                        }
                    }
                )
            }
        }
    }
    
    func stopSorting() {
        sortingTask?.cancel()
        sortingTask = nil
        isSorting = false
        showCompletionAnimation = false
        
        // Pause or end the live activity when sorting stops
        if isLiveActivityEnabled {
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                liveActivityManager.pauseLiveActivity()
            }
        }
        
        // Reset all bars to unsorted state
        for i in 0..<bars.count {
            bars[i].state = .unsorted
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
        liveActivityManager.endLiveActivity()
    }
} 