//
//  ContentView.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import SwiftUI
import GameKit

struct ContentView: View {
    
    // MARK: - State Variables
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var quizFinished = false
    @State private var gameStarted = false
    @State private var shuffledQuestions: [Question] = []
    @State private var usedSetIndexes: [Int] = []
    @State private var currentSetIndex: Int = 0
    @State private var categorySelected = false
    @State private var setCounts: [Int: Int] = {
        if let data = UserDefaults.standard.data(forKey: "setCounts"),
           let decoded = try? JSONDecoder().decode([Int: Int].self, from: data) {
            return decoded
        }
        return [:]
    }()
    @State private var difficultySelected = false
    @State private var selectedCategory = 0
    @State private var selectedDifficulty = "medium"
    @State private var isLoading = false
    @State private var isGameCenterAuthenticated = false
    @State private var showLogo = false
    @State private var showStats = false
    @State private var showPlayButton = false
    @State private var showTitle = false
    @State private var showSettings = false
    @State private var showTheme = false
    @State private var hasAnimated = false
    @State private var showNumbers = false
    @State private var showFloatingDice = true
    @State private var timeElapsed = 0
    @State private var timer: Timer? = nil
    @State private var showQuitAlert = false
    @State private var timerPaused = false
    @State private var showNextButton = false
    @State private var skipsUsed = 0
    @State private var skipsAllowed = 2
    @AppStorage("totalPoints") private var totalPoints = 0
    @AppStorage("totalQuizzes") private var totalQuizzes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("lastPlayedDate") private var lastPlayedDate = ""
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    @AppStorage("perfectScores") private var perfectScores = 0
    @AppStorage("fastestPerfectTime") private var fastestPerfectTime = 0
    @EnvironmentObject var gcManager: GameCenterManager
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Handle Answer
    func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
        }
        // If it's the last question, stop timer immediately
        if currentIndex + 1 == questionSets[currentSetIndex].questions.count {
            stopTimer()
        }
        showNextButton = true
    }
    
    // MARK: - Button Color
    func buttonColor(for index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.2)
        }
        if shuffledQuestions[currentIndex].options[index] == shuffledQuestions[currentIndex].correctAnswer {
            return Color.green.opacity(0.85)  // always show correct in green
        }
        if index == selected {
            return Color.red.opacity(0.75)    // wrong choice turns red
        }
        return Color.white.opacity(0.1)
    }
    
    // MARK: - Pick Random Set
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
    
    // MARK: - Restart Quiz
    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        gameStarted = false
        categorySelected = true
    }
    
    // MARK: - Start Set
    func startSet(index: Int) {
        isLoading = true
        let categoryName = questionSets[index].name
        fetchQuestions(for: categoryName, difficulty: selectedDifficulty) { questions in
            DispatchQueue.main.async {
                isLoading = false
                if let questions = questions {
                    shuffledQuestions = questions
                } else {
                    shuffledQuestions = questionSets[index].questions.map { question in
                        Question(text: question.text,
                                 options: question.options.shuffled(),
                                 correctAnswer: question.correctAnswer)
                    }
                }
                currentSetIndex = index
                startTimer()
                skipsUsed = 0
                gameStarted = true
                categorySelected = false
                difficultySelected = false
            }
        }
    }
    
    // MARK: - Category Color
    func categoryColor(for name: String) -> Color {
        switch name {
        case "General Knowledge": return Color(red: 0.7, green: 0.6, blue: 0.9)
        case "Science & Nature": return Color(red: 0.1, green: 0.7, blue: 0.2)
        case "History": return Color(red: 0.55, green: 0.35, blue: 0.15)
        case "Geography": return Color(red: 0.1, green: 0.6, blue: 0.65)
        case "Sports": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "Movies & TV": return Color(red: 0.95, green: 0.35, blue: 0.6)
        case "Technology": return Color(red: 0.1, green: 0.4, blue: 0.85)
        case "Music": return Color(red: 0.4, green: 0.1, blue: 0.6)
        case "Animals": return Color(red: 0.6, green: 0.95, blue: 0.7)
        case "Video Games": return Color(red: 0.0, green: 0.0, blue: 0.5)
        case "Mythology": return Color(red: 0.7, green: 0.45, blue: 0.05)
        case "Board Games": return Color(red: 0.4, green: 0.9, blue: 0.95)
        case "Art": return Color(red: 0.98, green: 0.7, blue: 0.5)
        case "Vehicles": return Color(red: 0.27, green: 0.35, blue: 0.43)
        case "Celebrities": return Color(red: 0.98, green: 0.9, blue: 0.3)
        case "Comics": return Color(red: 0.85, green: 0.1, blue: 0.1)
        case "Anime & Manga": return Color(red: 0.95, green: 0.35, blue: 0.6)
        case "Cartoons": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "Books": return Color(red: 0.55, green: 0.35, blue: 0.15)
        case "Gadgets": return Color(red: 0.27, green: 0.35, blue: 0.43)
        default: return .indigo
        }
    }
    
    // MARK: - Authenticate Game Center
    func authenticateGameCenter() {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { vc, error in
            if player.isAuthenticated {
                isGameCenterAuthenticated = true
            }
        }
    }
    
    // MARK: - Streak
    func updateStreak() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        
        if lastPlayedDate == today {
            // Already played today, don't change streak
            return
        } else if lastPlayedDate == DateFormatter.localizedString(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, dateStyle: .short, timeStyle: .none) {
            // Played yesterday, increase streak
            currentStreak += 1
        } else {
            // Missed a day, reset streak
            currentStreak = 1
        }
        lastPlayedDate = today
    }
    
    // MARK: - App Color
    func appColor() -> Color {
        switch appColorName {
        case "rose": return Color(red: 0.95, green: 0.5, blue: 0.5)
        case "red": return Color(red: 0.85, green: 0.1, blue: 0.1)
        case "crimson": return Color(red: 0.6, green: 0.0, blue: 0.1)
        case "peach": return Color(red: 0.98, green: 0.7, blue: 0.5)
        case "orange": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "sunset": return Color(red: 0.7, green: 0.25, blue: 0.05)
        case "yellow": return Color(red: 0.98, green: 0.9, blue: 0.3)
        case "gold": return Color(red: 0.85, green: 0.65, blue: 0.13)
        case "amber": return Color(red: 0.7, green: 0.45, blue: 0.05)
        case "mint": return Color(red: 0.6, green: 0.95, blue: 0.7)
        case "green": return Color(red: 0.1, green: 0.7, blue: 0.2)
        case "forest": return Color(red: 0.05, green: 0.35, blue: 0.1)
        case "cyan": return Color(red: 0.4, green: 0.9, blue: 0.95)
        case "teal": return Color(red: 0.1, green: 0.6, blue: 0.65)
        case "darkTeal": return Color(red: 0.05, green: 0.35, blue: 0.4)
        case "sky": return Color(red: 0.5, green: 0.75, blue: 0.98)
        case "blue": return Color(red: 0.1, green: 0.4, blue: 0.85)
        case "navy": return Color(red: 0.05, green: 0.1, blue: 0.5)
        case "lavender": return Color(red: 0.7, green: 0.6, blue: 0.95)
        case "indigo": return .indigo
        case "violet": return Color(red: 0.4, green: 0.1, blue: 0.6)
        case "lightPink": return Color(red: 0.98, green: 0.7, blue: 0.85)
        case "pink": return Color(red: 0.95, green: 0.35, blue: 0.6)
        case "hotPink": return Color(red: 0.8, green: 0.1, blue: 0.45)
        case "tan": return Color(red: 0.82, green: 0.68, blue: 0.52)
        case "brown": return Color(red: 0.55, green: 0.35, blue: 0.15)
        case "darkBrown": return Color(red: 0.3, green: 0.15, blue: 0.05)
        case "silver": return Color(red: 0.75, green: 0.75, blue: 0.75)
        case "slate": return Color(red: 0.4, green: 0.4, blue: 0.45)
        case "black": return Color(red: 0.1, green: 0.1, blue: 0.15)
        default: return Color(red: 0.3, green: 0.2, blue: 0.8)
        }
    }
    
    // MARK: - App Text Color
    func appTextColor() -> Color {
        if appColorName == "black" { return .white }
        return textColorName == "black" ? Color.black : Color.white
    }
    
    // MARK: - Trigger Animations
    func triggerAnimations() {
        showTitle = false
        showStats = false
        showNumbers = false
        showPlayButton = false
        withAnimation(.easeIn(duration: 1.2).delay(0.3)) { showTitle = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.3).delay(0.6)) { showStats = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.2).delay(0.9)) { showNumbers = true }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.3).delay(1.2)) { showPlayButton = true }
    }
    
    // MARK: - Start Timer
    func startTimer() {
        timeElapsed = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !timerPaused {
                timeElapsed += 1
            }
        }
    }
    
    // MARK: - Stop Timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Format Time
    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    // MARK: - Skip Question
    func skipQuestion() {
        skipsUsed += 1
        selectedAnswer = -1  // -1 means skipped, shows correct answer in green
        showNextButton = true
    }
    
    // MARK: - Finish Quiz
    func finishQuiz() {
        setCounts[currentSetIndex] = (setCounts[currentSetIndex] ?? 0) + 1
        if let encoded = try? JSONEncoder().encode(setCounts) {
            UserDefaults.standard.set(encoded, forKey: "setCounts")
        }
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
        quizFinished = true
    }
    
    // MARK: - Start of Body
    var body: some View {
        // MARK: - Loading Screen
        Group{
            if isLoading {
                ZStack {
                    appColor().ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Loading questions...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                
                // MARK: - Start Screen
            } else if !gameStarted && !categorySelected {
                ZStack {
                    appColor().ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        
                        // Logo
                        Image("StartScreenLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding(20)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 5)
                        
                        Text("Cleverr Mind")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundColor(appTextColor())
                            .opacity(showLogo ? 1 : 0)
                        
                        // Welcome Card
                        VStack(spacing: 12) {
                            Text("Welcome back!")
                                .font(.custom("Chalkboard SE", size: 22))
                                .foregroundColor(.white.opacity(0.9))
                            if gcManager.isAuthenticated {
                                Text(gcManager.playerName)
                                    .font(.custom("Chalkboard SE", size: 22))
                                    .foregroundColor(appTextColor())
                            }
                        }
                        
                        // Stats Card
                        HStack(spacing: 12) {
                            VStack(spacing: 4) {
                                Text("\(totalQuizzes)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(appTextColor())
                                    .scaleEffect(showNumbers ? 1 : 0.1)
                                Text("Quizzes")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                            
                            VStack(spacing: 4) {
                                Text("\(totalPoints)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(appTextColor())
                                    .scaleEffect(showNumbers ? 1 : 0.1)
                                Text("Points")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                            
                            VStack(spacing: 4) {
                                Text("\(totalQuizzes == 0 ? 0 : totalPoints / totalQuizzes)/10")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(appTextColor())
                                    .scaleEffect(showNumbers ? 1 : 0.1)
                                Text("Avg Score")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                        }
                        .offset(x: showStats ? 0 : -300)
                        .opacity(showStats ? 1 : 0)
                        .padding(.horizontal)
                        
                        // Daily Streak Card
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Text("🔥")
                                    .font(.system(size: 40))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(currentStreak) Day Streak")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(appTextColor())
                                    Text(currentStreak == 0 ? "Play today to start your streak!" : "Keep it going!")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(16)
                        }
                        .offset(x: showStats ? 0 : 300)
                        .opacity(showStats ? 1 : 0)
                        .padding(.horizontal)
                        
                        // Play Button
                        Button(action: {
                            categorySelected = true
                        }) {
                            Text("▶ Play")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(appColor())
                                .frame(width: 200)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                        .scaleEffect(showPlayButton ? 1 : 0.01)
                        .opacity(showPlayButton ? 1 : 0)
                        
                        // Leaderboard Button
                        Button(action: {
                            gcManager.showLeaderboard()
                        }) {
                            Text("🏆 Leaderboard")
                                .font(.headline)
                                .foregroundColor(appTextColor())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Settings Button
                        Button(action: {
                            showSettings = true
                        }) {
                            Text("⚙️ Settings")
                                .font(.headline)
                                .foregroundColor(appTextColor())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
                .onAppear {
                    if !hasAnimated {
                        hasAnimated = true
                        triggerAnimations()
                    }
                    authenticateGameCenter()
                    shuffledQuestions = questionSets[0].questions.map { question in
                        Question(text: question.text,
                                 options: question.options.shuffled(),
                                 correctAnswer: question.correctAnswer)
                    }
                    
                    // Animations
                    withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                        showLogo = true
                    }
                    withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                        showStats = true
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(1.2)) {
                        showPlayButton = true
                    }
                    withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                        showTitle = true
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .background {
                        hasAnimated = false
                    }
                    if scenePhase == .active && !hasAnimated {
                        hasAnimated = true
                        triggerAnimations()
                    }
                    if scenePhase == .background && gameStarted {
                        gameStarted = false
                        categorySelected = true
                        currentIndex = 0
                        score = 0
                        selectedAnswer = nil
                        stopTimer()
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(isShowing: $showSettings, appColorName: $appColorName, textColorName: $textColorName)
                }
                
                // MARK: - Category Screen
            } else if categorySelected && !gameStarted && !difficultySelected {
                ZStack {
                    appColor().ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header buttons
                            HStack {
                                Button(action: {
                                    categorySelected = false
                                    gameStarted = false
                                    difficultySelected = false
                                }) {
                                    Image(systemName: "house.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.75))
                                        .padding()
                                }
                                Spacer()
                                Button(action: {
                                    gcManager.showLeaderboard()
                                }) {
                                    Image(systemName: "trophy.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.75))
                                        .padding(8)
                                }
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.75))
                                        .padding(8)
                                }
                            }
                            
                            Text("Choose a Category")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                            
                            GeometryReader { geo in
                                Button(action: {
                                    let picked = pickRandomSet()
                                    selectedCategory = picked
                                    difficultySelected = true
                                }) {
                                    Text("🎲 Surprise Me!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(12)
                                        .glittering()
                                }
                                .onChange(of: geo.frame(in: .global).minY) {
                                    showFloatingDice = geo.frame(in: .global).minY < 0
                                }
                            }
                            .frame(height: 50)
                            .padding(.horizontal)
                            
                            let sorted = questionSets.indices.sorted {
                                (setCounts[$0] ?? 0) > (setCounts[$1] ?? 0)
                            }
                            ForEach(sorted, id: \.self) { i in                            Button(action: {
                                selectedCategory = i
                                difficultySelected = true
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
                                .foregroundColor(appColor())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Floating dice button
                    if showFloatingDice {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    let picked = pickRandomSet()
                                    selectedCategory = picked
                                    difficultySelected = true
                                }) {
                                    Text("🎲")
                                        .font(.title)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .padding()
                            }
                        }
                    }
                }
                
                // MARK: - Difficulty Screen
            } else if difficultySelected && !gameStarted {
                ZStack {
                    appColor().ignoresSafeArea()
                    
                    // Back button for difficulty
                    VStack {
                        HStack {
                            Button(action: {
                                difficultySelected = false
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.75))
                                    .padding()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // Difficulty
                    VStack(spacing: 20) {
                        Text("Choose Difficulty")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                        
                        Text(questionSets[selectedCategory].name)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ForEach(["Shuffle", "Medium", "Hard"], id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = difficulty.lowercased()
                                difficultySelected = false
                                startSet(index: selectedCategory)
                            }) {
                                Text(difficulty)
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
                
                // MARK: - Results Screen
                } else if quizFinished {
                    ZStack {
                        appColor().ignoresSafeArea()
                        VStack(spacing: 0) {
                            
                            // Top section - stars, score circle, message, category
                            VStack(spacing: 12) {
                                let stars = score >= 9 ? 4 : score >= 8 ? 3 : score >= 6 ? 2 : score >= 3 ? 1 : 0
                                
                                // Stars
                                HStack(spacing: 8) {
                                    ForEach(0..<3) { i in
                                        Text(stars == 4 ? "🌟" : i < stars ? "⭐️" : "★")
                                            .font(.system(size: 50))
                                            .foregroundColor(stars == 4 ? .yellow : i < stars ? .yellow : .white.opacity(0.3))
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Score circle
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 160, height: 160)
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 160, height: 160)
                                    VStack(spacing: 2) {
                                        Text("\(score)")
                                            .font(.system(size: 64, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("out of 8")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                // Message
                                Text(score >= 9 ? "Legendary! 🌟" :
                                     score == 8 ? "Perfect! 🏆" :
                                     score >= 6 ? "Great job! 👏" :
                                     score >= 4 ? "Not bad! 💪" : "Keep trying! 📚")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                // Category and difficulty
                                HStack(spacing: 6) {
                                    Text(questionSets[currentSetIndex].name)
                                    Text("•")
                                    Text(selectedDifficulty.capitalized)
                                }
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Bottom section - skips, stats, buttons
                            VStack(spacing: 12) {
                                
                                // Skips used
                                if skipsUsed > 0 {
                                    VStack {
                                        HStack {
                                            Text("🎯 Skips used: \(skipsUsed)")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                    .padding(.top, 20)               }
                                
                                // Personal best banner
                                if score == questionSets[currentSetIndex].questions.count &&
                                   fastestPerfectTime == timeElapsed {
                                    HStack {
                                        Text("⚡️ New fastest perfect time!")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // Stats cards
                                HStack(spacing: 12) {
                                    VStack(spacing: 4) {
                                        Text(formatTime(timeElapsed))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Time")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(16)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(score * 10)%")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Accuracy")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(16)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(perfectScores)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Perfects")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(16)
                                }
                                .padding(.top, 30)
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                // Play Again button
                                Button(action: {
                                    currentIndex = 0
                                    score = 0
                                    selectedAnswer = nil
                                    showNextButton = false
                                    quizFinished = false
                                    startSet(index: currentSetIndex)
                                }) {
                                    Text("▶ Play Again")
                                        .font(.headline)
                                        .foregroundColor(appColor())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                // New Category button
                                Button(action: { restartQuiz() }) {
                                    Text("🗂 New Category")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                
                // MARK: - Quiz Screen
            } else {
                ZStack {
                    appColor().ignoresSafeArea()
                    
                    VStack {
                        // Top bar
                        HStack {
                            Button(action: {
                                timerPaused = true
                                showQuitAlert = true
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.75))
                                    .padding()
                            }
                            Spacer()
                            // Timer
                            Text("⏱ \(formatTime(timeElapsed))")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.75))
                            Spacer()
                            Text("Q\(currentIndex + 1)/\(questionSets[currentSetIndex].questions.count)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.75))
                                .padding()
                        }
                        
                        // Category and difficulty
                        HStack {
                            Text(questionSets[currentSetIndex].name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            Text(selectedDifficulty.capitalized)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Question card
                        VStack(spacing: 20) {
                            Text(shuffledQuestions[currentIndex].text)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(appColor())
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                            
                            // Answer buttons
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
                                .disabled(selectedAnswer != nil)
                                .padding(.horizontal)
                            }
                            VStack(spacing: 12) {
                                
                                // Next button
                                if showNextButton {
                                    Button(action: {
                                        showNextButton = false
                                        selectedAnswer = nil
                                        if currentIndex + 1 < questionSets[currentSetIndex].questions.count {
                                            currentIndex += 1
                                        } else {
                                            finishQuiz()
                                        }
                                    }) {
                                        Text(currentIndex + 1 < questionSets[currentSetIndex].questions.count ? "Next →" : "Finish ✓")
                                            .font(.headline)
                                            .foregroundColor(appColor())
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                    .transition(.opacity)
                                }
                                
                                // Skip button
                                if selectedAnswer == nil && skipsUsed < skipsAllowed {
                                    Button(action: {
                                        skipQuestion()
                                    }) {
                                        Text("Skip (\(skipsAllowed - skipsUsed) left)")
                                            .font(.headline)
                                            .foregroundColor(appColor())
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 150)
                            
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(questionSets[currentSetIndex].questions.count), height: 8)
                                        .animation(.easeInOut, value: currentIndex)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .overlay(
                        Group {
                            if showQuitAlert {
                                ZStack {
                                    Color.black.opacity(0.5).ignoresSafeArea()
                                    VStack(spacing: 20) {
                                        Text("⚠️ Leave Quiz?")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("If you leave you'll lose your progress and your time won't be saved.")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                timerPaused = false
                                                showQuitAlert = false
                                            }) {
                                                Text("Stay")
                                                    .font(.headline)
                                                    .foregroundColor(appColor())
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                            }
                                            Button(action: {
                                                showQuitAlert = false
                                                timerPaused = false
                                                gameStarted = false
                                                categorySelected = true
                                                currentIndex = 0
                                                score = 0
                                                selectedAnswer = nil
                                                stopTimer()
                                            }) {
                                                Text("Leave")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.red.opacity(0.8))
                                                    .cornerRadius(12)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding()
                                    .background(appColor())
                                    .cornerRadius(20)
                                    .padding(.horizontal, 30)
                                                                        }
                                        }
                                }
                        )
                }
        }
}
        .sheet(isPresented: $showSettings) {
            SettingsView(isShowing: $showSettings, appColorName: $appColorName, textColorName: $textColorName)
                }
        }
}
        


#Preview {
    ContentView()
        .environmentObject(GameCenterManager.shared)
}
