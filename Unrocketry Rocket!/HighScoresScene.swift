import SpriteKit

class HighScoresScene: SKScene {
    override func didMove(to view: SKView) {
        setupHighScores()
    }
    
    private func setupHighScores() {
        removeAllChildren()
        
        backgroundColor = .black
        
        let titleLabel = SKLabelNode(fontNamed: "Arial")
        titleLabel.text = "High Scores"
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(titleLabel)
        
        let highScores = HighScoreManager.shared.getHighScores()
        
        for (index, score) in highScores.enumerated() {
            let scoreLabel = SKLabelNode(fontNamed: "Arial")
            scoreLabel.text = "\(index + 1). \(score.score) - \(formatDate(score.date))"
            scoreLabel.fontSize = 20
            scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 250 - CGFloat(index * 30))
            addChild(scoreLabel)
        }
        
        let backButton = SKLabelNode(fontNamed: "Arial")
        backButton.text = "Back to Menu"
        backButton.fontSize = 30
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "backButton" {
            let menuScene = MenuScene(size: size)
            menuScene.scaleMode = .aspectFill
            view?.presentScene(menuScene, transition: .fade(withDuration: 0.5))
        }
    }
}
