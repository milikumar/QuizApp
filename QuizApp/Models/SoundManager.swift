//
//  SoundManager.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/25/26.
//

import AudioToolbox
import UIKit

final class SoundManager {
    static let shared = SoundManager()

    private let soundEffectsKey = "soundEffectsEnabled"
    private let hapticsKey = "hapticsEnabled"

    private var soundEffectsEnabled: Bool {
        UserDefaults.standard.object(forKey: soundEffectsKey) as? Bool ?? true
    }

    private var hapticsEnabled: Bool {
        UserDefaults.standard.object(forKey: hapticsKey) as? Bool ?? true
    }
    
    func playCorrect() {
        if soundEffectsEnabled {
            AudioServicesPlaySystemSound(1057)
        }
        if hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    func playWrong() {
        if soundEffectsEnabled {
            AudioServicesPlaySystemSound(1053)
        }
        if hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
        }
    }
}
