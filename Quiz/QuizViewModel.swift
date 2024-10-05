//
//  QuizViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class QuizViewModel: ObservableObject {
    
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var currentQuestionIndex: Int = -1
    @Published private(set) var score: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var timeRemaining: Int = 15
    @Published private(set) var shouldPlayTimerSound: Bool = false
    
    private let quiz: Quiz
    private var timer: AnyCancellable?
    private var startTime: Date?
    private(set) var totalTime: TimeInterval = 0
    private(set) var userAnswers: [UserAnswer] = []
    
    var totalQuestions: Int {
        return quiz.questions.count
    }
    
    init(quiz: Quiz) {
        self.quiz = quiz
    }
    
    func startGame() {
        startTime = Date()
        currentQuestionIndex = -1
        score = 0
        isGameOver = false
        timeRemaining = 15
        shouldPlayTimerSound = false
        setNextQuestion()
    }
    
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            shouldPlayTimerSound = timeRemaining <= 5
        } else {
            answerSelected(nil)
        }
    }
    
    func answerSelected(_ answer: String?) {
        timer?.cancel()
        if let currentQuestion = currentQuestion {
            let userAnswer = UserAnswer(question: currentQuestion, selectedAnswer: answer)
            userAnswers.append(userAnswer)
            if userAnswer.isCorrect {
                score += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.setNextQuestion()
        }
    }
    
    private func setNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < quiz.questions.count {
            currentQuestion = quiz.questions[currentQuestionIndex]
            timeRemaining = 15
            shouldPlayTimerSound = false
            startTimer()
        } else {
            endGame()
        }
    }
    
    private func endGame() {
        isGameOver = true
        timer?.cancel()
        if let startTime = startTime {
            totalTime = Date().timeIntervalSince(startTime)
        }
    }
}
