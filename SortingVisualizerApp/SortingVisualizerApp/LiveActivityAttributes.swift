//
//  LiveActivityAttributes.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import Foundation

struct DeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Define the dynamic content that can change over time
        var status: String
        var progress: Double
        
        // Add more properties as needed for your animation
    }
    
    // Define static content that doesn't change
    var orderNumber: String
    var estimatedDelivery: Date
}
