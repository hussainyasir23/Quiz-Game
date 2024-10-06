//
//  SettingsManager.swift
//  Quiz Game
//
//  Created by Yasir on 06/10/24.
//

import Foundation

final class SettingsManager {
    
    static let shared = SettingsManager()
    
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Setting Enum
    
    enum Setting: String, CaseIterable {
        
        case sound = "soundEnabled"
        case volume = "soundVolume"
        case haptics = "hapticsEnabled"
        
        var defaultValue: Any {
            switch self {
            case .sound, .haptics: return true
            case .volume: return 1.0 as Float
            }
        }
    }
    
    // MARK: - Public Methods
    
    func saveSetting(_ value: Any, for setting: Setting) {
        userDefaults.set(value, forKey: setting.rawValue)
    }
    
    func loadSettings() {
        Setting.allCases.forEach { setting in
            
            if userDefaults.object(forKey: setting.rawValue) == nil {
                userDefaults.set(setting.defaultValue, forKey: setting.rawValue)
            }
            
            switch setting {
            case .sound:
                SoundEffectManager.shared.setSoundEnabled(bool(for: .sound))
            case .volume:
                SoundEffectManager.shared.setVolume(float(for: .volume))
            case .haptics:
                FeedbackManager.setHapticsEnabled(bool(for: .haptics))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func bool(for setting: Setting) -> Bool {
        return userDefaults.bool(forKey: setting.rawValue)
    }
    
    private func float(for setting: Setting) -> Float {
        return userDefaults.float(forKey: setting.rawValue)
    }
}
