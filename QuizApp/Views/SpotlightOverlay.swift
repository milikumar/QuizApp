//
//  SpotlightOverlay.swift
//  QuizApp
//

import SwiftUI

struct SpotlightOverlay: View {
    let step: TutorialStep
    let anchorFrames: [TutorialTarget: CGRect]
    let onNext: () -> Void
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let spotlightFrame = resolvedSpotlightFrame(in: proxy.size)
            ZStack {
                if let spotlightFrame {
                    SpotlightCutout(cutout: spotlightFrame.insetBy(dx: -8, dy: -8))
                        .fill(.black.opacity(0.68), style: FillStyle(eoFill: true))
                        .allowsHitTesting(false)
                } else {
                    Color.black.opacity(0.68).ignoresSafeArea().allowsHitTesting(false)
                }

                TutorialCallout(
                    step: step,
                    spotlightFrame: spotlightFrame,
                    containerSize: proxy.size,
                    onNext: onNext,
                    onDone: onDone
                )
            }
        }
        .ignoresSafeArea()
    }

    private func resolvedSpotlightFrame(in size: CGSize) -> CGRect? {
        guard let target = step.target else { return nil }
        return anchorFrames[target] ?? fallbackFrame(for: target, in: size)
    }

    private func fallbackFrame(for target: TutorialTarget, in size: CGSize) -> CGRect {
        switch target {
        case .settings: CGRect(x: size.width * 0.08, y: size.height * 0.82, width: size.width * 0.84, height: 56)
        case .play: CGRect(x: size.width * 0.22, y: size.height * 0.62, width: size.width * 0.56, height: 60)
        case .categoryHome, .exit: CGRect(x: 8, y: 42, width: 54, height: 54)
        case .surpriseMe: CGRect(x: size.width * 0.06, y: size.height * 0.23, width: size.width * 0.88, height: 54)
        case .difficulty: CGRect(x: size.width * 0.06, y: size.height * 0.30, width: size.width * 0.88, height: size.height * 0.32)
        case .timer: CGRect(x: size.width * 0.38, y: 44, width: size.width * 0.24, height: 40)
        case .skip: CGRect(x: size.width * 0.06, y: size.height * 0.68, width: size.width * 0.88, height: 52)
        case .results: CGRect(x: size.width * 0.05, y: size.height * 0.11, width: size.width * 0.90, height: size.height * 0.56)
        }
    }
}

// MARK: - Callout

private struct TutorialCallout: View {
    let step: TutorialStep
    let spotlightFrame: CGRect?
    let containerSize: CGSize
    let onNext: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(step.message)
                .font(.headline)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            if !step.requiresInteraction {
                Button(step == .closing ? "Done" : "Next", action: step == .closing ? onDone : onNext)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .frame(width: min(300, containerSize.width - 40), alignment: .leading)
        .background(.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.25), lineWidth: 1))
        .position(calloutPosition)
        .allowsHitTesting(!step.requiresInteraction)
    }

    private var calloutPosition: CGPoint {
        guard let spotlightFrame else {
            return CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
        }
        let width = min(300, containerSize.width - 40)
        let x = min(max(spotlightFrame.midX, width / 2 + 20), containerSize.width - width / 2 - 20)
        let prefersBelow = spotlightFrame.maxY < containerSize.height * 0.62
        let y = prefersBelow
            ? min(spotlightFrame.maxY + 105, containerSize.height - 110)
            : max(spotlightFrame.minY - 105, 110)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Spotlight Shape

private struct SpotlightCutout: Shape {
    let cutout: CGRect

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addRoundedRect(in: cutout, cornerSize: CGSize(width: 14, height: 14))
        return path
    }
}

extension View {
    func tutorialAnchor(_ target: TutorialTarget) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: TutorialAnchorPreferenceKey.self,
                    value: [target: proxy.frame(in: .global)]
                )
            }
        }
    }
}
