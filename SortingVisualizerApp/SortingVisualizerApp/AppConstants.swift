//
//  AppConstants.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

/// Global constants for the Sorting Visualizer App
/// These constants are accessible across the entire application
enum AppConstants {
    // MARK: - Animation Constants
    enum Animation {
        /// Base delay for visualization (nanoseconds)
        static let baseDelay: UInt64 = 500_000_000
        
        /// Duration for standard transitions
        static let standardDuration: Double = 0.3
        
        /// Duration for comparing transitions
        static let compareDuration: Double = 0.2
        
        /// Duration for sort completion transition
        static let completionDuration: Double = 1.0
        
        /// Duration for marking bars as sorted
        static let sortedMarkDuration: Double = 0.5
    }
    
    // MARK: - Audio Constants
    enum Audio {
        /// Base frequency for the lowest note (Hz)
        static let baseFrequency: Float = 116.5 // A3 note
        
        /// Maximum frequency range (Hz)
        static let frequencyRange: Float = 349.66 // Range from baseFrequency to baseFrequency + range
        
        /// Maximum possible bar value used for normalization
        static let maxBarValue: Int = 200
        
        /// Duration of each tone (seconds)
        static let toneDuration: Float = 0.1
        
        /// Tone value for sorted bars
        static let sortedToneValue: Int = 200
    }
    
    // MARK: - Bar Generation Constants
    enum BarGeneration {
        /// Minimum height for bars
        static let minHeight: Int = 10
        
        /// Maximum height for small arrays (10-30 elements)
        static let maxHeightSmall: Int = 500
        
        /// Maximum height for medium arrays (31-60 elements)
        static let maxHeightMedium: Int = 450
        
        /// Maximum height for large arrays (61+ elements)
        static let maxHeightLarge: Int = 400
    }
    
    // MARK: - UI Constants
    enum UI {
        /// Standard corner radius for UI elements
        static let cornerRadius: CGFloat = 10
        
        /// Standard padding for UI elements
        static let standardPadding: CGFloat = 16
        
        /// Button size for control buttons
        static let buttonSize: CGFloat = 44
    }
} 