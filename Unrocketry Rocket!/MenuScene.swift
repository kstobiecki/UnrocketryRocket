import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        setupMenu()
    }
    
    private func setupMenu() {
        // Remove existing children to avoid duplication
        removeAllChildren()
        
        backgroundColor = .black
        
        let titleLabel = SKLabelNode(fontNamed: "Arial")
        titleLabel.text = "Unrocketry Rocket!"
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(titleLabel)
        
        let playButton = SKLabelNode(fontNamed: "Arial")
        playButton.text = "Play Game"
        playButton.fontSize = 30
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        playButton.name = "playButton"
        addChild(playButton)
        
        let highScoresButton = SKLabelNode(fontNamed: "Arial")
        highScoresButton.text = "High Scores"
        highScoresButton.fontSize = 30
        highScoresButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        highScoresButton.name = "highScoresButton"
        addChild(highScoresButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
        } else if touchedNode.name == "highScoresButton" {
            let highScoresScene = HighScoresScene(size: size)
            highScoresScene.scaleMode = .aspectFill
            view?.presentScene(highScoresScene, transition: .fade(withDuration: 0.5))
        }
    }
}
