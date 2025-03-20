import SwiftUI

struct ControlPanelLayout: View {
    @Binding var arraySize: Double
    @Binding var animationSpeed: Double
    @Binding var isAudioEnabled: Bool
    @Binding var isUniformDistribution: Bool
    @Binding var selectedAlgorithm: SortingAlgorithmType
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    // Track previous values for sliders to determine when to trigger haptics
    @State private var previousArraySize: Double = 50
    @State private var previousAnimationSpeed: Double = 1.0
    
    private func hapticRandomize() {
        HapticManager.shared.mediumImpact()
        onRandomize()
    }
    
    private func hapticStartSorting() {
        HapticManager.shared.mediumImpact()
        onStartSorting()
    }
    
    private func hapticStopSorting() {
        HapticManager.shared.mediumImpact()
        onStopSorting()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) {
                HStack(alignment: .top, spacing: 10) {
                    // Left column - algorithm picker, description, and buttons
                    VStack(alignment: .leading) {
                        // Algorithm Picker - Dropdown style
                        HStack {
                            Text("Algorithm:")
                                .opacity(isSorting ? 0.5 : 1)
                            Spacer()
                            
                            // Create a custom picker display to show selected algorithm in blue
                            Menu {
                                ForEach(SortingAlgorithmType.allCases.sorted(by: { $0.rawValue > $1.rawValue })) { algorithm in
                                    Button(action: {
                                        selectedAlgorithm = algorithm
                                        HapticManager.shared.buttonTap()
                                    }) {
                                        Text(algorithm.rawValue)
                                        if selectedAlgorithm == algorithm {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedAlgorithm.rawValue)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 180)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                            }
                            .disabled(isSorting)
                            .opacity(isSorting ? 0.5 : 1)
                            .accessibilityLabel("Algorithm Selector")
                        }
                        .padding(.bottom, 2)
                        
                        // Algorithm Description
                        ScrollView {
                            Text(selectedAlgorithm.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 3)
                                .accessibilityLabel("Algorithm Description")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 100)
                        .accessibilityLabel("Scrollable Algorithm Description")
                        
                        // Randomize and Start/Stop Buttons
                        HStack(spacing: 10) {
                            // Randomize Button
                            Button(action: hapticRandomize) {
                                Text("Randomize")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(AppConstants.UI.cornerRadius)
                            }
                            .disabled(isSorting)
                            .opacity(isSorting ? 0.5 : 1)
                            .accessibilityLabel("Randomize Button")
                            
                            // Start/Stop Sorting Button
                            if isSorting {
                                Button(action: hapticStopSorting) {
                                    Text("Stop")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(AppConstants.UI.cornerRadius)
                                }
                                .accessibilityLabel("Stop Button")
                            } else {
                                Button(action: hapticStartSorting) {
                                    Text("Start")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(AppConstants.UI.cornerRadius)
                                }
                                .accessibilityLabel("Start Button")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right column - sliders and audio toggle
                    VStack(alignment: .leading) {
                        // Array Size Slider
                        HStack {
                            Text("📶")
                                .opacity(isSorting ? 0.5 : 1)
                            Slider(value: $arraySize, in: 10...100, step: 1)
                                .accessibilityLabel("Array Size Slider")
                                .disabled(isSorting)
                                .opacity(isSorting ? 0.5 : 1)
                                .onChange(of: arraySize) { _, newValue in
                                    previousArraySize = newValue
                                }
                            Text("\(Int(arraySize))")
                                .frame(width: 40, alignment: .trailing)
                                .opacity(isSorting ? 0.5 : 1)
                        }
                        .padding(.bottom, geometry.size.height/16)
                        
                        // Animation Speed Slider
                        HStack {
                            Text("⏩")
                                 .opacity(isSorting ? 0.5 : 1)
                            Slider(value: $animationSpeed, in: AppConstants.Animation.minAnimationSpeed...AppConstants.Animation.maxAnimationSpeed, step: 1)
                                .accessibilityLabel("Animation Speed Slider")
                                .disabled(isSorting)
                                .opacity(isSorting ? 0.5 : 1)
                                .onChange(of: animationSpeed) { _, newValue in
                                    previousAnimationSpeed = newValue
                                }
                            Text("\(Int(animationSpeed))x")
                                .frame(width: 40, alignment: .trailing)
                                .opacity(isSorting ? 0.5 : 1)
                        }
                        .padding(.bottom, geometry.size.height/16)
                        
                        // Audio Toggle
                        Toggle(isOn: $isAudioEnabled) {
                            Text("Sound Effects")
                                .padding(.trailing, 15)
                        }
                        .accessibilityLabel("Sound Effects Toggle")
                        .padding(.bottom, geometry.size.height/16)

                        // Distribution Toggle
                        Toggle(isOn: $isUniformDistribution) {
                            Text("Uniform Distribution")
                                .padding(.trailing, 15)
                                .opacity(isSorting ? 0.5 : 1)
                        }
                        .disabled(isSorting)
                        .accessibilityLabel("Distribution Toggle")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    ControlPanelPreviewWrapper(width: 700, height: 200, previewLayout: false)
}
