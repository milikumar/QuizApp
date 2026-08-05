//
//  TutorialManager.swift
//  QuizApp
//

import Combine
import CoreGraphics
import Foundation
import SwiftUI

enum TutorialStep: Int, CaseIterable {
    case settings
    case play
    case categoryHome
    case surpriseMe
    case difficulty
    case timer
    case exit
    case skip
    case results
    case closing

    var message: String {
        switch self {
        case .settings: "Customize your theme and more!"
        case .play: "Tap Play to start!"
        case .categoryHome: "Go back to the start screen anytime"
        case .surpriseMe: "Feeling lucky? Let us pick a category for you!"
        case .difficulty: "Choose your difficulty and tap to begin!"
        case .timer: "Your time is tracked — get 8 correct to stop the clock!"
        case .exit: "Exit anytime — but you'll lose your progress!"
        case .skip: "You get 2 skips per quiz — use them wisely! Skipping even saves you 2 seconds on the clock."
        case .results: "Here's your score, time, and accuracy — see how you did!"
        case .closing: "For more info, check the Manual and Badges in Settings! The Manual also explains offline mode and category play counts. Happy quizzing! 🎉"
        }
    }

    var requiresInteraction: Bool {
        switch self {
        case .play, .surpriseMe, .difficulty: true
        default: false
        }
    }

    var target: TutorialTarget? {
        switch self {
        case .settings: .settings
        case .play: .play
        case .categoryHome: .categoryHome
        case .surpriseMe: .surpriseMe
        case .difficulty: .difficulty
        case .timer: .timer
        case .exit: .exit
        case .skip: .skip
        case .results: .results
        case .closing: nil
        }
    }
}

enum TutorialTarget: Hashable {
    case settings
    case play
    case categoryHome
    case surpriseMe
    case difficulty
    case timer
    case exit
    case skip
    case results
}

final class TutorialManager: ObservableObject {
    @Published private(set) var step: TutorialStep?

    var isActive: Bool { step != nil }

    func start() {
        step = .settings
    }

    func advance() {
        guard let step, let nextStep = TutorialStep(rawValue: step.rawValue + 1) else { return }
        self.step = nextStep
    }

    func advanceAfterPlay() {
        guard step == .play else { return }
        step = .categoryHome
    }

    func advanceAfterSurpriseMe() {
        guard step == .surpriseMe else { return }
        step = .difficulty
    }

    func advanceAfterDifficulty() {
        guard step == .difficulty else { return }
        step = .timer
    }

    func complete() {
        step = nil
    }
}

struct TutorialAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [TutorialTarget: CGRect] = [:]

    static func reduce(value: inout [TutorialTarget: CGRect], nextValue: () -> [TutorialTarget: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}
