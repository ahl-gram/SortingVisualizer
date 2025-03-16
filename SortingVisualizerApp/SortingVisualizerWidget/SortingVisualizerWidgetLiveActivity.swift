//
//  SortingVisualizerWidgetLiveActivity.swift
//  SortingVisualizerWidget
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Using our defined VerticalBarsAttributes from the main app
struct SortingVisualizerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VerticalBarsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text(context.attributes.sessionName)
                    .font(.headline)
                
                // Visualization of bars
                HStack(spacing: 2) {
                    ForEach(Array(context.state.barHeights.enumerated()), id: \.offset) { index, height in
                        Rectangle()
                            .fill(height > 0.7 ? Color.red : Color.blue)
                            .frame(width: 6, height: CGFloat(height * 50))
                            .animation(.spring(response: 0.3), value: height)
                    }
                }
                .frame(height: 60)
                .padding()
                
                Text("Intensity: \(Int(context.state.currentIntensity * 100))%")
                    .font(.caption)
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        Text(context.attributes.sessionName)
                            .font(.caption)
                        Text(context.state.isPlaying ? "Sorting" : "Paused")
                            .font(.caption2)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Intensity: \(Int(context.state.currentIntensity * 100))%")
                        .font(.caption2)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Implement expanded view directly
                    VStack {
                        Text(context.attributes.sessionName)
                            .font(.headline)
                        
                        // Visual representation of bars
                        HStack(spacing: 4) {
                            ForEach(0..<min(8, context.state.barHeights.count), id: \.self) { index in
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: context.state.barHeights[index] * 50)
                                    .animation(.spring(response: 0.3), value: context.state.barHeights[index])
                            }
                        }
                        .frame(height: 60)
                        .padding()
                        
                        Text("Intensity: \(Int(context.state.currentIntensity * 100))%")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                // Implement compact leading view directly
                HStack(spacing: 2) {
                    // Mini visualization of bars
                    ForEach(0..<min(4, context.state.barHeights.count), id: \.self) { index in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 3, height: context.state.barHeights[index] * 15)
                            .animation(.spring(response: 0.3), value: context.state.barHeights[index])
                    }
                }
            } compactTrailing: {
                // Implement compact trailing view directly
                Text(context.state.isPlaying ? "Playing" : "Paused")
                    .font(.caption2)
                    .foregroundColor(.white)
            } minimal: {
                // Show a simple indicator for minimal view
                Circle()
                    .fill(context.state.isPlaying ? Color.green : Color.orange)
                    .frame(width: 20, height: 20)
            }
            .widgetURL(URL(string: "sorting://visualization"))
            .keylineTint(Color.blue)
        }
    }
}

// Preview data
extension VerticalBarsAttributes {
    fileprivate static var preview: VerticalBarsAttributes {
        VerticalBarsAttributes(
            sessionName: "Bubble Sort",
            startTime: Date()
        )
    }
}

extension VerticalBarsAttributes.ContentState {
    fileprivate static var sorting: VerticalBarsAttributes.ContentState {
        VerticalBarsAttributes.ContentState(
            barHeights: [0.5, 0.3, 0.8, 0.2, 0.6, 0.4, 0.7, 0.1],
            currentIntensity: 0.7,
            isPlaying: true
        )
    }
    
    fileprivate static var paused: VerticalBarsAttributes.ContentState {
        VerticalBarsAttributes.ContentState(
            barHeights: [0.5, 0.3, 0.8, 0.2, 0.6, 0.4, 0.7, 0.1],
            currentIntensity: 0.3,
            isPlaying: false
        )
    }
}

#Preview("Notification", as: .content, using: VerticalBarsAttributes.preview) {
   SortingVisualizerWidgetLiveActivity()
} contentStates: {
    VerticalBarsAttributes.ContentState.sorting
    VerticalBarsAttributes.ContentState.paused
}
