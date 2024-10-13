//
//  QuizService.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation
import Combine

class QuizService: QuizServiceProtocol {
    
    private let baseURL = "https://opentdb.com/api.php"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getSessionToken() -> AnyPublisher<String, Error> {
        
        let url = URL(string: "https://opentdb.com/api_token.php?command=request")!
        
        return urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SessionTokenResponse.self, decoder: JSONDecoder())
            .map(\.token)
            .eraseToAnyPublisher()
    }
    
    func resetSessionToken(_ token: String) -> AnyPublisher<Void, Error> {
        
        let url = URL(string: "https://opentdb.com/api_token.php?command=reset&token=\(token)")!
        
        return urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SessionTokenResponse.self, decoder: JSONDecoder())
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func fetchQuiz(amount: Int, category: Category?, difficulty: Difficulty?, type: QuestionType?) -> AnyPublisher<Quiz, Error> {
        
        var urlComponents = URLComponents(string: baseURL)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "amount", value: String(amount))
        ]
        
        if let category = category, category != .any {
            urlComponents.queryItems?.append(URLQueryItem(name: "category", value: String(category.rawValue)))
        }
        
        if let difficulty = difficulty, difficulty != .any {
            urlComponents.queryItems?.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        
        if let type = type, type != .any {
            urlComponents.queryItems?.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        
        guard let url = urlComponents.url else {
            return Fail(error: QuizServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: QuizAPIResponse.self, decoder: JSONDecoder())
            .tryMap { response -> Quiz in
                switch response.responseCode {
                case 0:
                    return Quiz(from: response)
                case 1:
                    throw QuizServiceError.noResults
                case 2:
                    throw QuizServiceError.invalidParameter
                case 3:
                    throw QuizServiceError.tokenNotFound
                case 4:
                    throw QuizServiceError.tokenEmpty
                case 5:
                    throw QuizServiceError.rateLimit
                default:
                    throw QuizServiceError.unknown(response.responseCode)
                }
            }
            .eraseToAnyPublisher()
    }
}
