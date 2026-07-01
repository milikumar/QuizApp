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
