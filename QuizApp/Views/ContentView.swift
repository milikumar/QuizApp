//
//  ContentView.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import SwiftUI

struct ContentView: View {

    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var quizFinished = false
    @State private var gameStarted = false
    @State private var shuffledQuestions: [Question] = []
    @State private var usedSetIndexes: [Int] = []
    @State private var currentSetIndex: Int = 0
    @State private var categorySelected = false
    @State private var setCounts: [Int: Int] = [:]

    func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            selectedAnswer = nil
            if currentIndex + 1 < questionSets[currentSetIndex].questions.count {
                currentIndex += 1
            } else {
                quizFinished = true
            }
        }
    }

    func buttonColor(for index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.2)
        }
        if shuffledQuestions[currentIndex].options[index] == shuffledQuestions[currentIndex].correctAnswer {
            return Color.green.opacity(0.85)
        }
        if index == selected {
            return Color.red.opacity(0.75)
        }
        return Color.white.opacity(0.1)
    }

    func pickRandomSet() -> Int {
        if usedSetIndexes.count == questionSets.count {
            usedSetIndexes = []
        }
        let available = (0..<questionSets.count).filter { !usedSetIndexes.contains($0) }
        if let picked = available.randomElement() {
            currentSetIndex = picked
            usedSetIndexes.append(picked)
            return picked
        }
        return 0
    }

    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        gameStarted = false
        let picked = pickRandomSet()
        shuffledQuestions = questionSets[picked].questions.map { question in
            Question(text: question.text,
                     options: question.options.shuffled(),
                     correctAnswer: question.correctAnswer)
        }
    }

    var body: some View {
        if !gameStarted && !categorySelected {
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
                        categorySelected = true
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
                shuffledQuestions = questionSets[0].questions.map { question in
                    Question(text: question.text,
                             options: question.options.shuffled(),
                             correctAnswer: question.correctAnswer)
                }
            }
        } else if categorySelected && !gameStarted {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("Choose a Category")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    // Random button
                    Button(action: {
                        let picked = pickRandomSet()
                        shuffledQuestions = questionSets[picked].questions.map { question in
                                Question(text: question.text,
                                         options: question.options.shuffled(),
                                         correctAnswer: question.correctAnswer)
                            }
                        setCounts[picked] = (setCounts[picked] ?? 0) + 1
                        gameStarted = true
                        categorySelected = false
                    }) {
                        Text("🎲 Random")
                            .font(.headline)
                            .foregroundColor(.indigo)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Category buttons
                    ForEach(0..<questionSets.count, id: \.self) { i in
                        Button(action: {
                            let picked = i
                            currentSetIndex = picked
                            shuffledQuestions = questionSets[picked].questions.map { question in
                                Question(text: question.text,
                                         options: question.options.shuffled(),
                                         correctAnswer: question.correctAnswer)
                            }
                            setCounts[i] = (setCounts[i] ?? 0) + 1
                            gameStarted = true
                            categorySelected = false
                        }) {
                            HStack {
                                Text(questionSets[i].name)
                                Spacer()
                                if let count = setCounts[i] {
                                    Text("Played \(count)x")
                                        .font(.caption)
                                        .opacity(0.7)
                                }
                            }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
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
                    Text("You scored \(score) out of \(questionSets[currentSetIndex].questions.count)")
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
        } else {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Text("Question \(currentIndex + 1) of \(questionSets[currentSetIndex].questions.count)")
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
