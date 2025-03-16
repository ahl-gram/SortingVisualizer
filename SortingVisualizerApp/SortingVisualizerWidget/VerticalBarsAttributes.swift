//
//  VerticalBarsAttributes.swift
//  SortingVisualizerWidget
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import Foundation

// This is a duplicate of the attributes in the main app to ensure it's available in the widget extension
struct VerticalBarsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Properties that will change as your vertical bars move
        var barHeights: [Double] // Array of heights for your vertical bars
        var currentIntensity: Double // Overall intensity/amplitude
        var isPlaying: Bool // If your visualization is active
    }
    
    // Static properties that don't change during the activity
    var sessionName: String
    var startTime: Date
} 