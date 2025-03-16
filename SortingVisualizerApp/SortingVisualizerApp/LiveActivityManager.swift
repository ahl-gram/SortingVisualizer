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
    
    init() {
        // Print out useful debug info when created
        print("LiveActivityManager: Initialized")
        let authInfo = ActivityAuthorizationInfo()
        print("LiveActivityManager: Activities enabled: \(authInfo.areActivitiesEnabled)")
        
        // Check for existing activities from this app
        if #available(iOS 16.2, *) {
            let activities = Activity<VerticalBarsAttributes>.activities
            print("LiveActivityManager: \(activities.count) existing activities found")
            for activity in activities {
                print("LiveActivityManager: Found activity with ID: \(activity.id)")
            }
        }
    }
    
    // Start a new live activity when sorting begins
    func startLiveActivity(algorithmName: String, barHeights: [Int]) {
        // First, end any existing activity
        endLiveActivity()
        
        print("LiveActivityManager: Attempting to start Live Activity for \(algorithmName)")
        
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("LiveActivityManager: ERROR - Live Activities are not supported on this device")
            return
        }
        
        // Normalize the bar heights to values between 0.0 and 1.0
        let maxBarHeight = barHeights.max() ?? 1
        let normalizedHeights = barHeights.map { Double($0) / Double(maxBarHeight) }
        
        print("LiveActivityManager: Normalized \(barHeights.count) bar heights for Live Activity")
        
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
            print("LiveActivityManager: Successfully started Live Activity with ID: \(String(describing: activity?.id))")
            
            // For debugging in Simulator - trigger the Live Activity to show
            #if targetEnvironment(simulator)
            print("LiveActivityManager: Running in simulator - you may need to manually trigger the Live Activity")
            print("LiveActivityManager: Go to Device menu > Trigger Live Activity")
            #endif
        } catch {
            print("LiveActivityManager: ERROR starting Live Activity: \(error.localizedDescription)")
            print("LiveActivityManager: Detailed error: \(error)")
        }
    }
    
    // Update the live activity with new bar heights
    func updateLiveActivity(barHeights: [Int], isPlaying: Bool = true) {
        guard let activity = activity else {
            print("LiveActivityManager: Cannot update - no active Live Activity")
            return
        }
        
        print("LiveActivityManager: Updating Live Activity")
        
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
            print("LiveActivityManager: Activity updated")
        }
    }
    
    // End the live activity when sorting is complete
    func endLiveActivity() {
        if #available(iOS 16.2, *) {
            // End all existing activities if any
            let activities = Activity<VerticalBarsAttributes>.activities
            for activity in activities {
                print("LiveActivityManager: Ending existing activity with ID: \(activity.id)")
                Task {
                    await activity.end(
                        using: VerticalBarsAttributes.ContentState(
                            barHeights: activity.content.state.barHeights,
                            currentIntensity: 1.0,
                            isPlaying: false
                        ),
                        dismissalPolicy: .immediate
                    )
                }
            }
        }
        
        guard let activity = activity else {
            print("LiveActivityManager: No active Live Activity to end")
            return
        }
        
        print("LiveActivityManager: Ending Live Activity")
        
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
            print("LiveActivityManager: Activity ended successfully")
            self.activity = nil
        }
    }
    
    // Pause the live activity
    func pauseLiveActivity() {
        guard let activity = activity else {
            print("LiveActivityManager: Cannot pause - no active Live Activity")
            return
        }
        
        print("LiveActivityManager: Pausing Live Activity")
        
        let pausedState = VerticalBarsAttributes.ContentState(
            barHeights: activity.content.state.barHeights,
            currentIntensity: 0.3,
            isPlaying: false
        )
        
        Task {
            await activity.update(using: pausedState)
            print("LiveActivityManager: Activity paused")
        }
    }
} 