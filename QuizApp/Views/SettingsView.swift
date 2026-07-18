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
                            .foregroundColor(.white.opacity(0.75))
                            .padding()
                    }
                    Spacer()
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Badges coming soon
                    }) {
                        HStack {
                            Text("🏅 Badges")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Text Color
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✏️ Text Color")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if appColorName != "black" {
                                    textColorName = "white"
                                }
                            }) {
                                Text("White")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(textColorName == "white" ? Color.yellow : Color.clear, lineWidth: 3)
                                    )
                            }
                            
                            Button(action: {
                                if appColorName != "black" {
                                    textColorName = "black"
                                }
                            }) {
                                Text("Black")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(textColorName == "black" && appColorName != "black" ? Color.yellow : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showTheme) {
            ThemePickerView(appColorName: $appColorName)
        }
    }
}

#Preview {
    SettingsView(isShowing: .constant(true), appColorName: .constant("indigo"), textColorName: .constant("white"))
}
