import SpriteKit

class GameOverScene: SKScene {

    let score: Int

    init(size: CGSize, score: Int) {
        self.score = score
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Game Over label
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(gameOverLabel)

        // Score label
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 160)
        addChild(scoreLabel)

        // Home button
        let homeButton = SKLabelNode(text: "Home")
        homeButton.fontSize = 36
        homeButton.fontColor = .green
        homeButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        homeButton.name = "homeButton"
        addChild(homeButton)
    }

    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "homeButton" {
                // Transition to HomeScene
                let homeScene = HomeScene(size: size)
                homeScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(homeScene, transition: transition)
            }
        }
    }
}
