//
//  BadgesView.swift
//  QuizApp
//

import SwiftUI

struct BadgesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appColor") private var appColorName = "indigo"
    @AppStorage("textColor") private var textColorName = "white"
    @AppStorage("earnedBadges") private var earnedBadgesData = ""
    @AppStorage("onlineCategoryPlayCounts") private var onlineCategoryPlayCountsData = ""
    @AppStorage("totalPoints") private var totalPoints = 0
    @AppStorage("totalQuizzes") private var totalQuizzes = 0
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("perfectScores") private var perfectScores = 0
    @AppStorage("eliteScores") private var eliteScores = 0
    @AppStorage("hardEliteEarned") private var hardEliteEarned = false
    @AppStorage("consecutiveEliteAverageCount") private var consecutiveEliteAverageCount = 0
    @AppStorage("fastestPerfectTime") private var fastestPerfectTime = 0
    @State private var selectedBadge: Badge?

    private var textColor: Color { getAppTextColor(appColorName, textColorName) }
    private var earnedBadgeIDs: Set<String> { BadgeProgress.decodeIDs(earnedBadgesData) }

    var body: some View {
        ZStack {
            getAppColor(appColorName).ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Text("\(earnedBadgeIDs.count)/\(BadgeCatalog.all.count) Badges Claimed")
                    .font(.headline).foregroundColor(textColor).padding(.vertical, 12)
                badgeList
            }
        }
        .onAppear(perform: refreshEarnedBadges)
        .alert(item: $selectedBadge) { badge in
            let isEarned = earnedBadgeIDs.contains(badge.id)
            return Alert(
                title: Text(isEarned ? "\(badge.name) Earned!" : badge.name),
                message: Text(isEarned ? "You have claimed this badge. \(badge.description)" : badge.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(textColor.opacity(0.75)).padding()
            }
            Spacer()
            Text("Badges").font(.title2).fontWeight(.bold).foregroundColor(textColor)
            Spacer()
            Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.clear).padding()
        }
    }

    // MARK: - Badge List
    private var badgeList: some View {
        List {
            ForEach(BadgeGroup.allCases) { group in
                Section(group.rawValue) {
                    ForEach(BadgeCatalog.all.filter { $0.group == group }) { badge in
                        BadgeRow(badge: badge, isEarned: earnedBadgeIDs.contains(badge.id), textColor: textColor)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedBadge = badge }
                            .listRowBackground(Color.clear)
                    }
                }
                .listSectionSeparator(.hidden)
                .foregroundStyle(textColor)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Progress Refresh
    private func refreshEarnedBadges() {
        let snapshot = BadgeProgressSnapshot(
            onlineCategoryPlayCounts: BadgeProgress.decodeCategoryCounts(onlineCategoryPlayCountsData),
            categoryCount: questionSets.count,
            totalQuizzes: totalQuizzes,
            totalPoints: totalPoints,
            perfectScores: perfectScores,
            eliteScores: eliteScores,
            hardEliteEarned: hardEliteEarned,
            consecutiveEliteAverageCount: consecutiveEliteAverageCount,
            fastestPerfectTime: fastestPerfectTime,
            currentStreak: currentStreak
        )
        earnedBadgesData = BadgeProgress.encodeIDs(
            BadgeProgress.awardedBadgeIDs(existing: earnedBadgeIDs, snapshot: snapshot)
        )
    }
}

private struct BadgeRow: View {
    let badge: Badge
    let isEarned: Bool
    let textColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(badge.icon).font(.system(size: 32)).frame(width: 40)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(badge.name).font(.headline)
                    Spacer()
                    if isEarned { Image(systemName: "checkmark.seal.fill").foregroundStyle(.green) }
                }
                Text(badge.description).font(.subheadline).foregroundStyle(textColor.opacity(0.88)).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
        .saturation(isEarned ? 1 : 0)
        .opacity(isEarned ? 1 : 0.62)
    }
}

#Preview {
    BadgesView()
}
