//
//  AboutView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    
    // Get app version and build information
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 15) {
                    // Title and close button
                    HStack {
                        Text("About")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Version info
                    Text(appVersion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Description
                    Text("An interactive educational tool for visualizing and understanding sorting algorithms through animation and audio feedback.")
                        .font(.body)
                        .padding(.bottom, 5)
                    
                    // Use horizontal layout for landscape optimization
                    HStack(alignment: .top, spacing: 20) {
                        // Features section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Features")
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            FeatureRow(icon: "list.bullet", text: "10 different sorting algorithms")
                            FeatureRow(icon: "slider.horizontal.3", text: "Adjustable array size and animation speed")
                            FeatureRow(icon: "speaker.wave.2.fill", text: "Audio feedback with pitch variation")
                            FeatureRow(icon: "chart.bar.fill", text: "Real-time visual representation of sorting steps")
                            FeatureRow(icon: "arrow.left.arrow.right", text: "Uniform or non-uniform data distribution")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        // Credits section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Credits")
                                .font(.headline)
                                .padding(.bottom, 2)
                            
                            Text("Created as a SwiftUI learning project")
                            Text("Built with Cursor, Claude and ChatGPT assistance")
                            
                            HStack {
                                Text("License:")
                                Link("MIT License", destination: URL(string: "https://choosealicense.com/licenses/mit/")!)
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .frame(minWidth: geometry.size.width - 40)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            // Position to center of the screen accounting for safe areas
            .frame(width: geometry.size.width, height: min(geometry.size.height - 10, 350))
        }
    }
}

struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}

#Preview("Landscape", traits: .landscapeLeft) {
    AboutView(isPresented: .constant(true))
} 