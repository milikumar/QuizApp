//
//  SettingsView.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/17/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowing: Bool
    @Binding var appColorName: String
    @Binding var textColorName: String
    @State private var showTheme = false
    @State private var showHelp = false
    @State private var showBadges = false
    let categoryStats: [CategoryStatRow]
    @State private var showCategoryStats = false
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @EnvironmentObject var gcManager: GameCenterManager
    
    // Setting Text Color
    func settingsTextColor() -> Color {
        if appColorName == "black" { return .white }
        return textColorName == "black" ? Color.black : Color.white
    }
    
    var selectedColor: Color {
        // reuse same color lookup
        ThemePickerView.colorList.first { $0.name == appColorName }?.color ?? .indigo
    }
    
    var body: some View {
        ZStack {
            selectedColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Header
                HStack {
                    Button(action: {
                        isShowing = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(settingsTextColor().opacity(0.75))
                            .padding()
                    }
                    Spacer()
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(settingsTextColor())
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                        .padding()
                }
                
                // Menu buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showTheme = true
                    }) {
                        HStack {
                            Text("🎨 App Theme")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(settingsTextColor())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        showCategoryStats = true
                    }) {
                        HStack {
                            Text("📊 Category Stats")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(settingsTextColor())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Badges
                    Button(action: {
                        showBadges = true
                    }) {
                        HStack {
                            Text("🏅 Badges")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(settingsTextColor())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Manual
                    Button(action: {
                        showHelp = true
                    }) {
                        HStack {
                            Text("📖 Help & Manual")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(settingsTextColor())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    feedbackControls
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showTheme) {
            ThemePickerView(appColorName: $appColorName, textColorName: $textColorName)
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
                .environmentObject(gcManager)
        }
        .sheet(isPresented: $showBadges) {
            BadgesView()
        }
        .sheet(isPresented: $showCategoryStats) {
            CategoryStatsView(
                appColor: selectedColor,
                textColor: settingsTextColor(),
                stats: categoryStats
            )
        }
    }

    // MARK: - Feedback Controls
    private var feedbackControls: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔊 Feedback")
                .font(.headline)
                .foregroundColor(settingsTextColor())

            Toggle(isOn: $soundEffectsEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sound Effects")
                    Text("Correct and incorrect answer sounds")
                        .font(.caption)
                        .opacity(0.75)
                }
            }

            Divider().overlay(settingsTextColor().opacity(0.25))

            Toggle(isOn: $hapticsEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vibrations")
                    Text("Haptic feedback when answering questions")
                        .font(.caption)
                        .opacity(0.75)
                }
            }
        }
        .font(.headline)
        .foregroundColor(settingsTextColor())
        .toggleStyle(FeedbackToggleStyle())
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct FeedbackToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.label
            Spacer(minLength: 12)
            Button(action: { configuration.isOn.toggle() }) {
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(configuration.isOn ? Color.green.opacity(0.9) : Color.black.opacity(0.28))
                        .frame(width: 52, height: 32)
                    Circle()
                        .fill(.white)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.45), radius: 3, x: 0, y: 1)
                        .padding(3)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(configuration.isOn ? "On" : "Off")
        }
    }
}

#Preview {
    SettingsView(
        isShowing: .constant(true),
        appColorName: .constant("indigo"),
        textColorName: .constant("white"),
        categoryStats: []
    )
}
