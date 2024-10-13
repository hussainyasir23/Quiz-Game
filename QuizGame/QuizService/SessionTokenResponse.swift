//
//  SessionTokenResponse.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

struct SessionTokenResponse: Decodable {
    let responseCode: Int
    let responseMessage: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case responseMessage = "response_message"
        case token
    }
}
