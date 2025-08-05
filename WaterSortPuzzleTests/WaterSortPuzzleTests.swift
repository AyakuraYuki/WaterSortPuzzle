//
//  WaterSortPuzzleTests.swift
//  WaterSortPuzzleTests
//
//  Created by 绫仓优希 on 2025-08-05.
//

import Testing
@testable import WaterSortPuzzle

struct WaterSortPuzzleTests {
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func randomColors() async throws {
        let colorCnt = Int.random(in: 4 ..< 10)
        let emptyBottles = colorCnt < 6 ? 2 : 3
        let shuffleColors = LevelGenerator.colors.shuffled()
        let levelColors = shuffleColors[..<colorCnt]

        #expect(levelColors.count == colorCnt)
        #expect(emptyBottles == (colorCnt < 6 ? 2 : 3))
    }
}
