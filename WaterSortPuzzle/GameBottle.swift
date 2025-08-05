//
//  GameBottle.swift
//  WaterSortPuzzle
//
//  Created by 绫仓优希 on 2025-08-05.
//

import Foundation
import SpriteKit

// MARK: - Color block

class ColorBlock: SKSpriteNode {
    var waterColor = "transparent"

    // statics
    static let BLUE = ColorBlock(with: "blue")
    static let CORAL = ColorBlock(with: "coral")
    static let CYAN = ColorBlock(with: "cyan")
    static let GREEN = ColorBlock(with: "green")
    static let NAVY = ColorBlock(with: "navy")
    static let ORANGE = ColorBlock(with: "orange")
    static let PINK = ColorBlock(with: "pink")
    static let RED = ColorBlock(with: "red")
    static let TEAL = ColorBlock(with: "teal")
    static let VIOLET = ColorBlock(with: "violet")
    static let WHITE = ColorBlock(with: "white")
    static let YELLOW = ColorBlock(with: "yellow")

    convenience init(with waterColor: String) {
        self.init(imageNamed: waterColor)
        self.waterColor = waterColor
        self.zPosition = 1
    }
}

// MARK: - Bottle

class GameBottle: SKNode {
    static let MAXIMUM_BLOCKS: Int = 4
    private let BLOCK_HEIGHT = 34.0
    private let BLOCK_BOTTOM_Y = -63.0
    private let SELECTED_BOTTLE_Y = 20.0

    var id: Int = 0
    private var blocks: [ColorBlock] = []
    private var selected = false

    var x: Double = 0 {
        didSet {
            self.position.x = self.x
        }
    }

    var y: Double = 0 {
        didSet {
            self.position.y = self.y
        }
    }

    var pos: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }

    convenience init(with bottle: Bottle) {
        self.init()
        self.id = bottle.id
        self.name = "bottle_\(bottle.id)"

        for block in bottle.blocks {
            self.push(block: ColorBlock(with: block))
        }

        let btl = SKSpriteNode(imageNamed: "bottle")
        btl.name = "btl\(bottle.id)"
        btl.zPosition = 2
        self.addChild(btl)
    }

    func isEmpty() -> Bool { return self.blocks.count == 0 }

    func isFull() -> Bool { return self.blocks.count == GameBottle.MAXIMUM_BLOCKS }

    func isSolved() -> Bool {
        return self.blocks.count == GameBottle.MAXIMUM_BLOCKS
            && self.blocks[1].waterColor == self.blocks[0].waterColor
            && self.blocks[2].waterColor == self.blocks[0].waterColor
            && self.blocks[3].waterColor == self.blocks[0].waterColor
    }

    func pushable() -> Int { return GameBottle.MAXIMUM_BLOCKS - self.blocks.count }

    func popable() -> Int {
        guard !self.isEmpty() else { return 0 }

        var result = 0
        let topColor = self.topColor()
        for i in (0 ..< self.blocks.count).reversed() {
            if self.blocks[i].waterColor == topColor {
                result += 1
                continue
            }
            break
        }

        return result
    }

    func isSelected() -> Bool { return self.selected }

    func deselect() {
        self.selected = false
        self.position.y = self.y
    }

    func trySelect() -> Bool {
        if self.selected { return false }

        self.selected = true
        self.position.y = self.y + self.SELECTED_BOTTLE_Y
        return true
    }

    func topColor() -> String? { return self.blocks.last?.waterColor }

    func pop() -> ColorBlock? {
        guard !self.isEmpty() else { return nil }

        let block = self.blocks.removeLast()
        block.removeFromParent()
        return block
    }

    func push(block: ColorBlock) {
        guard !self.isFull() else { return }

        let j = self.blocks.count
        block.name = "block\(j)"
        block.position.y = self.BLOCK_BOTTOM_Y + Double(j) * self.BLOCK_HEIGHT

        self.blocks.append(block)
        self.addChild(block)
    }
}
