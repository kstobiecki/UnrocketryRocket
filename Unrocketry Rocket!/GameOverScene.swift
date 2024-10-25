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
        restartLabel.name = "restartButton"
        addChild(restartLabel)
        
        let highScoresLabel = SKLabelNode(fontNamed: "Arial")
        highScoresLabel.text = "High Scores"
        highScoresLabel.fontSize = 36
        highScoresLabel.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        highScoresLabel.name = "highScoresButton"
        addChild(highScoresLabel)
        
        // Save the high score
        HighScoreManager.shared.addHighScore(score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "restartButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
        } else if touchedNode.name == "highScoresButton" {
            let highScoresScene = HighScoresScene(size: size)
            highScoresScene.scaleMode = .aspectFill
            view?.presentScene(highScoresScene, transition: .fade(withDuration: 0.5))
        } else if touchedNode.name == "menuButton" {
            let menuScene = MenuScene(size: size)
            menuScene.scaleMode = .aspectFill
            view?.presentScene(menuScene, transition: .fade(withDuration: 0.5))
        }
    }
}
