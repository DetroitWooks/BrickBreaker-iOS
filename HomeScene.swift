import SpriteKit

class HomeScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Title label
        let titleLabel = SKLabelNode(text: "Asteroid Bounce!")
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(titleLabel)

        // High Score label
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontSize = 24
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 160)
        addChild(highScoreLabel)

        // Play button
        let playButton = SKLabelNode(text: "Play")
        playButton.fontSize = 36
        playButton.fontColor = .green
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        playButton.name = "playButton"  // Assign a name to the node for detection
        addChild(playButton)

        // Shop button
        let shopButton = SKLabelNode(text: "Shop")
        shopButton.fontSize = 24
        shopButton.fontColor = .lightGray
        shopButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        shopButton.name = "shopButton"  // Assign a name to the node for detection
        addChild(shopButton)

        // Credits button
        let creditsButton = SKLabelNode(text: "Credits")
        creditsButton.fontSize = 24
        creditsButton.fontColor = .lightGray
        creditsButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        creditsButton.name = "creditsButton"  // Assign a name to the node for detection
        addChild(creditsButton)
    }

    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "playButton" {
                // Transition to GameScene
                let gameScene = GameScene(size: size)
                gameScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
            } else if touchedNode.name == "shopButton" {
                // Transition to ShopScene
                let shopScene = ShopScene(size: size)
                shopScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(shopScene, transition: transition)
            } else if touchedNode.name == "creditsButton" {
                // Transition to CreditsScene
                let creditsScene = CreditsScene(size: size)
                creditsScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(creditsScene, transition: transition)
            }
        }
    }
}
