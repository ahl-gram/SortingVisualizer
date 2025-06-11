# Sorting Visualizer

A SwiftUI-based iOS application built with Cursor that provides an interactive and educational visualization of various sorting algorithms with real-time animation and audio feedback.

## Features

- **Multiple Sorting Algorithms**: Visualize 12 different sorting algorithms:
  - Bubble Sort (O(n²))
  - Quick Sort (O(n log n))
  - Merge Sort (O(n log n))
  - Insertion Sort (O(n²))
  - Heap Sort (O(n log n))
  - Radix Sort (O(nk))
  - Time Sort (hybrid algorithm, O(n log n))
  - Bucket Sort (O(n+k))
  - Selection Sort (O(n²))
  - Shell Sort (O(n (log n)²))
  - Cube Sort (O(n log n))
  - Bogo Sort (O(n!))


- **Interactive Controls**:
  - Adjust array size (10-100 elements) with a slider
  - Control animation speed (1x-20x) for faster or slower visualization
  - Toggle audio feedback on/off
  - Choose between uniform and non-uniform data distribution
  - Start, stop, and randomize arrays at any time

- **Real-time Visualization**:
  - Color-coded bars show the sorting process in action
  - See comparisons, swaps, and sorted elements with distinct visual feedback
  - Watch how each algorithm approaches the sorting problem differently

- **Audio Feedback**:
  - Hear tones that correspond to the values being compared and sorted
  - Audio pitch changes based on bar height for intuitive feedback
  - Celebratory sound effect when sorting is complete

- **Modern UI/UX**:
  - Clean, responsive interface optimized for landscape orientation
  - Dynamic Island support on newer iPhones
  - Proper handling of safe areas across all iOS devices
  - Informative algorithm descriptions for each sorting method
  - Completion animation that highlights the sorted array

- **Educational Value**:
  - Compare algorithm efficiency in real-time
  - Understand how each algorithm approaches the sorting problem
  - Visualize algorithm complexity with different array sizes

## Requirements

- iOS 17.6+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `SortingVisualizerApp.xcodeproj` in Xcode
3. Build and run the app on your device or simulator (landscape orientation)

## Usage

1. Launch the app in landscape orientation
2. Choose a sorting algorithm from the dropdown menu
3. Use the "Array Size" slider to adjust the number of elements
4. Use the "Animation Speed" slider to control the visualization speed
5. Toggle audio feedback and distribution type as desired
6. Press "Randomize Array" to generate a new random array
7. Press "Start Sorting" to begin the visualization
8. Press "Stop Sorting" at any time to interrupt the sorting process

## License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License

## Acknowledgments

- Created as part of a SwiftUI learning project
- Inspired by various sorting visualization tools
- Designed to make learning about sorting algorithms engaging and interactive 
