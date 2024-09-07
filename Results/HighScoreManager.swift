//
//  HighScoreManager.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

class HighScoreManager {
    static let shared = HighScoreManager()
    
    private let userDefaults = UserDefaults.standard
    private let highScoreKey = "HighScore"
    
    private init() {}
    
    func getHighScore() -> Int {
        return userDefaults.integer(forKey: highScoreKey)
    }
    
    func setHighScore(_ score: Int) {
        let currentHighScore = getHighScore()
        if score > currentHighScore {
            userDefaults.set(score, forKey: highScoreKey)
        }
    }
}
