//
//  ResultsViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation

class ResultsViewModel {
    
    private let userAnswers: [UserAnswer]
    private let totalTime: TimeInterval
    
    var score: Int {
        return userAnswers.filter { $0.isCorrect }.count
    }
    
    var numberOfQuestions: Int {
        return userAnswers.count
    }
    
    var scoreText: String {
        return "\(score)/\(numberOfQuestions)"
    }
    
    var percentage: Double {
        return Double(score) / Double(numberOfQuestions)
    }
    
    var messageText: String {
        switch percentage {
        case 0.8...1.0:
            return "Excellent! You're a quiz master!"
        case 0.6..<0.8:
            return "Great job! You're doing well!"
        case 0.4..<0.6:
            return "Good effort! Keep practicing!"
        default:
            return "Keep trying! You'll improve with practice."
        }
    }
    
    var shouldShowConfetti: Bool {
        return percentage >= 0.8
    }
    
    var shareMessage: String {
        return String(format: "I scored %d out of %d in the Quiz Game!", score, numberOfQuestions)
    }
    
    init(userAnswers: [UserAnswer], totalTime: TimeInterval) {
        self.userAnswers = userAnswers
        self.totalTime = totalTime
    }
    
    func userAnswer(at index: Int) -> UserAnswer {
        return userAnswers[index]
    }
}
