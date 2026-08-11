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

func fetchQuestions(
    for category: String,
    difficulty: String,
    completion: @escaping (_ questions: [Question]?, _ isOffline: Bool) -> Void
) {
    let id = categoryID(for: category)
    let diff = difficulty == "shuffle" ? "" : "&difficulty=\(difficulty)"
    let urlString = "https://opentdb.com/api.php?amount=10&category=\(id)&type=multiple\(diff)"
    
    guard let url = URL(string: urlString) else {
        completion(nil, false)
        return
    }
    
    requestQuestions(from: url, retriesRemaining: 3, completion: completion)
}

private func requestQuestions(
    from url: URL,
    retriesRemaining: Int,
    completion: @escaping (_ questions: [Question]?, _ isOffline: Bool) -> Void
) {
    let delay = TriviaRequestLimiter.reserveDelay()
    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(nil, isOfflineNetworkError(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, false)
                return
            }

            if response.statusCode == 429, retriesRemaining > 0 {
                requestQuestions(from: url, retriesRemaining: retriesRemaining - 1, completion: completion)
                return
            }

            guard (200..<300).contains(response.statusCode), let data else {
                // The device may be online even when the trivia service is unavailable.
                completion(nil, false)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
                if decoded.responseCode == 5, retriesRemaining > 0 {
                    // Open Trivia DB limits each IP to one request every five seconds.
                    requestQuestions(from: url, retriesRemaining: retriesRemaining - 1, completion: completion)
                    return
                }

                guard decoded.responseCode == 0 else {
                    completion(nil, false)
                    return
                }

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
                completion(questions.count == 10 ? questions : nil, false)
            } catch {
                // A malformed or rate-limited API response is not an offline device.
                completion(nil, false)
            }
        }.resume()
    }
}

private func isOfflineNetworkError(_ error: Error) -> Bool {
    guard let urlError = error as? URLError else { return false }
    return urlError.code == .notConnectedToInternet
}

struct TriviaResponse: Codable, Sendable {
    let responseCode: Int
    let results: [TriviaQuestion]

    private enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Codable, Sendable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

private enum TriviaRequestLimiter {
    private static let minimumInterval: TimeInterval = 5.1
    private static let lock = NSLock()
    private static var nextRequestDate = Date.distantPast

    static func reserveDelay() -> TimeInterval {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        let scheduledDate = max(now, nextRequestDate)
        nextRequestDate = scheduledDate.addingTimeInterval(minimumInterval)
        return scheduledDate.timeIntervalSince(now)
    }
}
