//
//  HapticManager.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI
import UIKit

/// Centralized manager for haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Button Haptic Feedback
    
    /// Triggers a light impact haptic for button taps
    func buttonTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a medium impact haptic for more significant actions
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a success haptic for completed operations
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Triggers an error haptic for failed operations
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Slider Haptic Feedback
    
    /// Triggers a very light impact for slider value changes
    func sliderChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Triggers haptic feedback when slider reaches certain threshold values
    func sliderThreshold() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - SwiftUI View Extensions

extension View {
    /// Adds a button tap haptic feedback action to a view
    func hapticOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticManager.shared.buttonTap()
            }
        )
    }
} 