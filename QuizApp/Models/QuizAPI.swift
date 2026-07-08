//
//  QuizAPI.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/1/26.
//

import Foundation

struct TriviaResponse: Codable, Sendable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Sendable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

nonisolated
func categoryID(for name: String) -> Int {
    switch name {
    case "General Knowledge": return 9
    case "Science & Nature": return 17
    case "History": return 23
    case "Geography": return 22
    case "Sports": return 21
    case "Movies & TV": return 11
    case "Food & Drink": return 25
    case "Technology": return 18
    case "Music": return 12
    case "Animals": return 27
    default: return 9
    }
}

nonisolated
func fetchQuestions(for category: String, difficulty: String, completion: @escaping ([Question]?) -> Void) {
    let id = categoryID(for: category)
    let urlString = "https://opentdb.com/api.php?amount=10&category=\(id)&type=multiple&difficulty=\(difficulty)"
    
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
