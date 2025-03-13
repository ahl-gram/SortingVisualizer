//
//  SafeAreaViewModifier.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct SafeAreaViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
            .safeAreaInset(edge: .leading) { Color.clear.frame(width: 0) }
            .safeAreaInset(edge: .trailing) { Color.clear.frame(width: 0) }
    }
}

extension View {
    func avoidDynamicIsland() -> some View {
        self.modifier(SafeAreaViewModifier())
    }
} 