//
//  QuizScreens.swift
//  QuizApp
//
//  Composable screens used by ContentView.
//

import SwiftUI

// MARK: - Loading Screen

struct LoadingView: View {
    let appColor: Color
    let textColor: Color

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView().tint(.white).scaleEffect(1.5)
                Text("Loading questions...").font(.headline).foregroundColor(textColor)
            }
        }
    }
}

// MARK: - Start Screen

struct StartScreenView: View {
    let appColor: Color
    let textColor: Color
    let totalQuizzes: Int
    let totalPoints: Int
    let perfectScores: Int
    let currentStreak: Int
    let fastestPerfectTime: Int
    let bestCategory: (name: String, points: Int)?
    let playerName: String?
    let isFirstLaunch: Bool
    let showLogo: Bool
    let showStats: Bool
    let showNumbers: Bool
    let showPlayButton: Bool
    let onPlay: () -> Void
    let onLeaderboard: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack(spacing: 20) {
                logo
                welcome
                scoreSummary
                highlightCards
                primaryActions
            }
        }
    }

    // MARK: - Header
    private var logo: some View {
        Group {
            Image("StartScreenLogo")
                .resizable().scaledToFit().frame(width: 150, height: 150).padding(20)
                .background(.white).clipShape(Circle())
                .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 5)
            Text("Cleverr Mind")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(textColor).opacity(showLogo ? 1 : 0)
        }
    }

    private var welcome: some View {
        VStack(spacing: 12) {
            Text(isFirstLaunch ? "Welcome!" : "Welcome back!").font(.custom("Chalkboard SE", size: 22)).foregroundColor(.white.opacity(0.9))
            if let playerName {
                Text(playerName).font(.custom("Chalkboard SE", size: 22)).foregroundColor(textColor)
            }
        }
    }

    // MARK: - Player Statistics
    private var scoreSummary: some View {
        HStack(spacing: 8) {
            SummaryStat(value: totalQuizzes, label: "Quizzes", textColor: textColor, isVisible: showNumbers)
            SummaryStat(value: totalPoints, label: "Points", textColor: textColor, isVisible: showNumbers)
            SummaryStat(value: totalQuizzes == 0 ? 0 : totalPoints / totalQuizzes, label: "Avg/8", textColor: textColor, isVisible: showNumbers)
            SummaryStat(value: perfectScores, label: "Elite", textColor: textColor, isVisible: showNumbers)
        }
        .offset(x: showStats ? 0 : -300).opacity(showStats ? 1 : 0).padding(.horizontal)
    }

    private var highlightCards: some View {
        TabView {
            HighlightCard(icon: "🔥", title: "\(currentStreak) Day Streak", subtitle: currentStreak == 0 ? "Play today to start your streak!" : "Keep it going!", textColor: textColor)
                .padding(.horizontal, 4)
            HighlightCard(icon: "⚡️", title: fastestPerfectTime == 0 ? "No perfect yet!" : formatTime(fastestPerfectTime), subtitle: "Fastest Perfect Time", textColor: textColor)
                .padding(.horizontal, 4)
            HighlightCard(icon: "🏆", title: bestCategory?.name ?? "No data yet!", subtitle: bestCategory.map { "\($0.points) points earned" } ?? "Best Category", textColor: textColor)
                .padding(.horizontal, 4)
        }
        .tabViewStyle(.page(indexDisplayMode: .always)).frame(height: 110)
        .offset(x: showStats ? 0 : 300).opacity(showStats ? 1 : 0).padding(.horizontal)
    }

    // MARK: - Actions
    private var primaryActions: some View {
        VStack(spacing: 12) {
            Button(action: onPlay) {
                Text("▶ Play").font(.title2).fontWeight(.bold).foregroundColor(appColor)
                    .frame(width: 200).padding().background(.white).cornerRadius(16)
            }
            .scaleEffect(showPlayButton ? 1 : 0.01).opacity(showPlayButton ? 1 : 0)
            .tutorialAnchor(.play)
            ScreenButton(title: "⚙️ Settings", textColor: textColor, action: onSettings)
                .tutorialAnchor(.settings)
        }
        .padding(.horizontal).padding(.bottom, 40)
    }
}

// MARK: - Category Selection Screen

struct CategorySelectionView: View {
    let appColor: Color
    let textColor: Color
    let categories: [String]
    let playCounts: [Int: Int]
    let showFloatingDice: Bool
    let onHome: () -> Void
    let onLeaderboard: () -> Void
    let onSettings: () -> Void
    let onSelectCategory: (Int) -> Void
    let onSurpriseMe: () -> Void
    let onScrollPositionChange: (Bool) -> Void

