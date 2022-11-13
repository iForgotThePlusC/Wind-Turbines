//
//  GameScene.swift
//  WindTurbines
//
//  Created by Yicheng Xia on 12/11/2022.
//

import SpriteKit

class GameScene: SKScene {
    
    var mathsModel: TurbineModel?
    var turbineNodes: [TurbineNode] = []
    
    var upButton: SKSpriteNode?
    var downButton: SKSpriteNode?
    var numLabel: SKLabelNode?
    var powerLabel: SKLabelNode?
    var maxPowerLabel: SKLabelNode?
    
    var deltaLabel: SKLabelNode?
    var descSpeedLabel: SKLabelNode?
    var deltaUpButton: SKSpriteNode?
    var deltaDownButton: SKSpriteNode?
    var descSpeedUpButton: SKSpriteNode?
    var descSpeedDownButton: SKSpriteNode?
    
    var n: Int = 10
    var delta: CGFloat = 1.0
    var descSpeed: CGFloat = 15.0
    
    var uniformWind: Bool = true
    
    override func didMove(to view: SKView) {
        
        upButton = childNode(withName: "upButton") as? SKSpriteNode
        downButton = childNode(withName: "downButton") as? SKSpriteNode
        numLabel = childNode(withName: "numLabel") as? SKLabelNode
        powerLabel = childNode(withName: "powerLabel") as? SKLabelNode
        maxPowerLabel = childNode(withName: "maxPowerLabel") as? SKLabelNode
        
        deltaLabel = childNode(withName: "deltaLabel") as? SKLabelNode
        descSpeedLabel = childNode(withName: "descSpeedLabel") as? SKLabelNode
        deltaUpButton = childNode(withName: "deltaUp") as? SKSpriteNode
        deltaDownButton = childNode(withName: "deltaDown") as? SKSpriteNode
        descSpeedUpButton = childNode(withName: "descSpeedUp") as? SKSpriteNode
        descSpeedDownButton = childNode(withName: "descSpeedDown") as? SKSpriteNode

        initialise(n: n)
    }
    
    func initialise(n: Int) {
        self.n = n
        let r: CGFloat = 40
        
        mathsModel = TurbineModel(n: n, radius: r, k: 0.5, boundary: Rectangle(width: 800, height: 800))
        updateDelta(self.delta)
        updateDescendSpeed(self.descSpeed)
        
        for n in turbineNodes {
            n.removeFromParent()
        }
        turbineNodes = []
        for _ in 1...n {
            let n = TurbineNode(radius: r)
            turbineNodes.append(n)
            addChild(n)
        }
        
        numLabel?.text = String(n)
        
        let maxPower: CGFloat = 2 * r * 0.5 * CGFloat(n)
        maxPowerLabel?.text = String(format: "%.3f", maxPower)
        
        mathsModel?.randomise()
        updateVisual()
    }
    
    func updateDelta(_ d: CGFloat) {
        self.delta = d
        mathsModel!.delta = d
        deltaLabel?.text = String(format: "%.3f", delta)
    }
    
    func updateDescendSpeed(_ ds: CGFloat) {
        self.descSpeed = ds
        mathsModel!.descendSpeed = ds
        descSpeedLabel?.text = String(format: "%.3f", descSpeed)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first!.location(in: self)
        
        if upButton!.frame.contains(loc) {
            initialise(n: min(n + 1, 50))
            
        } else if downButton!.frame.contains(loc) {
            initialise(n: max(n - 1, 1))
            
        } else if deltaUpButton!.frame.contains(loc) {
            updateDelta(self.delta * 2)
            
        } else if deltaDownButton!.frame.contains(loc) {
            updateDelta(self.delta / 2)
            
        } else if descSpeedUpButton!.frame.contains(loc) {
            updateDescendSpeed(self.descSpeed * 2)
            
        } else if descSpeedDownButton!.frame.contains(loc) {
            updateDescendSpeed(self.descSpeed / 2)
        }
    }
    
    func updateVisual() {
        for (i, p) in mathsModel!.positions.enumerated() {
            turbineNodes[i].position = CGPoint(x: p.x, y: p.y)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        mathsModel!.gradientDescent()
        powerLabel?.text = String(format: "%.3f", mathsModel!.currPower)
        updateVisual()
    }

}
