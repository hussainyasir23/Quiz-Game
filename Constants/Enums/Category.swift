//
//  Category.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import Foundation

enum Category: Int, CaseIterable {
    case anyCategory = 0
    case generalKnowledge = 9
    case books = 10
    case film = 11
    case music = 12
    case musicalsTheatres = 13
    case television = 14
    case videoGames = 15
    case boardGames = 16
    case scienceNature = 17
    case computers = 18
    case mathematics = 19
    case mythology = 20
    case sports = 21
    case geography = 22
    case history = 23
    case politics = 24
    case art = 25
    case celebrities = 26
    case animals = 27
    case vehicles = 28
    case comics = 29
    case gadgets = 30
    case animeManac = 31
    case cartoonAnimations = 32
    
    var name: String {
        switch self {
        case .anyCategory: return "Any Category"
        case .generalKnowledge: return "General Knowledge"
        case .books: return "Entertainment: Books"
        case .film: return "Entertainment: Film"
        case .music: return "Entertainment: Music"
        case .musicalsTheatres: return "Entertainment: Musicals & Theatres"
        case .television: return "Entertainment: Television"
        case .videoGames: return "Entertainment: Video Games"
        case .boardGames: return "Entertainment: Board Games"
        case .scienceNature: return "Science & Nature"
        case .computers: return "Science: Computers"
        case .mathematics: return "Science: Mathematics"
        case .mythology: return "Mythology"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        case .politics: return "Politics"
        case .art: return "Art"
        case .celebrities: return "Celebrities"
        case .animals: return "Animals"
        case .vehicles: return "Vehicles"
        case .comics: return "Entertainment: Comics"
        case .gadgets: return "Science: Gadgets"
        case .animeManac: return "Entertainment: Japanese Anime & Manga"
        case .cartoonAnimations: return "Entertainment: Cartoon & Animations"
        }
    }
}
