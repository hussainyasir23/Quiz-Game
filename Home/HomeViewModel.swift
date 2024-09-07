//
//  HomeViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var highScore: Int = 0
    @Published var categories: [Category] = Category.allCases
    @Published var difficulties: [Difficulty] = Difficulty.allCases
    @Published var questionTypes: [QuestionType] = QuestionType.allCases
    
    private let userDefaults: UserDefaults
    private let quizService: QuizServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(userDefaults: UserDefaults = .standard, quizService: QuizServiceProtocol = QuizService()) {
        self.userDefaults = userDefaults
        self.quizService = quizService
        loadHighScore()
    }
    
    func loadHighScore() {
        highScore = userDefaults.integer(forKey: "highScore")
    }
    
    func updateHighScore(_ score: Int) {
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: "highScore")
        }
    }
    
    func createNewGameViewModel() -> NewGameViewModel {
        return NewGameViewModel(quizService: quizService)
    }
}
