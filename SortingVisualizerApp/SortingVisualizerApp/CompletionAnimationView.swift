//
//  CompletionAnimationView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct CompletionAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .opacity(opacity)
            
            // Celebration text
            VStack {
                Text("Sorting Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .shadow(radius: 10)
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                
                // Confetti-like elements
                HStack(spacing: 20) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(colorForIndex(i))
                            .frame(width: 20, height: 20)
                            .offset(y: offsetForIndex(i))
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(i) * 0.1),
                                value: offsetForIndex(i)
                            )
                    }
                }
                .padding(.top, 20)
                .scaleEffect(scale)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                rotation = 5
            }
        }
    }
    
    private func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple]
        return colors[index % colors.count]
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        let baseOffset: CGFloat = -10
        return index % 2 == 0 ? baseOffset : 10
    }
}

#Preview {
    CompletionAnimationView()
} 