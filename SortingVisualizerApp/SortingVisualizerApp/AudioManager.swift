//
//  AudioManager.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import AVFoundation

class AudioManager {
    private var audioEngine: AVAudioEngine
    private var tonePlayer: AVAudioPlayerNode
    private var mixer: AVAudioMixerNode
    private var isAudioEnabled: Bool = true
    
    init() {
        audioEngine = AVAudioEngine()
        tonePlayer = AVAudioPlayerNode()
        mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(tonePlayer)
        audioEngine.connect(tonePlayer, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start audio engine: \(error.localizedDescription)")
            isAudioEnabled = false
        }
    }
    
    func playTone(forValue value: Int) {
        guard isAudioEnabled else { return }
        
        // Calculate frequency based on the bar's height/value
        // Higher values produce higher pitches
        let baseFrequency: Float = 220.0 // A3 note
        let maxValue: Float = 200.0 // Maximum possible value
        let normalizedValue = Float(value) / maxValue
        let frequency = baseFrequency + (normalizedValue * 880.0) // Range from A3 to A5
        
        // Create a short tone
        let audioFormat = mixer.outputFormat(forBus: 0)
        let sampleRate = Float(audioFormat.sampleRate)
        let duration: Float = 0.1 // 100ms tone
        
        let buffer = createToneBuffer(frequency: frequency, duration: duration, sampleRate: sampleRate)
        
        // Play the tone
        tonePlayer.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        tonePlayer.play()
    }
    
    private func createToneBuffer(frequency: Float, duration: Float, sampleRate: Float) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let omega = 2.0 * Float.pi * frequency / sampleRate
        
        // Fill the buffer with a sine wave
        for frame in 0..<Int(frameCount) {
            let value = sin(omega * Float(frame))
            
            // Apply a simple envelope to avoid clicks
            var amplitude: Float = 0.5
            let attackReleaseSamples = Int(0.01 * sampleRate) // 10ms attack/release
            
            if frame < attackReleaseSamples {
                // Attack phase
                amplitude *= Float(frame) / Float(attackReleaseSamples)
            } else if frame > Int(frameCount) - attackReleaseSamples {
                // Release phase
                amplitude *= Float(Int(frameCount) - frame) / Float(attackReleaseSamples)
            }
            
            buffer.floatChannelData?[0][frame] = value * amplitude
        }
        
        return buffer
    }
    
    func setAudioEnabled(_ enabled: Bool) {
        isAudioEnabled = enabled
    }
    
    func cleanup() {
        tonePlayer.stop()
        audioEngine.stop()
        audioEngine.detach(tonePlayer)
    }
} 