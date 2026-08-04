//
//  Badges.swift
//  QuizApp
//

import Foundation

struct Badge: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let group: BadgeGroup
}

enum BadgeGroup: String, CaseIterable, Identifiable {
    case completion = "🎯 Completion"
    case score = "⭐️ Score"
    case speed = "⚡️ Speed"
    case streak = "🔥 Streak"
    case master = "👑 Master"

    var id: String { rawValue }
}

enum BadgeCatalog {
    static let all: [Badge] = [
        Badge(id: "first-step", name: "First Step", description: "Complete your first quiz.", icon: "👣", group: .completion),
        Badge(id: "category-loyal", name: "Category Loyal", description: "Play any one category 10 times.", icon: "🎯", group: .completion),
        Badge(id: "explorer", name: "Explorer", description: "Play 5 different categories at least once each.", icon: "🧭", group: .completion),
        Badge(id: "scholar", name: "Scholar", description: "Complete every category at least once.", icon: "📚", group: .completion),
        Badge(id: "category-obsessed", name: "Category Obsessed", description: "Play any one category 50 times.", icon: "🤩", group: .completion),
        Badge(id: "century", name: "Century", description: "Complete 100 quizzes.", icon: "💯", group: .completion),

        Badge(id: "perfect", name: "Perfect", description: "Earn your first perfect score: 8 or more correct out of 10.", icon: "⭐️", group: .score),
        Badge(id: "legend", name: "Legend", description: "Earn your first Elite score: 9 or 10 correct out of 10.", icon: "🌟", group: .score),
        Badge(id: "big-brain", name: "Big Brain", description: "Earn 100 total lifetime points.", icon: "🧠", group: .score),
        Badge(id: "champion", name: "Champion", description: "Earn 10 perfect scores: 8 or more correct out of 10.", icon: "🏆", group: .score),
        Badge(id: "hard-elite", name: "Hard Elite", description: "Earn an Elite score of 9 or 10 while playing on Hard difficulty.", icon: "💪", group: .score),
        Badge(id: "legendary", name: "Legendary", description: "Earn 10 Elite scores: 9 or 10 correct out of 10.", icon: "👑", group: .score),
        Badge(id: "elite-avg", name: "Elite Avg", description: "Score 8 or more in 3 quizzes in a row.", icon: "📈", group: .score),
        Badge(id: "quiz-royale", name: "Quiz Royale", description: "Earn 500 total lifetime points.", icon: "♛", group: .score),

        Badge(id: "quick", name: "Quick", description: "Finish a quiz with 8 or more correct in under 1 minute.", icon: "⏱️", group: .speed),
        Badge(id: "speed-demon", name: "Speed Demon", description: "Finish a quiz with 8 or more correct in under 45 seconds.", icon: "💨", group: .speed),
        Badge(id: "lightning", name: "Lightning", description: "Finish a quiz with 8 or more correct in under 30 seconds.", icon: "⚡️", group: .speed),

        Badge(id: "on-fire", name: "On Fire", description: "Reach a 3-day play streak.", icon: "🔥", group: .streak),
        Badge(id: "hot-streak", name: "Hot Streak", description: "Reach a 7-day play streak.", icon: "🌋", group: .streak),
        Badge(id: "dedicated", name: "Dedicated", description: "Reach a 10-day play streak.", icon: "📅", group: .streak),
        Badge(id: "unstoppable", name: "Unstoppable", description: "Reach a 20-day play streak.", icon: "🚀", group: .streak),
        Badge(id: "legend-streak", name: "Legend Streak", description: "Reach a 30-day play streak.", icon: "🏅", group: .streak),

        Badge(id: "master-mind", name: "Master Mind", description: "Earn every other badge.", icon: "👑", group: .master)
    ]

    static let masterMindID = "master-mind"
}

struct BadgeProgressSnapshot {
    let onlineCategoryPlayCounts: [Int: Int]
    let categoryCount: Int
    let totalQuizzes: Int
    let totalPoints: Int
    let perfectScores: Int
    let eliteScores: Int
    let hardEliteEarned: Bool
    let consecutiveEliteAverageCount: Int
    let fastestPerfectTime: Int
    let currentStreak: Int
}

