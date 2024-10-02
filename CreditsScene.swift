import SpriteKit

class CreditsScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Developer name
        let developerLabel = SKLabelNode(text: "Developed by: Rich Sivak")
        developerLabel.fontSize = 36
        developerLabel.fontColor = .white
        developerLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(developerLabel)

        // ChatGPT credits
        let chatGPTLabel = SKLabelNode(text: "Credits to: ChatGPT o1 & ChatGPT 4o")
        chatGPTLabel.fontSize = 24
        chatGPTLabel.fontColor = .lightGray
        chatGPTLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(chatGPTLabel)

        // Back to Home button
        let backButton = SKLabelNode(text: "Back to Home")
        backButton.fontSize = 36
        backButton.fontColor = .green
        backButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        backButton.name = "backButton"
        addChild(backButton)
    }

    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "backButton" {
                // Transition to HomeScene
                let homeScene = HomeScene(size: size)
                homeScene.scaleMode = .aspectFill
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(homeScene, transition: transition)
            }
        }
    }
}
