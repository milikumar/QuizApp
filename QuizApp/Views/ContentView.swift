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
    
    func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { selectedAnswer = nil
            if currentIndex + 1 < questionSets[currentSetIndex].count {
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
        let picked = pickRandomSet()
        shuffledQuestions = questionSets[picked].map { question in
                Question(text: question.text,
                         options: question.options.shuffled(),
                         correctAnswer: question.correctAnswer)
        }
    }
    func pickRandomSet() -> Int {
        let available = (0..<questionSets.count).filter { !usedSetIndexes.contains($0) }
        if usedSetIndexes.count == questionSets.count {
            usedSetIndexes = []
        }
        if let picked = available.randomElement() {
            currentSetIndex = picked
            usedSetIndexes.append(picked)
            return picked
        }
        return 0
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
                let picked = pickRandomSet()
                shuffledQuestions = questionSets[picked].map { question in
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
                    Text("You scored \(score) out of \(questionSets[currentSetIndex].count)")
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
                        Text("Question \(currentIndex + 1) of \(questionSets[currentSetIndex].count)")
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

