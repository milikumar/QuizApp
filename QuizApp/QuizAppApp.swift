//
//  QuizAppApp.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import SwiftUI
import GameKit

@main
struct QuizAppApp: App {
    
    @StateObject private var gcManager = GameCenterManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gcManager)
        }
    }
}
