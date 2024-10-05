//
//  SoundEffectManager.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import AVFoundation

final class SoundEffectManager {
    
    // MARK: - Properties
    
    static let shared = SoundEffectManager()
    
    private var audioPlayers: [SoundEffect: [AVAudioPlayer]] = [:]
    private var volume: Float = 1.0
    private let maxConcurrentPlayers = 3
    private let audioQueue = DispatchQueue(label: "com.soundEffectManager.audioQueue", attributes: .concurrent)
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Enum for Sound Types
    
    enum SoundEffect: String, CaseIterable {
        case select
        case correct
        case incorrect
        
        var fileName: String {
            return rawValue
        }
        
        var fileExtension: String {
            return "wav"
        }
    }
    
    // MARK: - Public Methods
    
    func playSound(_ sound: SoundEffect) {
        audioQueue.async {
            if let availablePlayer = self.getAvailablePlayer(for: sound) {
                availablePlayer.volume = self.volume
                availablePlayer.play()
            } else {
                self.createNewPlayer(for: sound)?.play()
            }
        }
    }
    
    func stopSound(_ sound: SoundEffect) {
        audioQueue.async {
            self.audioPlayers[sound]?.forEach { $0.stop() }
        }
    }
    
    func stopAllSounds() {
        audioQueue.async {
            self.audioPlayers.values.flatMap { $0 }.forEach { $0.stop() }
        }
    }
    
    func setVolume(_ volume: Float) {
        audioQueue.async(flags: .barrier) {
            self.volume = max(0.0, min(1.0, volume))
            self.audioPlayers.values.flatMap { $0 }.forEach { $0.volume = self.volume }
        }
    }
    
    func preloadSounds() {
        SoundEffect.allCases.forEach { sound in
            for _ in 0..<maxConcurrentPlayers {
                _ = createNewPlayer(for: sound)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    private func getAvailablePlayer(for sound: SoundEffect) -> AVAudioPlayer? {
        var player: AVAudioPlayer?
        audioQueue.sync {
            player = self.audioPlayers[sound]?.first(where: { !$0.isPlaying })
        }
        return player
    }
    
    private func createNewPlayer(for sound: SoundEffect) -> AVAudioPlayer? {
        guard let soundURL = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) else {
            print("Sound file not found: \(sound.fileName).\(sound.fileExtension)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            player.volume = volume
            
            audioQueue.async(flags: .barrier) {
                if self.audioPlayers[sound] == nil {
                    self.audioPlayers[sound] = []
                }
                
                if var players = self.audioPlayers[sound], players.count < self.maxConcurrentPlayers {
                    players.append(player)
                    self.audioPlayers[sound] = players
                } else {
                    self.audioPlayers[sound]?.removeFirst()
                    self.audioPlayers[sound]?.append(player)
                }
            }
            
            return player
        } catch {
            print("Failed to load sound \(sound.rawValue): \(error.localizedDescription)")
            return nil
        }
    }
}

