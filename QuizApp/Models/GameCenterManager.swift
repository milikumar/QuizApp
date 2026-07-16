//
//  GameCenterManager.swift
//  QuizApp
//
//  Created by Mili Kumar on 7/13/26.
//

import GameKit
import Combine

class GameCenterManager: NSObject, ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var playerName = ""
    
    static let shared = GameCenterManager()
    
    // Your leaderboard ID from App Store Connect
    let leaderboardID = "com.cleverrmind.score"
    
    func authenticatePlayer(from viewController: UIViewController) {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { vc, error in
            if let vc = vc {
                viewController.present(vc, animated: true)
            } else if player.isAuthenticated {
                self.isAuthenticated = true
                self.playerName = player.displayName
            }
        }
    }
    
    func submitScore(_ score: Int) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error)")
            }
        }
    }
    
    func showLeaderboard() {
        GKAccessPoint.shared.trigger(state: .leaderboards) {}
    }
}
