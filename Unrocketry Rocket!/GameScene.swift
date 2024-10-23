//
//  GameScene.swift
//  Unrocketry Rocket!
//
//  Created by Kamil Stobiecki on 22/10/2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var rocket: SKSpriteNode!
    private var obstacles: [SKSpriteNode] = []
    private var scoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var restartButton: SKLabelNode!
    
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0
    private var obstacleSpeed: CGFloat = 200
    private var rocketDirection: CGFloat = 1.0 // 1 for right, -1 for left
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var isGameOver = false
    
    // Category bitmasks for collision detection
    let rocketCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    
    private var rocketTotalRotation: CGFloat = 0
    private let maxRotationAngle: CGFloat = .pi / 3 // 60 degrees in radians
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupRocket()
        setupScoreLabel()
        setupGameOverLabel()
        setupRestartButton()
        startBackgroundMusic()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    private func setupRocket() {
        rocket = SKSpriteNode(imageNamed: "rocket")
        rocket.size = CGSize(width: 40, height: 60)
        rocket.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
        rocket.zRotation = -.pi / 2 // Point upwards
        
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.physicsBody?.isDynamic = false
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.contactTestBitMask = obstacleCategory
        rocket.physicsBody?.collisionBitMask = 0
        
        addChild(rocket)
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        
        let topPadding: CGFloat = 70  // Adjust this value for different devices
        let leftPadding: CGFloat = 20
        
        scoreLabel.position = CGPoint(x: frame.minX + leftPadding, y: frame.maxY - topPadding)
        addChild(scoreLabel)
    }
    
    private func setupGameOverLabel() {
        gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
    }
    
    private func setupRestartButton() {
        restartButton = SKLabelNode(fontNamed: "Arial")
        restartButton.text = "Restart"
        restartButton.fontSize = 36
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        restartButton.isHidden = true
        addChild(restartButton)
    }
    
    private func startBackgroundMusic() {
        let backgroundMusic = SKAudioNode(fileNamed: "background_music.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            if let touch = touches.first {
                let location = touch.location(in: self)
                if restartButton.contains(location) {
                    restartGame()
                }
            }
        } else {
            rocketDirection *= -1
            run(SKAction.playSoundFileNamed("turn_sound.mp3", waitForCompletion: false))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        moveObstacles()
        spawnObstacle()
        updateRocketRotation()
        
        obstacleSpeed += CGFloat(deltaTime) * 5 // Increase speed over time
        score += 1
    }
    
    private func moveObstacles() {
        for obstacle in obstacles {
            obstacle.position.y -= obstacleSpeed * CGFloat(deltaTime)
            
            if obstacle.position.y < -obstacle.size.height {
                obstacle.removeFromParent()
                if let index = obstacles.firstIndex(of: obstacle) {
                    obstacles.remove(at: index)
                }
            }
        }
    }
    
    private func spawnObstacle() {
        guard obstacles.count < 5 else { return }
        
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        let screenWidth = frame.width
        let minWidth = screenWidth * 0.3
        let maxWidth = screenWidth * 0.6
        let obstacleWidth = CGFloat.random(in: minWidth...maxWidth)
        
        obstacle.size = CGSize(width: obstacleWidth, height: 20)
        
        let isLeftSide = Bool.random()
        let xPosition: CGFloat
        
        if isLeftSide {
            xPosition = obstacle.size.width / 2
        } else {
            xPosition = frame.width - obstacle.size.width / 2
        }
        
        obstacle.position = CGPoint(x: xPosition, y: frame.height + obstacle.size.height)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = rocketCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func updateRocketRotation() {
        let rotationRate: CGFloat = .pi / 2 // 90 degrees per second
        let rotationAmount = rotationRate * CGFloat(deltaTime) * rocketDirection
        
        // Calculate new total rotation
        let newTotalRotation = rocketTotalRotation + rotationAmount
        
        // Check if we've reached or exceeded the maximum rotation
        if abs(newTotalRotation) >= maxRotationAngle {
            // Clamp the rotation to the maximum angle
            rocketTotalRotation = maxRotationAngle * rocketDirection
            // Reverse direction
            rocketDirection *= -1
        } else {
            // Apply the rotation normally
            rocketTotalRotation = newTotalRotation
        }
        
        // Apply rotation to the rocket
        rocket.zRotation = rocketTotalRotation
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == rocketCategory && contact.bodyB.categoryBitMask == obstacleCategory) ||
           (contact.bodyA.categoryBitMask == obstacleCategory && contact.bodyB.categoryBitMask == rocketCategory) {
            gameOver()
        }
    }
    
    private func gameOver() {
        isGameOver = true
        gameOverLabel.isHidden = false
        restartButton.isHidden = false
        run(SKAction.playSoundFileNamed("game_over_sound.mp3", waitForCompletion: false))
    }
    
    private func restartGame() {
        // Remove all obstacles
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()
        
        // Reset game state
        score = 0
        obstacleSpeed = 200
        isGameOver = false
        
        // Hide game over elements
        gameOverLabel.isHidden = true
        restartButton.isHidden = true
        
        // Reset rocket position and rotation
        rocket.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
        rocket.zRotation = -.pi / 2
        rocketDirection = 1
    }
}
