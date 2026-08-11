//
//  CategoryStatsView.swift
//  QuizApp
//
//  Created by Mili Kumar on 8/4/26.
//

import SwiftUI

struct CategoryStatsView: View {
    let appColor: Color
    let textColor: Color
    let stats: [CategoryStatRow]
    @Environment(\.dismiss) var dismiss

    private var sortedStats: [CategoryStatRow] {
        stats.sorted { $0.points > $1.points }
    }

    var body: some View {
        ZStack {
            appColor.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sortedStats) { row in
                            CategoryStatCard(row: row, textColor: textColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(textColor.opacity(0.75))
                    .padding()
            }
            Spacer()
            Text("Category Stats")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            Spacer()
            Image(systemName: "chevron.left.circle.fill")
                .font(.title2)
                .foregroundColor(.clear)
                .padding()
        }
    }
}

private struct CategoryStatCard: View {
    let row: CategoryStatRow
    let textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(row.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(textColor)

            HStack(spacing: 12) {
                statBlock(value: "\(row.plays)", label: "Plays")
                statBlock(value: "\(row.points)", label: "Points")
                statBlock(value: "\(row.perfectCount)", label: "Perfects")
                statBlock(value: "\(row.eliteCount)", label: "Elite")
            }

            Text("⚡️ Fastest: \(row.fastestTime == 0 ? "—" : formatTime(row.fastestTime))")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    CategoryStatsView(
        appColor: .indigo,
        textColor: .white,
        stats: [
            CategoryStatRow(name: "History", plays: 12, points: 84, perfectCount: 5, eliteCount: 2, fastestTime: 47),
            CategoryStatRow(name: "Science & Nature", plays: 3, points: 18, perfectCount: 0, eliteCount: 0, fastestTime: 0)
        ]
    )
}
