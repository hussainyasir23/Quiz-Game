//
//  QuizServiceProtocol.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

protocol QuizServiceProtocol {
    func getSessionToken() -> AnyPublisher<String, Error>
    func resetSessionToken(_ token: String) -> AnyPublisher<Void, Error>
    func fetchQuiz(amount: Int, category: Category?, difficulty: Difficulty?, type: QuestionType?) -> AnyPublisher<Quiz, Error>
}
