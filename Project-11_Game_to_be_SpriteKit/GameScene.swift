//
//  GameScene.swift
//  Project-11_Game_to_be_SpriteKit
//
//  Created by Serhii Prysiazhnyi on 09.11.2024.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var imageName = [String]()
    var startChanceLabel: SKLabelNode!
    var startChance = 5 {
        didSet {
            startChanceLabel.text = "Yout chance: \(startChance)"
        }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for name in items {
            if name.hasPrefix("ball") {
                imageName.append(name)
            }
        }
        print(imageName)
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 5))
        makeBouncer(at: CGPoint(x: 256, y: 5))
        makeBouncer(at: CGPoint(x: 512, y: 5))
        makeBouncer(at: CGPoint(x: 768, y: 5))
        makeBouncer(at: CGPoint(x: 1024, y: 5))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        startChanceLabel = SKLabelNode(fontNamed: "Chalkduster")
        startChanceLabel.text = "Yout chance: 5"
        startChanceLabel.position = CGPoint(x: 512, y: 700)
        addChild(startChanceLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if startChance < 6 && startChance > 0 {
                if objects.contains(editLabel) {
                    editingMode.toggle()
                } else {
                    if editingMode {
                        
                        let size = CGSize(width: Int.random(in: 16...128), height: 16)
                        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                        box.zRotation = CGFloat.random(in: 0...3)
                        box.position = location
                        
                        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                        box.physicsBody?.isDynamic = false
                        
                        addChild(box)
                    } else {
                        
                        let randomeBallName = imageName.randomElement() ?? "ballRed"
                        //print(randomeBallName)
                        let ball = SKSpriteNode(imageNamed: randomeBallName)
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        
                        ball.physicsBody?.restitution = 0.6
                        ball.position = CGPoint(x: location.x, y: 700)
                        addChild(ball)
                        
                        ball.name = "ball"
                        startChance -= 1
                    }
                }
            } else {
                showGameOverAlert()
            }
        }
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            startChance += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func showGameOverAlert() {
        let alert = UIAlertController(title: "Вы проиграли", message: "Начните сначала", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.restartGame()
        })
        self.view?.window?.rootViewController?.present(alert, animated: true)
    }

    func restartGame() {
        score = 0
        startChance = 5
        // дополнительные действия для перезапуска
    }

}
