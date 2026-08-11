//
//  CategoryStatRow.swift
//  QuizApp
//
//  Created by Mili Kumar on 8/4/26.
//

import Foundation

struct CategoryStatRow: Identifiable {
    var id: String { name }
    let name: String
    let plays: Int
    let points: Int
    let perfectCount: Int
    let eliteCount: Int
    let fastestTime: Int // seconds, 0 = none yet
}
