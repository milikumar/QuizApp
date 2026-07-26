//
//  ConfettiEffect.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/25/26.
//

import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var rotation: Double
    var scale: CGFloat
    var opacity: Double
}

struct ConfettiEffect: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                // Create particles
                for _ in 0..<80 {
                    let particle = ConfettiParticle(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: -20,
                        color: colors.randomElement()!,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.5...1.5),
                        opacity: 1.0
                    )
                    particles.append(particle)
                }
                // Animate them falling
                for i in 0..<particles.count {
                    withAnimation(
                        .easeIn(duration: Double.random(in: 1.0...2.0))
                        .delay(Double.random(in: 0...0.5))
                    ) {
                        particles[i].y = geo.size.height + 20
                        particles[i].rotation += Double.random(in: 180...540)
                        particles[i].opacity = 0
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
