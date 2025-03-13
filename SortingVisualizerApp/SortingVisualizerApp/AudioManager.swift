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
    private var outputFormat: AVAudioFormat
    
    init() {
        audioEngine = AVAudioEngine()
        tonePlayer = AVAudioPlayerNode()
        mixer = audioEngine.mainMixerNode
        
        // Get the output format from the mixer
        outputFormat = mixer.outputFormat(forBus: 0)
        
        audioEngine.attach(tonePlayer)
        audioEngine.connect(tonePlayer, to: mixer, format: outputFormat)
        
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
        let sampleRate = Float(outputFormat.sampleRate)
        let duration: Float = 0.1 // 100ms tone
        
        let buffer = createToneBuffer(frequency: frequency, duration: duration)
        
        // Play the tone
        tonePlayer.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        
        if !tonePlayer.isPlaying {
            tonePlayer.play()
        }
    }
    
    private func createToneBuffer(frequency: Float, duration: Float) -> AVAudioPCMBuffer {
        let sampleRate = Float(outputFormat.sampleRate)
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        // Use the same format as the mixer's output
        let buffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        
        let omega = 2.0 * Float.pi * frequency / sampleRate
        let channelCount = Int(outputFormat.channelCount)
        
        // Fill the buffer with a sine wave for all channels
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
            
            // Fill all channels with the same value
            for channel in 0..<channelCount {
                buffer.floatChannelData?[channel][frame] = value * amplitude
            }
        }
        
        return buffer
    }
    
    func setAudioEnabled(_ enabled: Bool) {
        isAudioEnabled = enabled
        
        if !enabled && tonePlayer.isPlaying {
            tonePlayer.stop()
        }
    }
    
    func cleanup() {
        tonePlayer.stop()
        audioEngine.stop()
        audioEngine.detach(tonePlayer)
    }
} 