//
//  UserAsnwer.swift
//  Quiz Game
//
//  Created by Yasir on 05/10/24.
//

import Foundation
import UIKit

struct UserAnswer {
    let question: Question
    let selectedAnswer: String?
    
    var isAnswered: Bool {
        return selectedAnswer != nil
    }
    
    var isCorrect: Bool {
        return selectedAnswer == question.correctAnswer
    }
    
    var resultImage: UIImage? {
        if isAnswered {
            if isCorrect {
                return UIImage(systemName: "checkmark.circle.fill")
            } else {
                return UIImage(systemName: "xmark.circle.fill")
            }
        } else {
            return UIImage(systemName: "hourglass.bottomhalf.fill")
        }
    }
    
    var resultTintColor: UIColor {
        if isAnswered {
            if isCorrect {
                return .systemGreen
            } else {
                return .systemRed
            }
        } else {
            return .systemOrange
        }
    }
}
