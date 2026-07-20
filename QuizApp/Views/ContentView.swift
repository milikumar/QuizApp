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
    @AppStorage("totalPoints") private var totalPoints = 0
    @AppStorage("totalQuizzes") private var totalQuizzes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("lastPlayedDate") private var lastPlayedDate = ""
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    @EnvironmentObject var gcManager: GameCenterManager
    @Environment(\.scenePhase) var scenePhase
    
// MARK: - Handle Answer
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
                setCounts[currentSetIndex] = (setCounts[currentSetIndex] ?? 0) + 1
                if let encoded = try? JSONEncoder().encode(setCounts) {
                    UserDefaults.standard.set(encoded, forKey: "setCounts")
                }
                gcManager.submitScore(score)
                totalPoints += score
                totalQuizzes += 1
                updateStreak()
                quizFinished = true
            }
        }
    }

    // MARK: - Button Color
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
        case "Food & Drink": return Color(red: 0.85, green: 0.1, blue: 0.1)
        case "Technology": return Color(red: 0.1, green: 0.4, blue: 0.85)
        case "Music": return Color(red: 0.4, green: 0.1, blue: 0.6)
        case "Animals": return Color(red: 0.6, green: 0.95, blue: 0.7)
        case "Video Games": return Color(red: 0.0, green: 0.0, blue: 0.5)
        case "Mythology": return Color(red: 0.7, green: 0.45, blue: 0.05)
        case "Board Games": return Color(red: 0.4, green: 0.9, blue: 0.95)
        case "Art": return Color(red: 0.98, green: 0.7, blue: 0.5)
        case "Vehicles": return Color(red: 0.27, green: 0.35, blue: 0.43)
        case "Mathematics": return Color(red: 0.1, green: 0.4, blue: 0.85)
        case "Celebrities": return Color(red: 0.98, green: 0.9, blue: 0.3)
        case "Comics": return Color(red: 0.85, green: 0.1, blue: 0.1)
        case "Anime & Manga": return Color(red: 0.95, green: 0.35, blue: 0.6)
        case "Cartoons": return Color(red: 0.9, green: 0.45, blue: 0.1)
        case "Books": return Color(red: 0.55, green: 0.35, blue: 0.15)
        case "Gadgets": return Color(red: 0.27, green: 0.35, blue: 0.43)
        case "World Cultures": return Color(red: 0.4, green: 0.1, blue: 0.6)
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
    
// MARK: - Start of Body
    var body: some View {
        // MARK: - Loading Screen
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
            
            // MARK: - Quiz Screen
        } else {
            ZStack {
                appColor().ignoresSafeArea()
                VStack {
                    HStack {
                        Button(action: {
                            gameStarted = false
                            categorySelected = true
                            currentIndex = 0
                            score = 0
                            selectedAnswer = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.75))
                                .padding()
                        }
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
                        .disabled(selectedAnswer != nil)
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
        .environmentObject(GameCenterManager.shared)
}
