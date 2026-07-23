//
//  QuizAPI.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/1/26.
//

import Foundation
import Combine

func categoryID(for name: String) -> Int {
    switch name {
    case "General Knowledge": return 9
    case "Books": return 10
    case "Movies & TV": return 11
    case "Music": return 12
    case "Television": return 14
    case "Video Games": return 15
    case "Board Games": return 16
    case "Science & Nature": return 17
    case "Technology": return 18
    case "Mythology": return 20
    case "Sports": return 21
    case "Geography": return 22
    case "History": return 23
    case "Art": return 25
    case "Celebrities": return 26
    case "Animals": return 27
    case "Vehicles": return 28
    case "Comics": return 29
    case "Gadgets": return 30
    case "Anime & Manga": return 31
    case "Cartoons": return 32
    default: return 9
    }
}

func fetchQuestions(for category: String, difficulty: String, completion: @escaping ([Question]?) -> Void) {
    let id = categoryID(for: category)
    let diff = difficulty == "shuffle" ? "" : "&difficulty=\(difficulty)"
    let urlString = "https://opentdb.com/api.php?amount=10&category=\(id)&type=multiple\(diff)"
    
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            let questions = decoded.results.map { q in
                var options = q.incorrect_answers
                options.append(q.correct_answer)
                options.shuffle()
                return Question(
                    text: q.question.htmlDecoded,
                    options: options.map { $0.htmlDecoded },
                    correctAnswer: q.correct_answer.htmlDecoded
                )
            }
            completion(questions)
        } catch {
            completion(nil)
        }
    }.resume()
}

struct TriviaResponse: Codable, Sendable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Sendable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
