//
//  GameOverScene.swift
//  Unrocketry Rocket!
//
//  Created by Kamil Stobiecki on 22/10/2024.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(color: .black, size: size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(scoreLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Arial")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 36
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
    }
}

