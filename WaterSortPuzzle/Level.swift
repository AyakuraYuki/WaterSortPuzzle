//
//  Level.swift
//  WaterSortPuzzle
//
//  Created by 绫仓优希 on 2025-08-05.
//

class Bottle: Decodable {
    let id: Int
    let blocks: [String]

    init(id: Int, blocks: [String]) {
        self.id = id
        self.blocks = blocks
    }
}

class Level: Decodable {
    let id: Int
    let emptyBottles: Int
    let bottles: [Bottle]

    init(id: Int, emptyBottles: Int, bottles: [Bottle]) {
        self.id = id
        self.emptyBottles = emptyBottles
        self.bottles = bottles
    }
}
