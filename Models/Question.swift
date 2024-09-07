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
        self.category = apiResponse.category.decodedHTMLString
        self.type = QuestionType(rawValue: apiResponse.type) ?? .multiple
        self.difficulty = Difficulty(rawValue: apiResponse.difficulty.lowercased()) ?? .medium
        self.question = apiResponse.question.decodedHTMLString
        self.correctAnswer = apiResponse.correctAnswer.decodedHTMLString
        self.incorrectAnswers = apiResponse.incorrectAnswers.map { $0.decodedHTMLString }
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

extension String {
    var decodedHTMLString: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributedString.string
    }
}
