//
//  QuestionType.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

enum QuestionType: String, CaseIterable {
    case any = ""
    case multiple = "multiple"
    case boolean = "boolean"
    
    var displayName: String {
        switch self {
        case .any: return "Any"
        case .multiple: return "MCQ"
        case .boolean: return "True / False"
        }
    }
}
