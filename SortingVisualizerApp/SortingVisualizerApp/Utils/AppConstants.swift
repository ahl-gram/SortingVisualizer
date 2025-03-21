import Foundation
import SwiftUI

/// Global constants for the Sorting Visualizer App
/// These constants are accessible across the entire application
enum AppConstants {
    // MARK: - Animation Constants
    enum Animation {
        /// Base delay for visualization (nanoseconds) - .5 second
        static let baseDelay: UInt64 = 500_000_000
        
        /// Duration for standard transitions
        static let standardDuration: Double = 0.3
        
        /// Duration for comparing transitions
        static let compareDuration: Double = 0.2
        
        /// Duration for sort completion transition
        static let completionDuration: Double = 1.0
        
        /// Duration for marking bars as sorted
        static let sortedMarkDuration: Double = 0.5
        
        /// Minimum animation speed - .5 second
        static let minAnimationSpeed: Double = 1.0
        
        /// Maximum animation speed - .025 second => 25 milliseconds
        static let maxAnimationSpeed: Double = 20.0
    }
    
    // MARK: - Audio Constants
    enum Audio {
        /// Maximum possible bar value used for normalization
        static let maxBarValue: Int = 200
        
        /// Duration of each tone (seconds)
        static let toneDuration: Float = 0.1
        
        /// Tone value for sorted bars
        static let sortedToneValue: Int = 200

        /// Base frequency for the tone (Bflat 2 note)
        static let baseFrequency: Float = 116.5

        /// Maximum frequency for the tone (Bflat 4 note)
        static let maxFrequency: Float = 349.66
    }
    
    // MARK: - Bar Generation Constants
    enum BarGeneration {
        /// Minimum height for bars
        static let minHeight: Int = 10
        
        /// Maximum height
        static let maxHeight: Int = 500
    }
    
    // MARK: - UI Constants
    enum UI {
        /// Standard corner radius for UI elements
        static let cornerRadius: CGFloat = 8
    }
    
    // MARK: - Default Values
    enum DefaultValues {
        /// Default size of the array to be sorted
        static let arraySize: Double = 25
        
        /// Default animation speed
        static let animationSpeed: Double = 12.0
        
        /// Default distribution type (uniform or not)
        static let isUniformDistribution: Bool = false

        /// Default status of the audio
        static let isAudioEnabled: Bool = false
    }
} 