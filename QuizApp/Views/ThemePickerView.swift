//
//  ThemePickerView.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/17/26.
//

import Foundation
import SwiftUI

struct ThemePickerView: View {
    @Binding var appColorName: String
    @Binding var textColorName: String
    @Environment(\.dismiss) var dismiss
    
    static let colorList: [(name: String, displayName: String, color: Color)] = [
        // Reds
        ("rose", "Rose", Color(red: 0.95, green: 0.5, blue: 0.5)),
        ("red", "Red", Color(red: 0.85, green: 0.1, blue: 0.1)),
        ("crimson", "Crimson", Color(red: 0.6, green: 0.0, blue: 0.1)),
        // Oranges
        ("peach", "Peach", Color(red: 0.98, green: 0.7, blue: 0.5)),
        ("orange", "Orange", Color(red: 0.9, green: 0.45, blue: 0.1)),
        ("sunset", "Sunset", Color(red: 0.7, green: 0.25, blue: 0.05)),
        // Yellows/Golds
        ("yellow", "Yellow", Color(red: 0.98, green: 0.9, blue: 0.3)),
        ("gold", "Gold", Color(red: 0.85, green: 0.65, blue: 0.13)),
        ("amber", "Amber", Color(red: 0.7, green: 0.45, blue: 0.05)),
        // Greens
        ("mint", "Mint", Color(red: 0.6, green: 0.95, blue: 0.7)),
        ("green", "Green", Color(red: 0.1, green: 0.7, blue: 0.2)),
        ("forest", "Forest", Color(red: 0.05, green: 0.35, blue: 0.1)),
        // Teals/Cyans
        ("cyan", "Cyan", Color(red: 0.4, green: 0.9, blue: 0.95)),
        ("teal", "Teal", Color(red: 0.1, green: 0.6, blue: 0.65)),
        ("darkTeal", "Dark Teal", Color(red: 0.05, green: 0.35, blue: 0.4)),
        // Blues
        ("sky", "Sky", Color(red: 0.5, green: 0.75, blue: 0.98)),
        ("blue", "Blue", Color(red: 0.1, green: 0.4, blue: 0.85)),
        ("navy", "Navy", Color(red: 0.05, green: 0.1, blue: 0.5)),
        // Purples/Indigos
        ("lavender", "Lavender", Color(red: 0.7, green: 0.6, blue: 0.95)),
        ("indigo", "Indigo (Default)", .indigo),
        ("violet", "Violet", Color(red: 0.4, green: 0.1, blue: 0.6)),
        // Pinks
        ("lightPink", "Light Pink", Color(red: 0.98, green: 0.7, blue: 0.85)),
        ("pink", "Pink", Color(red: 0.95, green: 0.35, blue: 0.6)),
        ("hotPink", "Hot Pink", Color(red: 0.8, green: 0.1, blue: 0.45)),
        // Browns
        ("tan", "Tan", Color(red: 0.82, green: 0.68, blue: 0.52)),
        ("brown", "Brown", Color(red: 0.55, green: 0.35, blue: 0.15)),
        ("darkBrown", "Dark Brown", Color(red: 0.3, green: 0.15, blue: 0.05)),
        // Greys/Blacks
        ("silver", "Silver", Color(red: 0.75, green: 0.75, blue: 0.75)),
        ("slate", "Slate", Color(red: 0.4, green: 0.4, blue: 0.45)),
        ("black", "Midnight", Color(red: 0.1, green: 0.1, blue: 0.15)),
    ]
    let colors = ThemePickerView.colorList
                                
    var selectedColor: Color {
        colors.first { $0.name == appColorName }?.color ?? .indigo
    }
    
    func pickerTextColor() -> Color {
        if appColorName == "black" { return .white }
        return textColorName == "black" ? Color.black : Color.white
    }
    
    var body: some View {
        ZStack {
            selectedColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.75))
                            .padding()
                    }
                    Spacer()
                    Text("App Theme")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                        .padding()
                }
                
                // Color grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(colors, id: \.name) { item in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(item.color)
                                .frame(height: 70)
                                .overlay(
                                    Text(item.displayName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white, lineWidth: appColorName == item.name ? 4 : 0)
                                )
                                .onTapGesture {
                                    appColorName = item.name
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Text Color
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✏️ Text Color")
                            .font(.headline)
                            .foregroundColor(pickerTextColor())
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
                                textColorName = "black"
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
                            .disabled(appColorName == "black")
                            .opacity(appColorName == "black" ? 0.45 : 1)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Reset
                    VStack(spacing: 6) {
                        Button(action: {
                            appColorName = "indigo"
                            textColorName = "white"
                        }) {
                            Text("↺ Reset Theme")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                        Text("Resets app color and text color only — your stats and progress are untouched")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    ThemePickerView(appColorName: .constant("indigo"), textColorName: .constant("white"))
}