    private var sortedIndexes: [Int] {
        categories.indices.sorted { (playCounts[$0] ?? 0) > (playCounts[$1] ?? 0) }
    }

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    Text("Choose a Category").font(.largeTitle).fontWeight(.bold).foregroundColor(textColor).padding()
                    surpriseButton
                    categoryButtons
                }
            }
            .onAppear { onScrollPositionChange(false) }
            if showFloatingDice { floatingDice }
        }
    }

    // MARK: - Category Controls
    private var header: some View {
        HStack {
            Button(action: onHome) { Image(systemName: "house.fill").font(.title2).foregroundColor(textColor.opacity(0.75)).padding() }
                .tutorialAnchor(.categoryHome)
            Spacer()
        //  Button(action: onLeaderboard) { Image(systemName: "trophy.fill").font(.title2).foregroundColor(textColor.opacity(0.75)).padding(8) }
            Button(action: onSettings) { Image(systemName: "gearshape.fill").font(.title2).foregroundColor(textColor.opacity(0.75)).padding(8) }
        }
    }

    private var surpriseButton: some View {
        GeometryReader { proxy in
            Button(action: onSurpriseMe) {
                Text("🎲 Surprise Me!").font(.headline).fontWeight(.bold).foregroundColor(textColor)
                    .frame(maxWidth: .infinity).padding().background(.white.opacity(0.2)).cornerRadius(12).glittering()
            }
            .tutorialAnchor(.surpriseMe)
            .onChange(of: proxy.frame(in: .global).minY) { _, minY in onScrollPositionChange(minY < 0) }
        }
        .frame(height: 50).padding(.horizontal)
    }

    private var categoryButtons: some View {
        ForEach(sortedIndexes, id: \.self) { index in
            Button(action: { onSelectCategory(index) }) {
                HStack {
                    Text(categories[index])
                    Spacer()
                    if let count = playCounts[index] { Text("Played \(count)x").font(.caption).opacity(0.7) }
                }
                .font(.headline).foregroundColor(appColor).frame(maxWidth: .infinity)
                .padding().background(.white).cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    private var floatingDice: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: onSurpriseMe) {
                    Text("🎲").font(.title).padding().background(.white).clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }.padding()
            }
        }
    }
}

// MARK: - Difficulty Selection Screen

struct DifficultySelectionView: View {
    let appColor: Color
    let textColor: Color
    let categoryName: String
    let onBack: () -> Void
    let onSelectDifficulty: (String) -> Void

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack {
                HStack { Button(action: onBack) { Image(systemName: "chevron.left.circle.fill").font(.title2).foregroundColor(.white.opacity(0.75)).padding() }; Spacer() }
                Spacer()
            }
            VStack(spacing: 20) {
                Text("Choose Difficulty").font(.largeTitle).fontWeight(.bold).foregroundColor(textColor).padding()
                Text(categoryName).font(.title3).foregroundColor(textColor.opacity(0.8))
                ForEach(["Shuffle", "Medium", "Hard"], id: \.self) { difficulty in
                    Button(action: { onSelectDifficulty(difficulty.lowercased()) }) {
                        Text(difficulty).font(.headline).foregroundColor(textColor).frame(maxWidth: .infinity)
                            .padding().background(.white.opacity(0.2)).cornerRadius(12)
                    }.padding(.horizontal)
                }
            }
            .tutorialAnchor(.difficulty)
        }
    }
}

// MARK: - Results Screen

struct ResultsView: View {
    let appColor: Color
    let textColor: Color
    let score: Int
    let questionCount: Int
    let categoryName: String
    let difficulty: String
    let skipsUsed: Int
    let elapsedTime: Int
    let perfectScores: Int
    let showNewFastestTime: Bool
    let onPlayAgain: () -> Void
    let onNewCategory: () -> Void
    let onHome: () -> Void

