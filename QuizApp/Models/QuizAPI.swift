//
//  QuizAPI.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/1/26.
//

import Foundation

struct TriviaAPIQuestion: Codable, Sendable {
    let question: QuestionText
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer
        case incorrectAnswers
    }
}

struct QuestionText: Codable, Sendable {
    let text: String
}

nonisolated
func categoryName(for name: String) -> String {
    switch name {
    case "General Knowledge": return "general_knowledge"
    case "Science & Nature": return "science"
    case "History": return "history"
    case "Geography": return "geography"
    case "Sports": return "sport_and_leisure"
    case "Movies & TV": return "film_and_tv"
    case "Food & Drink": return "food_and_drink"
    case "Technology": return "technology"
    case "Music": return "music"
    case "Animals": return "nature"
    default: return "general_knowledge"
    }
}

nonisolated
func fetchQuestions(for category: String, difficulty: String, completion: @escaping ([Question]?) -> Void) {
    let cat = categoryName(for: category)
    let diff = difficulty == "shuffle" ? "" : "&difficulties=\(difficulty)"
    let urlString = "https://the-trivia-api.com/v2/questions?limit=10&categories=\(cat)\(diff)"
    
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
            let decoded = try JSONDecoder().decode([TriviaAPIQuestion].self, from: data)
            let questions = decoded.map { q in
                var options = q.incorrectAnswers
                options.append(q.correctAnswer)
                options.shuffle()
                return Question(
                    text: q.question.text,
                    options: options.map { $0.htmlDecoded },
                    correctAnswer: q.correctAnswer.htmlDecoded
                )
            }
            completion(questions)
        } catch {
            completion(nil)
        }
    }.resume()
}
