import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var sceneCreated = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure the scene is created only once
        if !sceneCreated {
            // Set the view as SKView
            if let skView = self.view as? SKView {
                print("SKView loaded, bounds: \(skView.bounds.size)")  // Check if SKView is loaded

                // Create and configure the scene with the correct size
                let scene = GameScene(size: skView.bounds.size)
                scene.scaleMode = .resizeFill
                skView.presentScene(scene)

                // Enable debug information
                skView.ignoresSiblingOrder = true
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.showsPhysics = true  // Show physics bodies

                sceneCreated = true
                print("Scene created and presented")
            } else {
                // If the view is not SKView, replace it with an SKView
                let skView = SKView(frame: self.view.bounds)
                self.view = skView
                print("Replacing the view with an SKView")

                // After replacing the view, create the scene
                viewDidLayoutSubviews()
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
