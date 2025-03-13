//
//  ContentView.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Sorting Visualizer")
                    .font(.largeTitle)
                Spacer()
                // Placeholder for visual components (sorting animation)
                Text("Sorting animation here")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
                Spacer()
                // Placeholder for control components (sliders and buttons)
                Text("Control panel here")
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
