//
//  ShimmerEffect.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/18/26.
//

import SwiftUI

struct GlitterModifier: ViewModifier {
    @State private var sparkles: [Sparkle] = []
    
    struct Sparkle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    ZStack {
                        ForEach(sparkles) { sparkle in
                            Text("✦")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .opacity(sparkle.opacity)
                                .scaleEffect(sparkle.scale)
                                .position(x: sparkle.x, y: sparkle.y)
                        }
                    }
                    .onAppear {
                        startGlitter(in: geo.size)
                    }
                }
                    .clipped()
            )
    }
    
    func startGlitter(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            let newSparkle = Sparkle(
                x: CGFloat.random(in: 10...size.width - 10),
                y: Bool.random() ?
                    CGFloat.random(in: 0...size.height * 0.25) :
                    CGFloat.random(in: size.height * 0.75...size.height),
                opacity: 0.0,
                scale: CGFloat.random(in: 0.5...1.5)
            )
            sparkles.append(newSparkle)
            
            // Fade in gently
            withAnimation(.easeIn(duration: 0.4)) {
                if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                    sparkles[index].opacity = 1.0
                }
            }
            
            // Then fade out slowly
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                if let index = sparkles.firstIndex(where: { $0.id == newSparkle.id }) {
                    sparkles[index].opacity = 0
                }
            }
            
            // Remove after fully faded
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                sparkles.removeAll { $0.id == newSparkle.id }
            }
        }
    }
}
extension View {
    func glittering() -> some View {
        modifier(GlitterModifier())
    }
}
