import SpriteKit

class ShopScene: SKScene {

    var ballPower = UserDefaults.standard.integer(forKey: "BallPower") // Default is 0
    var paddleWidth = UserDefaults.standard.integer(forKey: "PaddleWidth") // Default is 0
    var startingHP = UserDefaults.standard.integer(forKey: "StartingHP") // Default is 1
    
    let maxBallPower = 10
    let maxPaddleWidth = 150  // Maximum width for paddle
    let maxStartingHP = 5  // Maximum base HP for bricks

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Shop title
        let shopTitle = SKLabelNode(text: "Shop")
        shopTitle.fontSize = 48
        shopTitle.fontColor = .white
        shopTitle.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(shopTitle)

        // Ball Power Upgrade button
        let ballPowerLabel = SKLabelNode(text: "Increase Ball Power (\(ballPower)/\(maxBallPower))")
        ballPowerLabel.fontSize = 24
        ballPowerLabel.fontColor = .green
        ballPowerLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        ballPowerLabel.name = "ballPowerButton"
        addChild(ballPowerLabel)

        // Paddle Width Upgrade button
        let paddleWidthLabel = SKLabelNode(text: "Increase Paddle Width (\(paddleWidth)/\(maxPaddleWidth))")
        paddleWidthLabel.fontSize = 24
        paddleWidthLabel.fontColor = .green
        paddleWidthLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        paddleWidthLabel.name = "paddleWidthButton"
        addChild(paddleWidthLabel)

        // Starting HP Upgrade button
        let startingHPLabel = SKLabelNode(text: "Increase Starting HP (\(startingHP)/\(maxStartingHP))")
        startingHPLabel.fontSize = 24
        startingHPLabel.fontColor = .green
        startingHPLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startingHPLabel.name = "startingHPButton"
        addChild(startingHPLabel)

        // Back to Home button
        let backButton = SKLabelNode(text: "Back to Home")
        backButton.fontSize = 24
        backButton.fontColor = .lightGray
        backButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        backButton.name = "backButton"
        addChild(backButton)
    }

    // Handle touches in the shop
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "ballPowerButton" && ballPower < maxBallPower {
                ballPower += 1
                UserDefaults.standard.set(ballPower, forKey: "BallPower")
                animateButton(touchedNode)
                (touchedNode as? SKLabelNode)?.text = "Increase Ball Power (\(ballPower)/\(maxBallPower))"
            } else if touchedNode.name == "paddleWidthButton" && paddleWidth < maxPaddleWidth {
                paddleWidth += 10  // Increase paddle width by 10 units
                UserDefaults.standard.set(paddleWidth, forKey: "PaddleWidth")
                animateButton(touchedNode)
                (touchedNode as? SKLabelNode)?.text = "Increase Paddle Width (\(paddleWidth)/\(maxPaddleWidth))"
            } else if touchedNode.name == "startingHPButton" && startingHP < maxStartingHP {
                startingHP += 1  // Increase base HP for new bricks
                UserDefaults.standard.set(startingHP, forKey: "StartingHP")
                animateButton(touchedNode)
                (touchedNode as? SKLabelNode)?.text = "Increase Starting HP (\(startingHP)/\(maxStartingHP))"
            } else if touchedNode.name == "backButton" {
                // Go back to HomeScene
                let homeScene = HomeScene(size: size)
                homeScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(homeScene, transition: transition)
            }
        }
    }

    // Button click animation
    func animateButton(_ node: SKNode) {
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        node.run(sequence)
    }
}
