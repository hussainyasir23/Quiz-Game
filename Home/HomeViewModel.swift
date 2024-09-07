//
//  HomeViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var highScore: Int = 0
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadHighScore()
    }
    
    func loadHighScore() {
        highScore = userDefaults.integer(forKey: Constants.UserDefaults.highScore)
    }
    
    func updateHighScore(_ score: Int) {
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: Constants.UserDefaults.highScore)
        }
    }
}
