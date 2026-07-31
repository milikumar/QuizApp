//
//  HelpView.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/29/26.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gcManager: GameCenterManager
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    
    // Help Text Color
    func helpTextColor() -> Color {
        if appColorName == "black" { return .white }
        return textColorName == "black" ? Color.black : Color.white
    }
    
    var body: some View {
        ZStack {
            getAppColor(appColorName).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(helpTextColor().opacity(0.75))
                            .padding()
                    }
                    Spacer()
                    Text("Help & Manual")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(helpTextColor())
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                        .padding()
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Section
                        helpSection(title: "🎮 How to Play", items: [
                            "Choose a category and difficulty to start a quiz",
                            "Answer 10 multiple choice questions",
                            "You only need 8/10 correct for a perfect score and 100% accuracy",
                            "Your timer starts when the quiz begins but can be stopped by getting 8 correct answers"
                        ])
                        
                        helpSection(title: "⏭️ Skip Button", items: [
                            "You get 2 skips per quiz",
                            "Tapping Skip reveals the correct answer without affecting your score",
                            "Skipping pauses your timer for 2 seconds — use it strategically!",
                            "Skipping is better than guessing randomly"
                        ])
                        
                        helpSection(title: "⏱️ Timer", items: [
                            "The timer counts up from the moment the quiz starts",
                            "It stops automatically when you get 8 correct answers",
                            "Getting a perfect score (8+) records your fastest time",
                            "Try to beat your fastest time for each category!"
                        ])
                        
                        helpSection(title: "⭐️ Star Ratings", items: [
                            "🌟🌟🌟 Legendary — 9 or 10 correct (Elite Score!)",
                            "⭐️⭐️⭐️ Perfect — 8 correct",
                            "⭐️⭐️ Great job — 5, 6 or 7 correct",
                            "⭐️ Not bad — 3 or 4 correct",
                            "☆ Keep trying — 2 or fewer correct"
                        ])
                        
                        helpSection(title: "🎲 Categories", items: [
                            "Choose from 20 categories across different topics",
                            "Tap Surprise Me for a random category",
                            "Most played categories appear at the top",
                            "The floating 🎲 button appears when you scroll down"
                        ])
                        
                        helpSection(title: "📵 Offline Mode", items: [
                            "If you have no internet, the app uses backup questions",
                            "Offline games don't count toward your points or stats",
                            "Your streak and play counts still update offline",
                            "A banner will appear at the top when playing offline"
                        ])
                        
                        helpSection(title: "🏆 Scoring", items: [
                            "Each correct answer earns 1 point",
                            "Points only count in online mode",
                            "Elite scores are quizzes where you got 9 or 10 correct",
                            "Perfect scores are exactly 8 correct",
                            "Your best category is tracked by total points earned"
                        ])
                        
                        helpSection(title: "⚙️ Settings", items: [
                            "Change your app theme color in Settings → App Theme",
                            "Switch between white and black text in Settings → Text Color",
                            "Access settings from the start screen or category screen"
                        ])
                        
                        // Footer note
                        Text("Still have questions? More features coming soon! 🚀")
                            .font(.caption)
                            .foregroundColor(helpTextColor().opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    func helpSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(helpTextColor())
            
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(helpTextColor().opacity(0.6))
                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(helpTextColor().opacity(0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HelpView()
        .environmentObject(GameCenterManager.shared)
}
