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
    @State private var showCategoryStats = false
    @State private var showQuitAlert = false

    // MARK: - Presentation State
    @State private var usedSetIndexes: [Int] = []
    @State private var setCounts: [Int: Int] = Self.loadSetCounts()
    @State private var showLogo = false
    @State private var showStats = false
    @State private var showPlayButton = false
    @State private var showNumbers = false
    @State private var hasAnimated = false
    @State private var showFloatingDice = false
    @State private var showNextButton = false
    @State private var showConfetti = false
    @State private var timerPaused = false
    @State private var isOffline = false
    @State private var tutorialAnchorFrames: [TutorialTarget: CGRect] = [:]
    @StateObject private var tutorial = TutorialManager()

    // MARK: - Persistent Player Data
    @AppStorage("totalPoints") private var totalPoints = 0
    @AppStorage("totalQuizzes") private var totalQuizzes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("lastPlayedDate") private var lastPlayedDate = ""
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    @AppStorage("perfectScores") private var perfectScores = 0
    @AppStorage("eliteScores") private var eliteScores = 0
    @AppStorage("fastestPerfectTime") private var fastestPerfectTime = 0
    @AppStorage("categoryPoints") private var categoryPointsData = ""
    @AppStorage("hardEliteEarned") private var hardEliteEarned = false
    @AppStorage("consecutiveEliteAverageCount") private var consecutiveEliteAverageCount = 0
    @AppStorage("earnedBadges") private var earnedBadgesData = ""
    @AppStorage("onlineCategoryPlayCounts") private var onlineCategoryPlayCountsData = ""
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("categoryPerfectCounts") private var categoryPerfectCountsData = ""
    @AppStorage("categoryEliteCounts") private var categoryEliteCountsData = ""
    @AppStorage("categoryFastestTimes") private var categoryFastestTimesData = ""

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
        .onPreferenceChange(TutorialAnchorPreferenceKey.self) { tutorialAnchorFrames = $0 }
        .overlay {
            if let step = tutorial.step {
                SpotlightOverlay(
                    step: step,
                    anchorFrames: tutorialAnchorFrames,
                    onNext: advanceTutorial,
                    onDone: finishTutorial
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                isShowing: $showSettings,
                appColorName: $appColorName,
                textColorName: $textColorName,
                categoryStats: categoryStatsList
            )
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
            onPlay: {
                guard !tutorial.isActive || tutorial.step == .play else { return }
                categorySelected = true
                tutorial.advanceAfterPlay()
            },
            onLeaderboard: { if !tutorial.isActive { gcManager.showLeaderboard() } },
            onSettings: { if !tutorial.isActive { showSettings = true } }
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
            onHome: { if !tutorial.isActive { returnToStart() } },
            onLeaderboard: { if !tutorial.isActive { gcManager.showLeaderboard() } },
            onSettings: { if !tutorial.isActive { showSettings = true } },
            onSelectCategory: { if !tutorial.isActive { selectCategory($0) } },
            onSurpriseMe: chooseRandomCategory,
            onScrollPositionChange: { showFloatingDice = $0 }
        )
    }

    private var difficultyScreen: some View {
        DifficultySelectionView(
            appColor: appColor(),
            textColor: appTextColor(),
            categoryName: questionSets[selectedCategory].name,
            onBack: { if !tutorial.isActive { difficultySelected = false } },
            onSelectDifficulty: { difficulty in
                guard !tutorial.isActive || tutorial.step == .difficulty else { return }
                selectedDifficulty = difficulty
                difficultySelected = false
                startSet(index: selectedCategory)
                tutorial.advanceAfterDifficulty()
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
            onPlayAgain: { if !tutorial.isActive { playAgain() } },
            onNewCategory: { if !tutorial.isActive { restartQuiz() } }
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
            onAnswer: { if !tutorial.isActive { handleAnswer($0) } },
            onNext: { if !tutorial.isActive { advanceQuiz() } },
            onSkip: { if !tutorial.isActive { skipQuestion() } },
            onQuit: { if !tutorial.isActive { timerPaused = true; showQuitAlert = true } },
            onStay: { if !tutorial.isActive { timerPaused = false; showQuitAlert = false } },
            onLeave: { if !tutorial.isActive { leaveQuiz() } }
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
        fetchQuestions(for: categoryName, difficulty: selectedDifficulty) { questions, isOffline in
            DispatchQueue.main.async {
                isLoading = false
                if let questions {
                    shuffledQuestions = questions
                    self.isOffline = false
                } else {
                    self.isOffline = isOffline
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
        updateStreak()

        if !isOffline {
            recordOnlineCategoryPlay()
            var points = categoryPoints
            let categoryName = questionSets[currentSetIndex].name
            points[categoryName] = (points[categoryName] ?? 0) + score
            saveCategoryPoints(points)
            gcManager.submitScore(score)
            totalPoints += score
            totalQuizzes += 1
            if score >= 8 {
                perfectScores += 1
                if fastestPerfectTime == 0 || timeElapsed < fastestPerfectTime {
                    fastestPerfectTime = timeElapsed
                }
                var perfects = getCategoryPerfectCounts()
                perfects[categoryName] = (perfects[categoryName] ?? 0) + 1
                saveCategoryPerfectCounts(perfects)

                var fastest = getCategoryFastestTimes()
                if fastest[categoryName] == nil || fastest[categoryName] == 0 || timeElapsed < fastest[categoryName]! {
                    fastest[categoryName] = timeElapsed
                }
                saveCategoryFastestTimes(fastest)
            }
            if score >= 9 {
                eliteScores += 1
                if selectedDifficulty == "hard" { hardEliteEarned = true }
                var elites = getCategoryEliteCounts()
                elites[categoryName] = (elites[categoryName] ?? 0) + 1
                saveCategoryEliteCounts(elites)
            }
            consecutiveEliteAverageCount = score >= 8 ? consecutiveEliteAverageCount + 1 : 0
            checkAndAwardBadges()
        } else {
            checkAndAwardStreakBadges()
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
        guard !tutorial.isActive || tutorial.step == .surpriseMe else { return }
        if usedSetIndexes.count == questionSets.count { usedSetIndexes = [] }
        let available = questionSets.indices.filter { !usedSetIndexes.contains($0) }
        guard let index = available.randomElement() else { return }
        usedSetIndexes.append(index)
        selectCategory(index)
        tutorial.advanceAfterSurpriseMe()
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
        if !hasSeenTutorial && !tutorial.isActive { tutorial.start() }
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
    
    private var categoryStatsList: [CategoryStatRow] {
        let points = categoryPoints
        let perfects = getCategoryPerfectCounts()
        let elites = getCategoryEliteCounts()
        let fastest = getCategoryFastestTimes()
        return questionSets.indices.map { index in
            let name = questionSets[index].name
            return CategoryStatRow(
                name: name,
                plays: setCounts[index] ?? 0,
                points: points[name] ?? 0,
                perfectCount: perfects[name] ?? 0,
                eliteCount: elites[name] ?? 0,
                fastestTime: fastest[name] ?? 0
            )
        }
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
    
    private func getCategoryPerfectCounts() -> [String: Int] {
        guard !categoryPerfectCountsData.isEmpty else { return [:] }
        return categoryPerfectCountsData.split(separator: "|").reduce(into: [:]) { result, pair in
            let parts = pair.split(separator: ":")
            if parts.count == 2, let count = Int(parts[1]) { result[String(parts[0])] = count }
        }
    }

    private func saveCategoryPerfectCounts(_ counts: [String: Int]) {
        categoryPerfectCountsData = counts.map { "\($0.key):\($0.value)" }.joined(separator: "|")
    }

    private func getCategoryEliteCounts() -> [String: Int] {
        guard !categoryEliteCountsData.isEmpty else { return [:] }
        return categoryEliteCountsData.split(separator: "|").reduce(into: [:]) { result, pair in
            let parts = pair.split(separator: ":")
            if parts.count == 2, let count = Int(parts[1]) { result[String(parts[0])] = count }
        }
    }

    private func saveCategoryEliteCounts(_ counts: [String: Int]) {
        categoryEliteCountsData = counts.map { "\($0.key):\($0.value)" }.joined(separator: "|")
    }

    private func getCategoryFastestTimes() -> [String: Int] {
        guard !categoryFastestTimesData.isEmpty else { return [:] }
        return categoryFastestTimesData.split(separator: "|").reduce(into: [:]) { result, pair in
            let parts = pair.split(separator: ":")
            if parts.count == 2, let time = Int(parts[1]) { result[String(parts[0])] = time }
        }
    }

    private func saveCategoryFastestTimes(_ times: [String: Int]) {
        categoryFastestTimesData = times.map { "\($0.key):\($0.value)" }.joined(separator: "|")
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

    // MARK: - Onboarding Tutorial
    private func advanceTutorial() {
        guard let step = tutorial.step else { return }
        tutorial.advance()
        if step == .skip { showTutorialResults() }
    }

    private func showTutorialResults() {
        stopTimer()
        score = 8
        skipsUsed = 1
        timeElapsed = 42
        selectedAnswer = nil
        showNextButton = false
        isOffline = false
        gameStarted = false
        quizFinished = true
    }

    private func finishTutorial() {
        hasSeenTutorial = true
        tutorial.complete()
    }

    // MARK: - Badge Progress
    private func recordOnlineCategoryPlay() {
        var counts = BadgeProgress.decodeCategoryCounts(onlineCategoryPlayCountsData)
        counts[currentSetIndex] = (counts[currentSetIndex] ?? 0) + 1
        onlineCategoryPlayCountsData = BadgeProgress.encodeCategoryCounts(counts)
    }

    private func checkAndAwardBadges() {
        let snapshot = BadgeProgressSnapshot(
            onlineCategoryPlayCounts: BadgeProgress.decodeCategoryCounts(onlineCategoryPlayCountsData),
            categoryCount: questionSets.count,
            totalQuizzes: totalQuizzes,
            totalPoints: totalPoints,
            perfectScores: perfectScores,
            eliteScores: eliteScores,
            hardEliteEarned: hardEliteEarned,
            consecutiveEliteAverageCount: consecutiveEliteAverageCount,
            fastestPerfectTime: fastestPerfectTime,
            currentStreak: currentStreak
        )
        let earned = BadgeProgress.awardedBadgeIDs(
            existing: BadgeProgress.decodeIDs(earnedBadgesData),
            snapshot: snapshot
        )
        earnedBadgesData = BadgeProgress.encodeIDs(earned)
    }

    private func checkAndAwardStreakBadges() {
        let earned = BadgeProgress.awardedStreakBadgeIDs(
            existing: BadgeProgress.decodeIDs(earnedBadgesData),
            currentStreak: currentStreak
        )
        earnedBadgesData = BadgeProgress.encodeIDs(earned)
    }
}

#Preview {
    ContentView().environmentObject(GameCenterManager.shared)
}
