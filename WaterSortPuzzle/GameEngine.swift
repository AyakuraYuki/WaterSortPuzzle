//
//  GameEngine.swift
//  WaterSortPuzzle
//
//  Created by 绫仓优希 on 2025-08-05.
//

import Foundation
import SpriteKit

class GameEngine {
    struct Move {
        let from: Int
        let to: Int
        let cnt: Int
    }

    private let BOTTLE_WIDTH = 45.0
    private let BOTTLE_HEIGHT = 164.0
    private let scene: GameScene

    var auto = false
    var genMode = false
    private var currentLevel = 0
    private var bottles: [Int: GameBottle] = [:]
    private var stack: [Move] = []

    init(with scene: GameScene) {
        self.scene = scene
    }

    func startLevel(lvl: Int) {
        // reset scene
        bottles = [:]
        stack = []
        if lvl >= 0 {
            currentLevel = lvl
        }
        scene.boardNode?.removeAllChildren()

        // init level
        let level: Level
        if genMode {
            level = LevelGenerator.generateLevel()
        } else {
            level = GameManager.shared.levels[lvl]
        }

        let totalBottles = level.bottles.count + level.emptyBottles
        let totalRows = (totalBottles + 4) / 4
        let boardHeight = Double(totalRows) * BOTTLE_HEIGHT + Double(totalRows - 1) * BOTTLE_WIDTH
        let yStep = BOTTLE_HEIGHT + BOTTLE_WIDTH
        var y = boardHeight / 2.0 - BOTTLE_HEIGHT / 2.0
        var bn = 0

        for _ in 0 ..< totalRows {
            let bottlesInRow = min(4, totalBottles - bn) // bottles in each row
            let xStep = BOTTLE_WIDTH * 2.0
            let rowWidth = Double(bottlesInRow) * BOTTLE_WIDTH + Double(bottlesInRow - 1) * BOTTLE_WIDTH
            var x = -(rowWidth / 2.0) + BOTTLE_WIDTH / 2.0

            for _ in 0 ..< bottlesInRow {
                let empty = Bottle(id: bn, blocks: [])
                let gameBottle = GameBottle(with: bn < level.bottles.count ? level.bottles[bn] : empty)
                bottles[gameBottle.id] = gameBottle
                gameBottle.x = x
                gameBottle.y = y
                scene.boardNode?.addChild(gameBottle) // 添加瓶子到场景面板
                x += xStep
                bn += 1
            }

            y -= yStep
        }
    }

    func rollback() {
        guard stack.count > 0 else { return }

        let move = stack.removeLast()

        guard let from = bottles[move.from] else { return }
        guard let to = bottles[move.to] else { return }

        for _ in 0 ..< move.cnt {
            if let block = to.pop() {
                from.push(block: block)
            }
        }
    }

    private func pour(from: GameBottle, to: GameBottle, completition: @escaping () -> Void) {
        guard !from.isEmpty() else {
            scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            completition()
            return
        }

        guard !to.isFull() else {
            scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            completition()
            return
        }

        var newPosition = to.pos
        newPosition.y += (BOTTLE_HEIGHT / 2.0)
        if to.x < from.x {
            newPosition.x += (BOTTLE_HEIGHT / 2.0)
        } else {
            newPosition.x -= (BOTTLE_HEIGHT / 2.0)
        }
        let angle = to.x < from.x ? 1.396263 : -1.396263 // 动画转角

        var ok = to.isEmpty() || (from.topColor() == to.topColor() && !to.isFull())

        if ok {
            let AD = 0.5 // 动画时长
            let toEmitter = SKEmitterNode(fileNamed: "pour") // 加载动画
            var cnt = 0
            from.run(SKAction.rotate(toAngle: angle, duration: AD))
            from.run(SKAction.move(to: newPosition, duration: AD)) {
                if let emitter = toEmitter {
                    emitter.particleTexture = SKTexture(imageNamed: from.topColor()!)
                    emitter.particlePosition = CGPoint(x: 0, y: self.BOTTLE_HEIGHT * 0.5)
                    emitter.emissionAngle = 4.712389
                    to.addChild(emitter)
                }
                self.scene.run(SKAction.playSoundFileNamed("pour.wav", waitForCompletion: false))
                while to.isEmpty() || (from.topColor() == to.topColor() && !to.isFull()) {
                    ok = true
                    if let block = from.pop() {
                        to.push(block: block)
                        cnt += 1
                    }
                }

                self.stack.append(Move(from: from.id, to: to.id, cnt: cnt))

                from.run(SKAction.rotate(toAngle: 0, duration: AD))
                from.run(SKAction.move(to: from.pos, duration: AD)) {
                    toEmitter?.removeFromParent()
                    completition()
                }
            }
        } else {
            completition()
        }

        if !ok {
            scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
        }
    }

    private func deselect(bottle: GameBottle) {
        guard bottle.isSelected() else { return }
        bottle.deselect()
    }

    private func select(bottle: GameBottle) -> Bool {
        guard !bottle.isEmpty() else {
            scene.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: false))
            return false
        }

        if bottle.trySelect() {
            scene.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: false))
            return true
        }

        return false
    }

    private func isSolved() -> Bool {
        var solved = true
        for bottle in bottles.values {
            if !bottle.isEmpty() {
                solved = solved && bottle.isSolved()
            }
        }
        return solved
    }

    var locked = false

    func bottleClick(bottle: GameBottle) {
        if let selectedBottle = bottles.values.first(where: { $0.isSelected() }) {
            if selectedBottle == bottle {
                deselect(bottle: selectedBottle)
                return
            }

            locked = true

            pour(from: selectedBottle, to: bottle) {
                self.deselect(bottle: selectedBottle)
                if bottle.isSolved() {
                    bottle.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)])) // 跳动提示
                }

                if self.isSolved() {
                    self.scene.run(SKAction.playSoundFileNamed("victory.wav", waitForCompletion: false))
                    self.scene.boardNode?.run(SKAction.fadeOut(withDuration: 2.0), completion: {
                        self.scene.nextLevel()
                        self.scene.boardNode?.alpha = 1.0
                    })
                }

                self.locked = false
            }

            return
        }

        for gameBottle in bottles.values {
            if gameBottle != bottle {
                deselect(bottle: gameBottle)
            }
        }

        if bottle.isSelected() {
            deselect(bottle: bottle)
            return
        }

        if !select(bottle: bottle) {
            return
        }

        guard auto else { return }

        let topColor = bottle.topColor()
        var bs: [GameBottle] = []

        for b in bottles.values {
            if b != bottle, !b.isEmpty(), !b.isFull(), b.topColor() == topColor, bottle.popable() <= b.pushable() {
                bs.append(b)
            }
        }

        if bs.count == 1 {
            bottleClick(bottle: bs[0])
            return
        } else if bs.count == 0 {
            for b in bottles.values {
                if b.isEmpty() {
                    bottleClick(bottle: b)
                    break
                }
            }
        }
    }
}