    private var stars: Int { score >= 9 ? 4 : score >= 8 ? 3 : score >= 6 ? 2 : score >= 3 ? 1 : 0 }

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack(spacing: 0) {
                resultHeader
                resultDetails
            }
            VStack {
                HStack {
                    Button(action: onHome) { Image(systemName: "house.fill").font(.title2).foregroundColor(textColor.opacity(0.75)).padding() }
                    Spacer()
                }
                Spacer()
            }
        }
    }

    // MARK: - Result Summary
    private var resultHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Text(stars == 4 ? "🌟" : index < stars ? "⭐️" : "★").font(.system(size: 50))
                        .foregroundColor(stars == 4 || index < stars ? .yellow : .white.opacity(0.3))
                }
            }.padding(.top, 20)
            ZStack {
                Circle().fill(.white.opacity(0.15)).frame(width: 160, height: 160)
                Circle().stroke(.white, lineWidth: 4).frame(width: 160, height: 160)
                VStack(spacing: 2) { Text("\(score)").font(.system(size: 64, weight: .bold, design: .rounded)).foregroundColor(.white); Text("out of 8").font(.caption).foregroundColor(.white.opacity(0.8)) }
            }.padding(.vertical, 8)
            Text(resultMessage).font(.title).fontWeight(.bold).foregroundColor(textColor)
            HStack(spacing: 6) { Text(categoryName); Text("•"); Text(difficulty.capitalized) }.font(.headline).foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .tutorialAnchor(.results)
    }

    // MARK: - Result Actions and Details
    private var resultDetails: some View {
        VStack(spacing: 12) {
            if skipsUsed > 0 { Text("🎯 Skips used: \(skipsUsed)").font(.subheadline).foregroundColor(textColor).resultCard().padding(.top, 20) }
            if showNewFastestTime { Text("⚡️ New fastest perfect time!").font(.subheadline).foregroundColor(textColor).resultCard() }
            HStack(spacing: 12) {
                ResultStat(value: formatTime(elapsedTime), label: "Time", textColor: textColor)
                ResultStat(value: "\(Int((Double(score) / 8) * 100))%", label: "Accuracy", textColor: textColor)
                ResultStat(value: "\(perfectScores)", label: "Perfects", textColor: textColor)
            }.padding(.top, 30).padding(.horizontal)
            Spacer()
            Button(action: onPlayAgain) { Text("▶ Play \(categoryName) Again").font(.headline).foregroundColor(appColor).frame(maxWidth: .infinity).padding().background(.white).cornerRadius(12) }.padding(.horizontal).padding(.top, 20)
            Button(action: onNewCategory) { Text("🗂 New Category").font(.headline).foregroundColor(textColor).frame(maxWidth: .infinity).padding().background(.white.opacity(0.2)).cornerRadius(12) }.padding(.horizontal).padding(.top, 8).padding(.bottom, 40)
        }
    }

    private var resultMessage: String {
        score >= 9 ? "Legendary! 🌟" : score == 8 ? "Perfect! 🏆" : score >= 5 ? "Great job! 👏" : score >= 3 ? "Not bad! 💪" : "Keep trying! 📚"
    }
}

// MARK: - Quiz Round Screen

