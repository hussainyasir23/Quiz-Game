//
//  UserAsnwer.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation

struct UserAnswer {
    let question: Question
    let selectedAnswer: String?
    
    var isAnswered: Bool {
        return selectedAnswer != nil
    }
    
    var isCorrect: Bool {
        return selectedAnswer == question.correctAnswer
    }
}
