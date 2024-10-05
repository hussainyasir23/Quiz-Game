//
//  HomeViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published private(set) var highScore: Int = 0
    
    private let highScoreManager: HighScoreManager
    private let quizService: QuizServiceProtocol
    
    init(highScoreManager: HighScoreManager = .shared, quizService: QuizServiceProtocol = QuizService()) {
        self.highScoreManager = highScoreManager
        self.quizService = quizService
        loadHighScore()
    }
    
    func loadHighScore() {
        highScore = highScoreManager.getHighScore()
    }
    
    func createQuizConfiguratorViewModel() -> QuizConfiguratorViewModel {
        return QuizConfiguratorViewModel(quizService: quizService)
    }
}
