//
//  LevelGenerator.swift
//  WaterSortPuzzle
//
//  Created by 绫仓优希 on 2025-08-05.
//

class LevelGenerator {
    static let colors = [
        ColorBlock.BLUE,
        ColorBlock.CORAL,
        ColorBlock.CYAN,
        ColorBlock.GREEN,
        ColorBlock.NAVY,
        ColorBlock.ORANGE,
        ColorBlock.PINK,
        ColorBlock.RED,
        ColorBlock.TEAL,
        ColorBlock.VIOLET,
        ColorBlock.WHITE,
        ColorBlock.YELLOW
    ]

    static func generateLevel() -> Level {
        let colorCnt = Int.random(in: 4 ..< 9)
        let emptyBottles = colorCnt < 6 ? 2 : 3
        let shuffleColors = colors.shuffled()
        let levelColors = shuffleColors[..<colorCnt]

        var waterBlocks = levelColors.flatMap { Array(repeating: $0, count: 4) }
        waterBlocks.shuffle()

        let bottles = (0 ..< colorCnt).map { id in
            Bottle(id: id, blocks: [])
        }

        var blockIndex = 0
        for i in 0 ..< bottles.count {
            while bottles[i].blocks.count < GameBottle.MAXIMUM_BLOCKS && blockIndex < waterBlocks.count {
                bottles[i].blocks.append(waterBlocks[blockIndex].waterColor)
                blockIndex += 1
            }
        }

        return Level(id: -1, emptyBottles: emptyBottles, bottles: bottles)
    }
}
