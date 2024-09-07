//
//  NewGameViewModel.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class NewGameViewModel: ObservableObject {
    
    @Published var categories: [Category] = Category.allCases
    @Published var difficulties: [Difficulty] = Difficulty.allCases
    @Published var questionTypes: [QuestionType] = QuestionType.allCases
    @Published var questionCountsMin: Int = 1
    @Published var questionCountsMax: Int = 50
    
    @Published var selectedCategory: Category = .any
    @Published var selectedDifficulty: Difficulty = .any
    @Published var selectedQuestionType: QuestionType = .any
    @Published var selectedQuestionCount: Int = 10
    
    private let quizService: QuizServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(quizService: QuizServiceProtocol = QuizService()) {
        self.quizService = quizService
    }
    
    func startQuiz() -> AnyPublisher<Quiz, Error> {
        return quizService.fetchQuiz(
            amount: selectedQuestionCount,
            category: selectedCategory == .any ? nil : selectedCategory,
            difficulty: selectedDifficulty == .any ? nil : selectedDifficulty,
            type: selectedQuestionType == .any ? nil : selectedQuestionType
        )
    }
}
