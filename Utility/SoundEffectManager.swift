//
//  SoundEffectManager.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation
import AVFoundation

final class SoundEffectManager {

    // MARK: - Properties
    
    static let shared = SoundEffectManager()
    
    private var audioPlayer: AVAudioPlayer?

    private init() {}
    
    // MARK: - Enum for Sound Types
    
    enum SoundEffect: String {
        
        case select = "select"
        case correct = "correct"
        case incorrect = "incorrect"
        
        var fileExtension: String {
            return "wav"
        }
    }
    
    // MARK: - Public Methods
    
    func playSound(_ sound: SoundEffect) {
        guard let soundURL = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.fileExtension) else {
            print("Sound file not found: \(sound.rawValue).\(sound.fileExtension)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

