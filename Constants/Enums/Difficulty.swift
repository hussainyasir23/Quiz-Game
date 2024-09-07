//
//  Difficulty.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

enum Difficulty: String, CaseIterable {
    case any = ""
    case easy
    case medium
    case hard
    
    var displayName: String {
        switch self {
        case .any: return "Any Difficulty"
        default: return rawValue.capitalized
        }
    }
}
