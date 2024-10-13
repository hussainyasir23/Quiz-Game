//
//  Quiz.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

struct Quiz {
    let questions: [Question]
}

extension Quiz {
    init(from apiResponse: QuizAPIResponse) {
        self.questions = apiResponse.results.map { Question(from: $0) }
    }
}

struct QuizAPIResponse: Decodable {
    let responseCode: Int
    let results: [QuestionAPIResponse]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}
