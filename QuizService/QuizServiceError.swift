//
//  QuizServiceError.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

enum QuizServiceError: Error {
    case invalidURL
    case noResults
    case invalidParameter
    case tokenNotFound
    case tokenEmpty
    case rateLimit
    case unknown(Int)
}
