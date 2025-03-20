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
        return "Sorting Visualizer v\(version) (\(build))"
    }
    
    var body: some View {
        // Use a simple ZStack instead of GeometryReader
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(radius: 10)
            
            // Content
            ScrollView {
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
                                HapticManager.shared.buttonTap()
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
                    
                    // Features section - full width
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // FAQs section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FAQs")
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        FAQItem(question: "What's This All About?", 
                                answer: "Sorting Visualizer is an interactive visualization tool that helps you understand how different sorting algorithms work by showing the process step by step with animated bars.")
                        
                        FAQItem(question: "What Is Big O Notation?", 
                                answer: "Big O Notation is a mathematical way to describe the efficiency of algorithms as input sizes grow. It describes the worst-case scenario for time or space requirements (e.g., O(n²), O(n log n)). This notation inspired the app icon, featuring a stylized \"O\" symbol that represents this fundamental computer science concept.")
                        
                        FAQItem(question: "What Is Time Complexity?", 
                                answer: "Time complexity describes how an algorithm's performance scales with input size, using Big O notation. Lower complexity means faster algorithms for large datasets.")
                        
                        FAQItem(question: "What's With The Bars?", 
                                answer: "Each bar represents a value in the array being sorted. Their heights are proportional to their values. As the algorithm runs, you can see how elements move and compare.")
                        
                        FAQItem(question: "What's With The Noises?", 
                                answer: "The audio provides an auditory representation of the sorting process. Different pitches correspond to different values, helping you 'hear' the sorting in progress.")
                        
                        FAQItem(question: "What's With The Sliders?", 
                                answer: "The array size slider controls how many elements to sort (10-100). The animation speed slider adjusts how fast the visualization runs (1x-20x). At 1x speed, there's a 0.5 second delay between steps, while at 20x the delay is reduced to just 0.025 seconds, making the sorting appear much faster.")
                        
                        FAQItem(question: "What Does Uniform Distribution Mean?", 
                                answer: "When enabled, values are distributed evenly across the possible range, forcing the bars to appear as a staircase. When disabled, values are randomly distributed, which can create more varied patterns to sort.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // Links section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Links")
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        HStack {
                            Text("Sorting Algorithms")
                            Spacer()
                            Link(destination: URL(string: "https://en.wikipedia.org/wiki/Sorting_algorithm")!) {
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            Text("Big O Notation")
                            Spacer()
                            Link(destination: URL(string: "https://www.bigocheatsheet.com/")!) {
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            Text("Found a bug? Report an issue")
                            Spacer()
                            Link(destination: URL(string: "https://github.com/ahl-gram/SortingVisualizerApp")!) {
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // Credits section - full width
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
                        
                        Text("© Alexander Lee - Route 12B Software")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 5)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
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

struct FAQItem: View {
    var question: String
    var answer: String
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                    HapticManager.shared.buttonTap()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview("Landscape", traits: .landscapeLeft) {
    AboutView(isPresented: .constant(true))
} 