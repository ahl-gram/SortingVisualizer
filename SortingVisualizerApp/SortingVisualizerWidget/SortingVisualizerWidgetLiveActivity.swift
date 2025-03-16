//
//  SortingVisualizerWidgetLiveActivity.swift
//  SortingVisualizerWidget
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Using our defined VerticalBarsAttributes
struct SortingVisualizerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VerticalBarsAttributes.self) { context in
            // Lock screen/banner UI goes here - simplified version
            HStack {
                Text(context.attributes.sessionName)
                    .font(.headline)
                
                Spacer()
                
                Text(context.state.isPlaying ? "Sorting..." : "Paused")
            }
            .padding()
            .activityBackgroundTint(Color.blue.opacity(0.2))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here - simplified for reliability
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.sessionName)
                        .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.isPlaying ? "Active" : "Paused")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // Very simplified version
                    HStack(spacing: 4) {
                        ForEach(0..<min(6, context.state.barHeights.count), id: \.self) { index in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 8, height: context.state.barHeights[index] * 40)
                        }
                    }
                    .padding()
                }
            } compactLeading: {
                // Simple text for compact leading
                Text("Sort")
                    .font(.caption)
            } compactTrailing: {
                // Simple circle for compact trailing
                Circle()
                    .fill(context.state.isPlaying ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
            } minimal: {
                // Minimal view - just a colored circle
                Circle()
                    .fill(context.state.isPlaying ? Color.green : Color.orange)
                    .frame(width: 12, height: 12)
            }
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
            barHeights: [0.5, 0.3, 0.8, 0.2, 0.6, 0.4],
            currentIntensity: 0.7,
            isPlaying: true
        )
    }
    
    fileprivate static var paused: VerticalBarsAttributes.ContentState {
        VerticalBarsAttributes.ContentState(
            barHeights: [0.5, 0.3, 0.8, 0.2, 0.6, 0.4],
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
