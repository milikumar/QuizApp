//
//  SettingsView.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/17/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.indigo.ignoresSafeArea()
            
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
                    // Empty space to balance the X button
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.clear)
                        .padding()
                }
                
                // Theme section coming soon
                Text("🎨 Theme")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView(isShowing: .constant(true))
}
