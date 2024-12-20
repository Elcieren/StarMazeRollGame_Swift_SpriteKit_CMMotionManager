//
//  GameScene.swift
//  Project26
//
//  Created by Eren Elçi on 25.11.2024.
//
import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortext = 8
    case finish = 16
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager!
    var isGameOver: Bool = false
    
    var gameOver: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var currentLevel = 1

    
    
    override func didMove(to view: SKView) {
        startGame()
    }
    
    
    func startGame(){
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        
        
        
        
        loadLevel()
        creatPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func loadLevel(){
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle")
        }
        
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle")
        }
        
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column , letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32 , y: (64 * row) + 32)
                
                
                if letter == "x" {
                    // load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                    
                } else if letter == "v" {
                    // load vortex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false

                    node.physicsBody?.categoryBitMask = CollisionTypes.vortext.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    addChild(node)
                    
                } else if letter == "s"{
                    // load star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "f" {
                    // load finish point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == " " {
                    //this is an empty space - do nothing
                } else {
                    fatalError("Unknow level letter: \(letter)")
                }
            }
            
        }
    }
    
    
    func creatPlayer(){
        player = SKSpriteNode(imageNamed: "player")
            player.position = CGPoint(x: 96, y: 672)
            player.zPosition = 1
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.linearDamping = 0.5

            player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortext.rawValue | CollisionTypes.finish.rawValue
            player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
            addChild(player)
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
        
        
        let tappedNodes = nodes(at: location)

            for node in tappedNodes {
                if node.name == "gameOver" { // "Tebrikler Oyun Bitti" yazısına tıklanırsa
                    startNextLevel()
                }
            }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
       #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity =  CGVector(dx: accelerometerData.acceleration.y * 50, dy: accelerometerData.acceleration.x * 50)
            
        }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player  {
            playerCollied(with: nodeB)
        } else if nodeB == player {
            playerCollied(with: nodeA)
        }
        
    }
    
    func playerCollied(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale =  SKAction.scale(by: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let squence = SKAction.sequence([move, scale, remove])
            
            player.run(squence) { [weak self] in
                self?.creatPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            if currentLevel == 1 {
                        currentLevel = 2
                        gameOver = SKLabelNode(fontNamed: "Chalkduster")
                        gameOver.text = "Tebrikler Level 1 Bitti"
                        gameOver.fontColor = .red
                        gameOver.fontSize = 56
                        gameOver.position = CGPoint(x: 500, y: 420)
                        gameOver.zPosition = 2
                        gameOver.name = "gameOver"
                        addChild(gameOver)
                    } else if currentLevel == 2 {
                        gameOver = SKLabelNode(fontNamed: "Chalkduster")
                        gameOver.text = "Oynadiginiz icin Tessekkurler Level 2 Bitti"
                        gameOver.fontColor = .red
                        gameOver.fontSize = 26
                        gameOver.position = CGPoint(x: 500, y: 420)
                        gameOver.zPosition = 2
                        gameOver.name = "gameOver"
                        addChild(gameOver)
                    }
        }
    }
    
    
    func loadLevel2(){
        guard let levelURL = Bundle.main.url(forResource: "level2", withExtension: "txt") else {
            fatalError("Could not find level1.txt in the app bundle")
        }
        
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle")
        }
        
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column , letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32 , y: (64 * row) + 32)
                
                
                if letter == "x" {
                    // load wall
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                    
                } else if letter == "v" {
                    // load vortex
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false

                    node.physicsBody?.categoryBitMask = CollisionTypes.vortext.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    addChild(node)
                    
                } else if letter == "s"{
                    // load star
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "f" {
                    // load finish point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == " " {
                    //this is an empty space - do nothing
                } else {
                    fatalError("Unknow level letter: \(letter)")
                }
            }
            
        }
    }
    
    
    func startNextLevel() {
        removeAllChildren()

            // Yeni haritayı yükle
        currentLevel = 2
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        
        
        
        
        loadLevel2()
        creatPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
            
    }
    func resetToLevel1() {
        // Remove all current nodes
        removeAllChildren()

            // Start the game from level 1
            currentLevel = 1  // Reset the level counter
            startGame()
            loadLevel()  // Load level 1 again
            creatPlayer()  // Reset player to the start position
            score = 0
    }
    
}