enum BadgeProgress {
    static func decodeIDs(_ data: String) -> Set<String> {
        Set(data.split(separator: "|").map(String.init))
    }

    static func encodeIDs(_ ids: Set<String>) -> String {
        ids.sorted().joined(separator: "|")
    }

    static func decodeCategoryCounts(_ data: String) -> [Int: Int] {
        guard let encoded = data.data(using: .utf8),
              let counts = try? JSONDecoder().decode([Int: Int].self, from: encoded) else { return [:] }
        return counts
    }

    static func encodeCategoryCounts(_ counts: [Int: Int]) -> String {
        guard let data = try? JSONEncoder().encode(counts), let encoded = String(data: data, encoding: .utf8) else { return "" }
        return encoded
    }

    static func awardedBadgeIDs(existing: Set<String>, snapshot: BadgeProgressSnapshot) -> Set<String> {
        var earned = existing
        let categoryCounts = snapshot.onlineCategoryPlayCounts.values

        if snapshot.totalQuizzes >= 1 { earned.insert("first-step") }
        if categoryCounts.contains(where: { $0 >= 10 }) { earned.insert("category-loyal") }
        if categoryCounts.filter({ $0 >= 1 }).count >= 5 { earned.insert("explorer") }
        if snapshot.categoryCount > 0 && categoryCounts.filter({ $0 >= 1 }).count >= snapshot.categoryCount { earned.insert("scholar") }
        if categoryCounts.contains(where: { $0 >= 50 }) { earned.insert("category-obsessed") }
        if snapshot.totalQuizzes >= 100 { earned.insert("century") }

        if snapshot.perfectScores >= 1 { earned.insert("perfect") }
        if snapshot.eliteScores >= 1 { earned.insert("legend") }
        if snapshot.totalPoints >= 100 { earned.insert("big-brain") }
        if snapshot.perfectScores >= 10 { earned.insert("champion") }
        if snapshot.hardEliteEarned { earned.insert("hard-elite") }
        if snapshot.eliteScores >= 10 { earned.insert("legendary") }
        if snapshot.consecutiveEliteAverageCount >= 3 { earned.insert("elite-avg") }
        if snapshot.totalPoints >= 500 { earned.insert("quiz-royale") }

        if snapshot.fastestPerfectTime > 0 && snapshot.fastestPerfectTime < 60 { earned.insert("quick") }
        if snapshot.fastestPerfectTime > 0 && snapshot.fastestPerfectTime < 45 { earned.insert("speed-demon") }
        if snapshot.fastestPerfectTime > 0 && snapshot.fastestPerfectTime < 30 { earned.insert("lightning") }

        addStreakBadges(to: &earned, currentStreak: snapshot.currentStreak)

        awardMasterMindIfEligible(to: &earned)
        return earned
    }

    static func awardedStreakBadgeIDs(existing: Set<String>, currentStreak: Int) -> Set<String> {
        var earned = existing
        addStreakBadges(to: &earned, currentStreak: currentStreak)
        awardMasterMindIfEligible(to: &earned)
        return earned
    }

    private static func addStreakBadges(to earned: inout Set<String>, currentStreak: Int) {
        if currentStreak >= 3 { earned.insert("on-fire") }
        if currentStreak >= 7 { earned.insert("hot-streak") }
        if currentStreak >= 10 { earned.insert("dedicated") }
        if currentStreak >= 20 { earned.insert("unstoppable") }
        if currentStreak >= 30 { earned.insert("legend-streak") }
    }

    private static func awardMasterMindIfEligible(to earned: inout Set<String>) {
        let nonMasterBadgeIDs = Set(BadgeCatalog.all.map(\.id)).subtracting([BadgeCatalog.masterMindID])
        if nonMasterBadgeIDs.isSubset(of: earned) { earned.insert(BadgeCatalog.masterMindID) }
    }
}
