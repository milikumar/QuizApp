//
//  ContentView.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import GameKit
import SwiftUI

struct ContentView: View {

    // MARK: - Quiz State
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int?
    @State private var shuffledQuestions: [Question] = []
    @State private var currentSetIndex = 0
    @State private var selectedCategory = 0
    @State private var selectedDifficulty = "medium"
    @State private var skipsUsed = 0
    @State private var timeElapsed = 0
    @State private var timer: Timer?

    // MARK: - Navigation State
    @State private var quizFinished = false
    @State private var gameStarted = false
    @State private var categorySelected = false
    @State private var difficultySelected = false
    @State private var isLoading = false
    @State private var showSettings = false
    @State private var showQuitAlert = false

    // MARK: - Presentation State
    @State private var usedSetIndexes: [Int] = []
    @State private var setCounts: [Int: Int] = Self.loadSetCounts()
    @State private var showLogo = false
    @State private var showStats = false
    @State private var showPlayButton = false
    @State private var showNumbers = false
    @State private var hasAnimated = false
    @State private var showFloatingDice = true
    @State private var showNextButton = false
    @State private var showConfetti = false
    @State private var timerPaused = false
    @State private var isOffline = false

    // MARK: - Persistent Player Data
    @AppStorage("totalPoints") private var totalPoints = 0
    @AppStorage("totalQuizzes") private var totalQuizzes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("lastPlayedDate") private var lastPlayedDate = ""
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    @AppStorage("perfectScores") private var perfectScores = 0
    @AppStorage("fastestPerfectTime") private var fastestPerfectTime = 0
    @AppStorage("categoryPoints") private var categoryPointsData = ""

    @EnvironmentObject private var gcManager: GameCenterManager
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Screen Routing
    private enum Screen {
        case loading, start, categories, difficulty, results, quiz
    }

    private var activeScreen: Screen {
        if isLoading { return .loading }
        if quizFinished { return .results }
        if gameStarted { return .quiz }
        if difficultySelected { return .difficulty }
        if categorySelected { return .categories }
        return .start
    }

