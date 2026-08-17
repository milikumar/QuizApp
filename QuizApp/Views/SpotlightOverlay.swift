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
    let onCancel: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let overlayFrame = proxy.frame(in: .global)
            let spotlightFrame = resolvedSpotlightFrame.map {
                $0.offsetBy(dx: -overlayFrame.minX, dy: -overlayFrame.minY)
            }
            ZStack(alignment: .topTrailing) {
                if let spotlightFrame {
                    let fullScreenCutout = spotlightFrame
                        .insetBy(dx: -8, dy: -8)
                        .offsetBy(dx: proxy.safeAreaInsets.leading, dy: proxy.safeAreaInsets.top)
                    SpotlightCutout(cutout: fullScreenCutout)
                        .fill(.black.opacity(0.68), style: FillStyle(eoFill: true))
                        .ignoresSafeArea()
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

                SkipButton(action: onCancel)
                    .padding(.top, 8)
                    .padding(.trailing, 16)
            }
        }
    }

    private var resolvedSpotlightFrame: CGRect? {
        guard let target = step.target else { return nil }
        return anchorFrames[target]
    }
}

// MARK: - Skip Control

private struct SkipButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Skip Tutorial")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.black.opacity(0.6))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
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
                Button(action: step == .closing ? onDone : onNext) {
                    Text(step == .closing ? "Done" : "Next")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
