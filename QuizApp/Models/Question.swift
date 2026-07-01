//
//  Question.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/29/26.
//

import Foundation
struct Question {
    let text: String
    let options: [String]
    let correctAnswer: String
}
struct QuestionSet {
    let name: String
    let questions: [Question]
}
extension String {
    var htmlDecoded: String {
        var result = self
        let replacements = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#039;": "'",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&lsquo;": "\u{2018}",
            "&rsquo;": "\u{2019}"
        ]
        for (key, value) in replacements {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }
}