    var body: some View {
        Group {
            switch activeScreen {
            case .loading:
                LoadingView(appColor: appColor(), textColor: appTextColor())
            case .start:
                startScreen
            case .categories:
                categoryScreen
            case .difficulty:
                difficultyScreen
            case .results:
                resultsScreen
            case .quiz:
                quizScreen
            }
        }
        .onChange(of: scenePhase) { _, phase in
            handleScenePhaseChange(phase)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isShowing: $showSettings, appColorName: $appColorName, textColorName: $textColorName)
        }
    }

    // MARK: - Screen Composition
    private var startScreen: some View {
        StartScreenView(
            appColor: appColor(),
            textColor: appTextColor(),
            totalQuizzes: totalQuizzes,
            totalPoints: totalPoints,
            perfectScores: perfectScores,
            currentStreak: currentStreak,
            fastestPerfectTime: fastestPerfectTime,
            bestCategory: bestCategory,
            playerName: gcManager.isAuthenticated ? gcManager.playerName : nil,
            showLogo: showLogo,
            showStats: showStats,
            showNumbers: showNumbers,
            showPlayButton: showPlayButton,
            onPlay: { categorySelected = true },
            onLeaderboard: gcManager.showLeaderboard,
            onSettings: { showSettings = true }
        )
        .onAppear(perform: prepareStartScreen)
    }

    private var categoryScreen: some View {
        CategorySelectionView(
            appColor: appColor(),
            textColor: appTextColor(),
            categories: questionSets.map(\.name),
            playCounts: setCounts,
            showFloatingDice: showFloatingDice,
            onHome: returnToStart,
            onLeaderboard: gcManager.showLeaderboard,
            onSettings: { showSettings = true },
            onSelectCategory: selectCategory,
            onSurpriseMe: chooseRandomCategory,
            onScrollPositionChange: { showFloatingDice = $0 }
        )
    }

    private var difficultyScreen: some View {
        DifficultySelectionView(
            appColor: appColor(),
            textColor: appTextColor(),
            categoryName: questionSets[selectedCategory].name,
            onBack: { difficultySelected = false },
            onSelectDifficulty: { difficulty in
                selectedDifficulty = difficulty
                difficultySelected = false
                startSet(index: selectedCategory)
            }
        )
    }

    private var resultsScreen: some View {
        ResultsView(
            appColor: appColor(),
            textColor: appTextColor(),
            score: score,
            questionCount: questionCount,
            categoryName: questionSets[currentSetIndex].name,
            difficulty: selectedDifficulty,
            skipsUsed: skipsUsed,
            elapsedTime: timeElapsed,
            perfectScores: perfectScores,
            showNewFastestTime: score == questionCount && fastestPerfectTime == timeElapsed,
            onPlayAgain: playAgain,
            onNewCategory: restartQuiz
        )
    }

    private var quizScreen: some View {
        QuizRoundView(
            appColor: appColor(),
            textColor: appTextColor(),
            question: shuffledQuestions[currentIndex],
            questionIndex: currentIndex,
            questionCount: questionCount,
            categoryName: questionSets[currentSetIndex].name,
            difficulty: selectedDifficulty,
            selectedAnswer: selectedAnswer,
            showNextButton: showNextButton,
            skipsUsed: skipsUsed,
            skipsAllowed: 2,
            elapsedTime: timeElapsed,
            isOffline: isOffline,
            showQuitAlert: showQuitAlert,
            buttonColor: buttonColor,
            onAnswer: handleAnswer,
            onNext: advanceQuiz,
            onSkip: skipQuestion,
            onQuit: { timerPaused = true; showQuitAlert = true },
            onStay: { timerPaused = false; showQuitAlert = false },
            onLeave: leaveQuiz
        )
        .overlay {
            if showConfetti {
                ConfettiEffect().ignoresSafeArea()
            }
        }
    }

    // MARK: - Quiz Actions
    private func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
            SoundManager.shared.playCorrect()
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showConfetti = false }
            if score >= 8 { stopTimer() }
        } else {
            SoundManager.shared.playWrong()
        }
        if currentIndex + 1 == questionCount { stopTimer() }
        showNextButton = true
    }

    private func advanceQuiz() {
        showNextButton = false
        selectedAnswer = nil
        if currentIndex + 1 < questionCount {
            currentIndex += 1
        } else {
            finishQuiz()
        }
    }

    private func skipQuestion() {
        skipsUsed += 1
        selectedAnswer = -1
        showNextButton = true
        timerPaused = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { timerPaused = false }
    }

    private func startSet(index: Int) {
        isLoading = true
        let categoryName = questionSets[index].name
        fetchQuestions(for: categoryName, difficulty: selectedDifficulty) { questions in
            DispatchQueue.main.async {
                isLoading = false
                if let questions {
                    shuffledQuestions = questions
                    isOffline = false
                } else {
                    isOffline = true
                    shuffledQuestions = questionSets[index].questions.map {
                        Question(text: $0.text, options: $0.options.shuffled(), correctAnswer: $0.correctAnswer)
                    }
                }
                currentSetIndex = index
                skipsUsed = 0
                startTimer()
                gameStarted = true
                categorySelected = false
                difficultySelected = false
            }
        }
    }

    private func finishQuiz() {
        setCounts[currentSetIndex] = (setCounts[currentSetIndex] ?? 0) + 1
        saveSetCounts(setCounts)

        if !isOffline {
            var points = categoryPoints
            let categoryName = questionSets[currentSetIndex].name
            points[categoryName] = (points[categoryName] ?? 0) + score
            saveCategoryPoints(points)
            gcManager.submitScore(score)
            totalPoints += score
            totalQuizzes += 1
            updateStreak()
            if score >= 8 {
                perfectScores += 1
                if fastestPerfectTime == 0 || timeElapsed < fastestPerfectTime {
                    fastestPerfectTime = timeElapsed
                }
            }
        }
        quizFinished = true
    }

    private func playAgain() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showNextButton = false
        quizFinished = false
        startSet(index: currentSetIndex)
    }

    private func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        gameStarted = false
        categorySelected = true
    }

    private func leaveQuiz() {
        showQuitAlert = false
        timerPaused = false
        gameStarted = false
        categorySelected = true
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        stopTimer()
    }

    // MARK: - Category Selection
    private func selectCategory(_ index: Int) {
        selectedCategory = index
        difficultySelected = true
    }

    private func chooseRandomCategory() {
        if usedSetIndexes.count == questionSets.count { usedSetIndexes = [] }
        let available = questionSets.indices.filter { !usedSetIndexes.contains($0) }
        guard let index = available.randomElement() else { return }
        usedSetIndexes.append(index)
        selectCategory(index)
    }

    private func returnToStart() {
        categorySelected = false
        gameStarted = false
        difficultySelected = false
    }

    // MARK: - Timer and Lifecycle
    private func startTimer() {
        timeElapsed = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !timerPaused { timeElapsed += 1 }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func prepareStartScreen() {
        if !hasAnimated {
            hasAnimated = true
            triggerAnimations()
        }
        authenticateGameCenter()
        if shuffledQuestions.isEmpty {
            shuffledQuestions = questionSets[0].questions.map {
                Question(text: $0.text, options: $0.options.shuffled(), correctAnswer: $0.correctAnswer)
            }
        }
        withAnimation(.easeIn(duration: 1.2).delay(0.3)) { showLogo = true }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .background { hasAnimated = false }
        if phase == .active && !hasAnimated {
            hasAnimated = true
            triggerAnimations()
        }
        if phase == .background && gameStarted { leaveQuiz() }
    }

    private func triggerAnimations() {
        showStats = false
        showNumbers = false
        showPlayButton = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.3).delay(0.6)) { showStats = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.2).delay(0.9)) { showNumbers = true }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.3).delay(1.2)) { showPlayButton = true }
    }

    // MARK: - Presentation Helpers
    private var questionCount: Int { questionSets[currentSetIndex].questions.count }
    private var categoryPoints: [String: Int] { getCategoryPoints() }
    private var bestCategory: (name: String, points: Int)? {
        categoryPoints.max(by: { $0.value < $1.value }).map { ($0.key, $0.value) }
    }

    private func buttonColor(for index: Int) -> Color {
        guard let selectedAnswer else { return Color.white.opacity(0.2) }
        if shuffledQuestions[currentIndex].options[index] == shuffledQuestions[currentIndex].correctAnswer {
            return .green.opacity(0.85)
        }
        return index == selectedAnswer ? .red.opacity(0.75) : .white.opacity(0.1)
    }

    private func appColor() -> Color { getAppColor(appColorName) }
    private func appTextColor() -> Color { getAppTextColor(appColorName, textColorName) }
    private func authenticateGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { _, _ in }
    }

    // MARK: - Local Persistence
    private static func loadSetCounts() -> [Int: Int] {
        guard let data = UserDefaults.standard.data(forKey: "setCounts"),
              let counts = try? JSONDecoder().decode([Int: Int].self, from: data) else { return [:] }
        return counts
    }

    private func saveSetCounts(_ counts: [Int: Int]) {
        guard let data = try? JSONEncoder().encode(counts) else { return }
        UserDefaults.standard.set(data, forKey: "setCounts")
    }

    private func getCategoryPoints() -> [String: Int] {
        guard !categoryPointsData.isEmpty else { return [:] }
        return categoryPointsData.split(separator: "|").reduce(into: [:]) { result, pair in
            let parts = pair.split(separator: ":")
            if parts.count == 2, let points = Int(parts[1]) { result[String(parts[0])] = points }
        }
    }

    private func saveCategoryPoints(_ points: [String: Int]) {
        categoryPointsData = points.map { "\($0.key):\($0.value)" }.joined(separator: "|")
    }

    private func updateStreak() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let today = formatter.string(from: Date())
        let yesterday = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        if lastPlayedDate == today { return }
        currentStreak = lastPlayedDate == yesterday ? currentStreak + 1 : 1
        lastPlayedDate = today
    }
}

#Preview {
    ContentView().environmentObject(GameCenterManager.shared)
}
