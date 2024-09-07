//
//  GameViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var timeRemaining: Int = 15  // 15 seconds per question
    
    private var quiz: Quiz
    private var timer: AnyCancellable?
    private var startTime: Date?
    private(set) var totalTime: TimeInterval = 0
    
    var totalQuestions: Int {
        return quiz.questions.count
    }
    
    init(quiz: Quiz) {
        self.quiz = quiz
        setNextQuestion()
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func startGame() {
        startTime = Date()
        setNextQuestion()
    }
    
    private func endGame() {
        isGameOver = true
        if let startTime = startTime {
            totalTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            answerSelected(nil)  // Time's up, treat as wrong answer
        }
    }
    
    func answerSelected(_ answer: String?) {
        timer?.cancel()
        
        if let currentQuestion = currentQuestion {
            if answer == currentQuestion.correctAnswer {
                score += 1
            }
        }
        
        setNextQuestion()
    }
    
    private func setNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < quiz.questions.count {
            currentQuestion = quiz.questions[currentQuestionIndex]
            timeRemaining = 15
            startTimer()
        } else {
            isGameOver = true
        }
        if currentQuestionIndex >= quiz.questions.count {
            endGame()
        }
    }
}
