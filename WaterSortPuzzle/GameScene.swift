//
//  GameScene.swift
//  WaterSortPuzzle
//
//  Created by 绫仓优希 on 2025-08-05.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene {
    var boardNode: SKNode?
    var forwardNode: SKLabelNode?
    var levelNode: SKLabelNode?
    var autoNode: SKLabelNode?
    var engine: GameEngine?
    private var lvl = 0
    private let fg = UIImpactFeedbackGenerator(style: .light)

    override func didMove(to view: SKView) {
        self.boardNode = self.childNode(withName: "board")
        self.forwardNode = self.childNode(withName: "top")?.childNode(withName: "forward") as? SKLabelNode
        self.levelNode = self.childNode(withName: "top")?.childNode(withName: "level") as? SKLabelNode
        self.autoNode = self.childNode(withName: "bottom")?.childNode(withName: "auto") as? SKLabelNode
        self.engine = GameEngine(with: self)
        self.lvl = UserDefaults.standard.integer(forKey: "last_level")
        self.levelNode?.text = "Level \(self.lvl)"
        self.autoNode?.text = self.engine?.auto ?? false ? "A" : "M"
        self.engine?.startLevel(lvl: self.lvl)
        self.fg.prepare()
        
        self.showOptions()
    }
    
    private var hideOptionsWorkItem: DispatchWorkItem?
    
    private func showOptions() {
        let top = self.childNode(withName: "top")
        let bottom = self.childNode(withName: "bottom")
        top?.isHidden = false
        bottom?.isHidden = false

        // 一段时间后隐藏按钮
        self.hideOptionsWorkItem?.cancel()
        self.hideOptionsWorkItem = DispatchWorkItem {
            top?.isHidden = true
            bottom?.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.hideOptionsWorkItem!)
    }
    
    func touchDown(atPoint pos: CGPoint) {
        guard !(self.engine?.locked ?? false) else { return }
        
        let node = self.atPoint(pos)
        
        // 显示选项按钮
        if node.name == "board" || node.name == "Scene" {
            self.showOptions()
            return
        }
        
        // 选项交互逻辑
        
        if node.name == "back" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.prevLevel()
            return
        }
        
        if node.name == "forward" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.nextLevel()
            return
        }
        
        if node.name == "reset" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.engine?.startLevel(lvl: self.lvl, reset: true)
            return
        }
        
        if node.name == "rollback" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.engine?.rollback()
            return
        }

        if node.name == "auto" {
            self.fg.impactOccurred()
            self.engine?.auto = !(self.engine?.auto ?? true)
            self.autoNode?.text = self.engine?.auto ?? false ? "A" : "M"
            return
        }
        
        // TODO: 点击level进入生成模式
        if node.name == "level" {
            self.fg.impactOccurred()
            self.fg.prepare()
            self.engine?.genMode = !(self.engine?.genMode ?? true)
            self.engine?.startLevel(lvl: -1)
            self.levelNode?.text = "Level ♾️"
            self.forwardNode?.isHidden = true
            return
        }
        
        let nodes = self.nodes(at: pos)
        
        for node in nodes {
            if let bottle = node as? GameBottle {
                self.engine?.bottleClick(bottle: bottle)
                return
            }
        }
    }
    
    func nextLevel() {
        if self.engine?.genMode ?? false {
            self.engine?.startLevel(lvl: self.lvl)
            return
        }
        
        self.lvl += 1
        if self.lvl >= GameManager.shared.levels.count {
            self.lvl = 0
        }
        
        UserDefaults.standard.set(self.lvl, forKey: "last_level")
        
        self.levelNode?.text = "Level \(self.lvl)"
        self.showOptions()
        self.engine?.startLevel(lvl: self.lvl)
    }
    
    private func prevLevel() {
        if self.engine?.genMode ?? false {
            // exit gen mode
            self.forwardNode?.isHidden = false
            self.engine?.genMode = false
        } else {
            // previous level
            self.lvl -= 1
            if self.lvl < 0 {
                self.lvl = GameManager.shared.levels.count - 1
            }
        }

        UserDefaults.standard.set(self.lvl, forKey: "last_level")
        
        self.levelNode?.text = "Level \(self.lvl)"
        self.engine?.startLevel(lvl: self.lvl)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
