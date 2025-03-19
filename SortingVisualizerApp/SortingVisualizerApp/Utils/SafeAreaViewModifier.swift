//
//  SafeAreaViewModifier.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct SafeAreaViewModifier: ViewModifier {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    func body(content: Content) -> some View {
        content
            // Respect safe areas but allow views to properly lay out with them
            .safeAreaInset(edge: .top) { 
                Spacer().frame(height: 0)
                    .background(Color.clear)
            }
            .ignoresSafeArea(.keyboard) // Only ignore keyboard, not safe areas
    }
}

// Environment value to access safe area insets directly
private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

// Helper to get safe area insets
struct SafeAreaInsetsReader: View {
    @Binding var insets: EdgeInsets
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    insets = geometry.safeAreaInsets
                }
                .onChange(of: geometry.safeAreaInsets) { oldInsets, newInsets in
                    insets = newInsets
                }
        }
    }
}

extension View {
    func avoidDynamicIsland() -> some View {
        self.modifier(SafeAreaViewModifier())
    }
    
    func respectSafeAreas() -> some View {
        self.ignoresSafeArea(.all, edges: []) // Don't ignore safe areas
    }
} 