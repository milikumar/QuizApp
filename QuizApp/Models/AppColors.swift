//
//  AppColors.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/29/26.
//

import SwiftUI

func getAppColor(_ name: String) -> Color {
    switch name {
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
    default: return .indigo
    }
}

func getAppTextColor(_ colorName: String, _ textName: String) -> Color {
    if colorName == "black" { return .white }
    return textName == "black" ? Color.black : Color.white
}