struct QuizRoundView: View {
    let appColor: Color
    let textColor: Color
    let question: Question
    let questionIndex: Int
    let questionCount: Int
    let categoryName: String
    let difficulty: String
    let selectedAnswer: Int?
    let showNextButton: Bool
    let skipsUsed: Int
    let skipsAllowed: Int
    let elapsedTime: Int
    let isOffline: Bool
    let showQuitAlert: Bool
    let buttonColor: (Int) -> Color
    let onAnswer: (Int) -> Void
    let onNext: () -> Void
    let onSkip: () -> Void
    let onQuit: () -> Void
    let onStay: () -> Void
    let onLeave: () -> Void

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack {
                quizHeader
                if isOffline { offlineBanner }
                categoryLabel
                Spacer()
                questionContent
                Spacer()
                progressBar
            }
            if showQuitAlert { quitAlert }
        }
    }

    // MARK: - Quiz Header
    private var quizHeader: some View {
        HStack {
            Button(action: onQuit) { Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.white.opacity(0.75)).padding() }
                .tutorialAnchor(.exit)
            Spacer()
            Text("⏱ \(formatTime(elapsedTime))").font(.subheadline).foregroundColor(textColor.opacity(0.75))
                .tutorialAnchor(.timer)
            Spacer()
            Text("Q\(questionIndex + 1)/\(questionCount)").font(.subheadline).foregroundColor(textColor.opacity(0.75)).padding()
        }
    }

    private var offlineBanner: some View {
        Text("📵 Offline mode — stats won't be tracked").font(.caption).foregroundColor(.white).frame(maxWidth: .infinity)
            .padding(8).background(.black.opacity(0.3)).cornerRadius(8).padding(.horizontal)
    }

    private var categoryLabel: some View {
        HStack { Text(categoryName); Text("•"); Text(difficulty.capitalized) }
            .font(.caption).foregroundColor(textColor.opacity(0.7))
    }

    // MARK: - Question and Answers
    private var questionContent: some View {
        VStack(spacing: 20) {
            Text(question.text).font(.title3).fontWeight(.bold).foregroundColor(appColor).multilineTextAlignment(.center)
                .padding().frame(maxWidth: .infinity).fixedSize(horizontal: false, vertical: true).background(.white).cornerRadius(16).padding(.horizontal)
            ForEach(question.options.indices, id: \.self) { index in
                Button(action: { onAnswer(index) }) {
                    Text(question.options[index]).font(.headline).foregroundColor(textColor).frame(maxWidth: .infinity)
                        .padding().background(buttonColor(index)).cornerRadius(12)
                }.disabled(selectedAnswer != nil).padding(.horizontal)
            }
            roundActions
            Text("Only need 8/10 for 100% • Skipping saves 2s ⏱").font(.caption).foregroundColor(.white.opacity(0.4))
        }
    }

    private var roundActions: some View {
        VStack(spacing: 12) {
            if showNextButton {
                Button(action: onNext) {
                    Text(questionIndex + 1 < questionCount ? "Next →" : "Finish ✓").font(.headline).foregroundColor(appColor).frame(maxWidth: .infinity)
                        .padding().background(.white).cornerRadius(12)
                }.transition(.opacity)
            }
            if selectedAnswer == nil && skipsUsed < skipsAllowed {
                Button(action: onSkip) {
                    Text("Skip (\(skipsAllowed - skipsUsed) left)").font(.headline).foregroundColor(appColor).frame(maxWidth: .infinity)
                        .padding().background(.white).cornerRadius(12)
                }
                .tutorialAnchor(.skip)
            }
        }.padding(.horizontal).padding(.top, 4)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.2)).frame(height: 8)
                RoundedRectangle(cornerRadius: 8).fill(.white)
                    .frame(width: proxy.size.width * CGFloat(questionIndex + 1) / CGFloat(questionCount), height: 8)
                    .animation(.easeInOut, value: questionIndex)
            }
        }.frame(height: 8).padding(.horizontal).padding(.bottom)
    }

    // MARK: - Quit Confirmation
    private var quitAlert: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("⚠️ Leave Quiz?").font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text("If you leave you'll lose your progress and your time won't be saved.").font(.subheadline).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.center).padding(.horizontal)
                HStack(spacing: 16) {
                    QuitAlertButton(title: "Stay", foregroundColor: appColor, backgroundColor: .white, action: onStay)
                    QuitAlertButton(title: "Leave", foregroundColor: .white, backgroundColor: .red.opacity(0.8), action: onLeave)
                }.padding(.horizontal)
            }.padding().background(appColor).cornerRadius(20).padding(.horizontal, 30)
        }
    }
}

// MARK: - Shared Screen Components

private struct SummaryStat: View {
    let value: Int
    let label: String
    let textColor: Color
    let isVisible: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)").font(.title).fontWeight(.bold).foregroundColor(textColor).scaleEffect(isVisible ? 1 : 0.1)
            Text(label).font(.caption).foregroundColor(.white.opacity(0.8))
        }.frame(maxWidth: .infinity).padding().background(.white.opacity(0.15)).cornerRadius(16)
    }
}

private struct HighlightCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let textColor: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(icon).font(.system(size: 40))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.title2).fontWeight(.bold).foregroundColor(textColor)
                Text(subtitle).font(.caption).foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }.padding().frame(maxWidth: .infinity).background(.white.opacity(0.15)).cornerRadius(16)
    }
}

private struct ScreenButton: View {
    let title: String
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) { Text(title).font(.headline).foregroundColor(textColor).frame(maxWidth: .infinity).padding().background(.white.opacity(0.2)).cornerRadius(16) }
    }
}

private struct ResultStat: View {
    let value: String
    let label: String
    let textColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2).fontWeight(.bold).foregroundColor(textColor)
            Text(label).font(.caption).foregroundColor(.white.opacity(0.8))
        }.frame(maxWidth: .infinity).padding().background(.white.opacity(0.15)).cornerRadius(16)
    }
}

private struct QuitAlertButton: View {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) { Text(title).font(.headline).foregroundColor(foregroundColor).frame(maxWidth: .infinity).padding().background(backgroundColor).cornerRadius(12) }
    }
}

private extension View {
    func resultCard() -> some View {
        frame(maxWidth: .infinity).padding().background(.white.opacity(0.15)).cornerRadius(12).padding(.horizontal)
    }
}

private func formatTime(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}
