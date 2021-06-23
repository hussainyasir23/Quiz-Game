//
//  Question.swift
//  Quiz Game
//
//  Created by Mohammad on 22/06/21.
//

import UIKit

struct Question: Decodable {
    let response_code: Int
    let results: [response]
    
    init(){
        response_code = 0
        results = []
    }
}

struct response: Decodable{
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
