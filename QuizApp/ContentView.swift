//
//  ContentView.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import SwiftUI

struct Question {
    let text: String
    let options: [String]
    let correctAnswer: String
}

struct ContentView: View {
    
    let questions: [Question] = [
        Question(text: "What is the capital of France?",
                 options: ["London", "Berlin", "Paris", "Madrid"],
                 correctAnswer: "Paris"),
        Question(text: "How many planets are in our solar system?",
                 options: ["7", "8", "9", "10"],
                 correctAnswer: "8"),
        Question(text: "Which animal is the fastest on land?",
                 options: ["Lion", "Horse", "Cheetah", "Greyhound"],
                 correctAnswer: "Cheetah"),
        Question(text: "What is the capital of Australia?",
                    options: ["Sydney", "Melbourne", "Canberra", "Brisbane"],
                    correctAnswer: "Canberra"),
        Question(text: "How many bones are in the human body?",
                    options: ["196", "206", "216", "226"],
                    correctAnswer: "206"),
        Question(text: "What is the largest ocean on Earth?",
                    options: ["Atlantic", "Indian", "Arctic", "Pacific"],
                    correctAnswer: "Pacific"),
        Question(text: "Which planet has the most moons?",
                    options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
                    correctAnswer: "Saturn"),
        Question(text: "What year did World War II end?",
                    options: ["1943", "1944", "1945", "1946"],
                    correctAnswer: "1945"),
        Question(text: "What is the chemical symbol for gold?",
                    options: ["Go", "Gd", "Au", "Ag"],
                    correctAnswer: "Au"),
        Question(text: "How many hearts does an octopus have?",
                    options: ["1", "2", "3", "4"],
                    correctAnswer: "3"),
        Question(text: "What is the capital of Japan?",
                    options: ["Beijing", "Seoul", "Tokyo", "Bangkok"],
                    correctAnswer: "Tokyo"),
        Question(text: "Which country has the longest coastline?",
                    options: ["Russia", "USA", "Australia", "Canada"],
                    correctAnswer: "Canada"),
        Question(text: "What is the speed of light in km/s?",
                    options: ["200,000", "300,000", "400,000", "500,000"],
                    correctAnswer: "300,000"),
    ]
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var quizFinished = false
    @State private var gameStarted = false
    @State private var shuffledQuestions: [Question] = []
    
    func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { selectedAnswer = nil
            if currentIndex + 1 < questions.count {
                currentIndex += 1
            } else {
                quizFinished = true
            }
        }
    }
    func buttonColor(for index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.2) //no answer yet, default color
        }
        if shuffledQuestions[currentIndex].options[index] == shuffledQuestions[currentIndex].correctAnswer {
            return Color.green.opacity(0.85) // always show correct in green
        }
        if index == selected {
            return Color.red.opacity(0.75) //wrong choice turns red
        }
        return Color.white.opacity(0.1) // other buttons go dim
    }
    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        gameStarted = false
        shuffledQuestions = questions.map { question in
                Question(text: question.text,
                         options: question.options.shuffled(),
                         correctAnswer: question.correctAnswer)
        }
    }
    var body: some View {
        if !gameStarted {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("🧠")
                        .font(.system(size: 80))
                    Text("Quiz App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Test your knowledge!")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            Button("Start Quiz") {
                                gameStarted = true
                            }
                            .font(.headline)
                            .foregroundColor(.indigo)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
            .onAppear {
                shuffledQuestions = questions.map { question in
                Question(text: question.text,
                         options: question.options.shuffled(),
                         correctAnswer: question.correctAnswer)
            }
            }
                } else if quizFinished {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("🏆")
                        .font(.system(size: 80))
                    Text("Quiz Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("You scored \(score) out of \(questions.count)")
                        .font(.title2)
                        .foregroundColor(.white)
                    Button("Play Again") {
                        restartQuiz()
                    }
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }else{
            ZStack {
                Color.indigo.ignoresSafeArea()
                // Counter pinned to top right
                VStack {
                    HStack {
                        Spacer()
                        Text("Question \(currentIndex + 1) of \(questions.count)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .padding()
                    }
                    Spacer()
                }
                VStack(spacing: 24) {
                    Text(shuffledQuestions[currentIndex].text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    ForEach(0..<shuffledQuestions[currentIndex].options.count, id: \.self) { i in
                        Button(action: {
                            handleAnswer(i)
                        }) {
                            Text(shuffledQuestions[currentIndex].options[i])
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonColor(for: i))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
            }
        }
        }
    }


#Preview {
    ContentView()
}

