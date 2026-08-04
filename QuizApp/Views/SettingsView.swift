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
    }
}

#Preview {
    SettingsView(isShowing: .constant(true), appColorName: .constant("indigo"), textColorName: .constant("white"))
}
