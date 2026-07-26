//
//  SoundManager.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/25/26.
//

import AudioToolbox
import UIKit

class SoundManager {
    static let shared = SoundManager()
    
    func playCorrect() {
        // Sound
        AudioServicesPlaySystemSound(1057)
        // Haptic feedback (works even on silent)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    func playWrong() {
        // Sound
        AudioServicesPlaySystemSound(1053)
        // Haptic feedback (works even on silent)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
    }
}
