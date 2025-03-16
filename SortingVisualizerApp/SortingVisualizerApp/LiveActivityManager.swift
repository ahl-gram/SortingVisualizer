//
//  LiveActivityManager.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/16/25.
//

import Foundation
import ActivityKit
import SwiftUI

class LiveActivityManager {
    private var activity: Activity<VerticalBarsAttributes>?
    
    // Start a new live activity when sorting begins
    func startLiveActivity(algorithmName: String, barHeights: [Int]) {
        // First, end any existing activity
        endLiveActivity()
        
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not supported on this device")
            return
        }
        
        // Normalize the bar heights to values between 0.0 and 1.0
        let maxBarHeight = barHeights.max() ?? 1
        let normalizedHeights = barHeights.map { Double($0) / Double(maxBarHeight) }
        
        // Create the initial state
        let initialState = VerticalBarsAttributes.ContentState(
            barHeights: normalizedHeights,
            currentIntensity: 0.5,
            isPlaying: true
        )
        
        // Create the attribute with static properties
        let attributes = VerticalBarsAttributes(
            sessionName: "\(algorithmName) Sort",
            startTime: Date()
        )
        
        // Start the live activity
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            print("Started Live Activity: \(String(describing: activity?.id))")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    // Update the live activity with new bar heights
    func updateLiveActivity(barHeights: [Int], isPlaying: Bool = true) {
        guard let activity = activity else { return }
        
        // Normalize the bar heights to values between 0.0 and 1.0
        let maxBarHeight = barHeights.max() ?? 1
        let normalizedHeights = barHeights.map { Double($0) / Double(maxBarHeight) }
        
        // Calculate current intensity (can be based on how far into sorting we are)
        // This is a simple example - you might want to derive this from other metrics
        let currentIntensity = isPlaying ? 0.8 : 0.3
        
        // Create the new state
        let updatedState = VerticalBarsAttributes.ContentState(
            barHeights: normalizedHeights,
            currentIntensity: currentIntensity,
            isPlaying: isPlaying
        )
        
        // Update the activity
        Task {
            await activity.update(using: updatedState)
        }
    }
    
    // End the live activity when sorting is complete
    func endLiveActivity() {
        guard let activity = activity else { return }
        
        Task {
            // End the activity
            await activity.end(
                using: VerticalBarsAttributes.ContentState(
                    barHeights: activity.content.state.barHeights,
                    currentIntensity: 1.0,
                    isPlaying: false
                ),
                dismissalPolicy: .immediate
            )
            self.activity = nil
        }
    }
    
    // Pause the live activity
    func pauseLiveActivity() {
        guard let activity = activity else { return }
        
        let pausedState = VerticalBarsAttributes.ContentState(
            barHeights: activity.content.state.barHeights,
            currentIntensity: 0.3,
            isPlaying: false
        )
        
        Task {
            await activity.update(using: pausedState)
        }
    }
} 