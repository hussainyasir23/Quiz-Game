//
//  Question.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

struct Question {
    let category: String
    let type: QuestionType
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
}

extension Question {
    init(from apiResponse: QuestionAPIResponse) {
        self.category = apiResponse.category
        self.type = QuestionType(rawValue: apiResponse.type) ?? .any
        self.difficulty = Difficulty(rawValue: apiResponse.difficulty.lowercased()) ?? .any
        self.question = apiResponse.question
        self.correctAnswer = apiResponse.correctAnswer
        self.incorrectAnswers = apiResponse.incorrectAnswers
    }
}

struct QuestionAPIResponse: Decodable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
