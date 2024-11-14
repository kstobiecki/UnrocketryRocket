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
    private var velocityLabel: SKLabelNode!
    
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
    private let rocketCategory: UInt32 = 0x1 << 0
    private let obstacleCategory: UInt32 = 0x1 << 1
    private let wallCategory: UInt32 = 0x1 << 2
    
    private var rocketTotalRotation: CGFloat = 0
    private let maxRotationAngle: CGFloat = .pi / 3 // 60 degrees in radians
    private var rocketSpeed: CGFloat = 150  // Starting speed
    
    private var initialDelay: TimeInterval = 1.0
    private var canMove = false
    
    private var displaySpeed: Int = 0
    
    private var backgrounds: [SKSpriteNode] = []
    private let backgroundScrollSpeed: CGFloat = 1.0
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupLabels()
        setupGameOverLabel()
        setupRestartButton()
        startBackgroundMusic()
        physicsWorld.contactDelegate = self
        setupRocket()
        setupBackground()
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        
        // Create physics body for walls
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = wallCategory
        physicsBody?.contactTestBitMask = rocketCategory
        physicsBody?.collisionBitMask = 0
    }
    
    private func setupRocket() {
        rocket = SKSpriteNode(imageNamed: "rocket")
        rocket.size = CGSize(width: 40, height: 60)
        rocket.position = CGPoint(x: frame.midX, y: frame.height * 0.2)
        rocket.zRotation = 0
        
        // Create a path that matches the rocket's shape
        let path = CGMutablePath()
        
        // Define points for a rocket-like shape (adjust these points to match your rocket image)
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 25),     // Top point
            CGPoint(x: 5, y: 10),     // Upper right
            CGPoint(x: 8, y: -20),    // Lower right
            CGPoint(x: 0, y: -30),    // Bottom point
            CGPoint(x: -8, y: -20),   // Lower left
            CGPoint(x: -5, y: 10)     // Upper left
        ]
        
        // Create the path from points
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        path.closeSubpath()
        
        // Create physics body from the path
        rocket.physicsBody = SKPhysicsBody(polygonFrom: path)
        
        rocket.physicsBody?.isDynamic = true
        rocket.physicsBody?.affectedByGravity = false
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.contactTestBitMask = obstacleCategory
        rocket.physicsBody?.collisionBitMask = 0
        
        addChild(rocket)
    }
    
    private func setupLabels() {
        // Setup score label
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: 20, y: frame.maxY - 80)
        addChild(scoreLabel)
        
        // Setup velocity label
        velocityLabel = SKLabelNode(fontNamed: "Arial")
        velocityLabel.text = "Speed: 0"
        velocityLabel.fontSize = 24
        velocityLabel.horizontalAlignmentMode = .right
        velocityLabel.verticalAlignmentMode = .top
        velocityLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 80)
        addChild(velocityLabel)
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
    
    private func setupBackground() {
        // Create two copies of the same tall background for seamless scrolling
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background1")
            background.size = CGSize(width: size.width, height: size.height * 5)  // 5 times screen height
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: 0, y: background.size.height * CGFloat(i - 1))
            background.zPosition = -1
            addChild(background)
            backgrounds.append(background)
        }
    }
    
    private func updateBackground() {
        for background in backgrounds {
            background.position.y -= obstacleSpeed * CGFloat(deltaTime) * backgroundScrollSpeed
            
            // If the background has scrolled off the screen
            if background.position.y <= -background.size.height {
                // Find the highest background
                let highestBackground = backgrounds.max { $0.position.y < $1.position.y }!
                // Move this background above the highest one
                background.position.y = highestBackground.position.y + background.size.height
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            rocketDirection *= -1
            run(SKAction.playSoundFileNamed("turn_sound.mp3", waitForCompletion: false))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        deltaTime = min(currentTime - lastUpdateTime, 1.0 / 60.0)
        lastUpdateTime = currentTime
        
        moveObstacles()
        updateRocketRotation()
        updateRocketPosition()
        updateBackground()
        
        if obstacles.count < 4 || (obstacles.last?.position.y ?? 0) < frame.height {
            spawnObstaclePair()
        }
        
        obstacleSpeed += CGFloat(deltaTime) * 5
        rocketSpeed += CGFloat(deltaTime) * 0.5
        
        score += 1
    }
    
    private func moveObstacles() {
        for obstacle in obstacles {
            obstacle.position.y -= obstacleSpeed * CGFloat(deltaTime)
            
            // Remove obstacles that are off screen
            if obstacle.position.y < -100 {  // Add this check
                obstacle.removeFromParent()
                if let index = obstacles.firstIndex(of: obstacle) {
                    obstacles.remove(at: index)
                }
            }
        }
    }
    
    private func spawnObstaclePair() {
        let screenWidth = frame.width
        let obstacleHeight: CGFloat = 50
        let minGapWidth: CGFloat = rocket.size.width * 2 // Minimum gap width
        let maxGapWidth: CGFloat = minGapWidth + 50 // Maximum gap width
        let gapWidth = CGFloat.random(in: minGapWidth...maxGapWidth)
        let totalObstacleWidth = screenWidth - gapWidth
        
        // Randomize vertical spacing between pairs, with a minimum of 300 pixels
        let minVerticalSpacing: CGFloat = 300
        let maxVerticalSpacing: CGFloat = 500
        let verticalSpacing = CGFloat.random(in: minVerticalSpacing...maxVerticalSpacing)
        
        // Calculate the y-position for the new pair of obstacles
        let lastObstacleY = obstacles.last?.position.y ?? frame.height
        let newYPosition = lastObstacleY + verticalSpacing
        
        // Randomly decide which obstacle is shorter
        let leftObstacleWidth = Bool.random() ? totalObstacleWidth * 0.4 : totalObstacleWidth * 0.6
        let rightObstacleWidth = totalObstacleWidth - leftObstacleWidth
        
        // Create left obstacle
        let leftObstacle = SKSpriteNode(imageNamed: "obstacle")
        leftObstacle.size = CGSize(width: leftObstacleWidth, height: obstacleHeight)
        leftObstacle.position = CGPoint(x: leftObstacleWidth / 2, y: newYPosition)
        
        // Create right obstacle
        let rightObstacle = SKSpriteNode(imageNamed: "obstacle")
        rightObstacle.size = CGSize(width: rightObstacleWidth, height: obstacleHeight)
        rightObstacle.position = CGPoint(x: screenWidth - rightObstacleWidth / 2, y: newYPosition)
        
        // Set physics properties
        for obstacle in [leftObstacle, rightObstacle] {
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.isDynamic = false
            obstacle.physicsBody?.categoryBitMask = obstacleCategory
            obstacle.physicsBody?.contactTestBitMask = rocketCategory
            obstacle.physicsBody?.collisionBitMask = 0
            addChild(obstacle)
            obstacles.append(obstacle)
        }
    }
    
    private func updateRocketRotation() {
        let rotationRate: CGFloat = .pi / 1.5 // 120 degrees per second
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
        
        // Update rocket position
        updateRocketPosition()
    }
    
    private func updateRocketPosition() {
        let horizontalMovement = rocketSpeed * CGFloat(deltaTime) * -sin(rocketTotalRotation)
        let newX = rocket.position.x + horizontalMovement
        
        // Keep rocket within screen bounds
        rocket.position.x = min(max(newX, rocket.size.width/2), frame.width - rocket.size.width/2)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (rocketCategory | obstacleCategory) || collision == (rocketCategory | wallCategory) {
            print("Collision detected!") // Add this line for debugging
            gameOver()
        }
    }
    
    private func gameOver() {
        if isGameOver { return }
        
        isGameOver = true
        print("Game Over!")
        
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.scaleMode = scaleMode
        gameOverScene.score = score
        view?.presentScene(gameOverScene, transition: .fade(withDuration: 1.0))
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
