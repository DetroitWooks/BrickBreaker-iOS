import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Game variables
    var lives = 3
    var score = 0
    var highScore = 0
    var spawnRate = 0.1  // Initial spawn rate for new bricks
    var rows = 3
    var columns = 5
    var baseBrickHP = UserDefaults.standard.integer(forKey: "StartingHP")  // Base HP for each brick (increases when bricks are cleared)
    var ballPower = UserDefaults.standard.integer(forKey: "BallPower")
    var paddleWidthUpgrade = UserDefaults.standard.integer(forKey: "PaddleWidth")
    var powerUpSpawnRate = 0.05  // Starting power-up spawn rate
    var powerUpActive = false

    // UI elements
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!

    // Game objects
    let paddle = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 20))
    var ball: SKShapeNode!
    var powerUp: SKShapeNode?

    // Physics categories
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let ball: UInt32 = 0x1 << 0
        static let brick: UInt32 = 0x1 << 1
        static let paddle: UInt32 = 0x1 << 2
        static let bottom: UInt32 = 0x1 << 3
        static let powerUp: UInt32 = 0x1 << 4
    }

    override func didMove(to view: SKView) {
        print("GameScene loaded")

        // Disable gravity in the scene
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // Set up the game elements
        setupEdges()
        setupPaddle()
        setupBall()
        createBricks(rows: rows, columns: columns)

        // Set up UI
        setupUI()

        // Load high score from UserDefaults
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        updateUI()
    }
    // MARK: - Touch Handling

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            var newXPosition = location.x

            // Constrain the paddle movement to stay within the scene bounds
            newXPosition = max(paddle.size.width / 2, newXPosition)
            newXPosition = min(size.width - paddle.size.width / 2, newXPosition)

            // Move the paddle to the new position
            paddle.position = CGPoint(x: newXPosition, y: paddle.position.y)
        }
    }

    // MARK: - Setup Functions

    func setupEdges() {
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        self.physicsBody = border

        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y - 10, width: frame.size.width, height: 10)
        let bottomEdge = SKNode()
        bottomEdge.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        bottomEdge.physicsBody?.categoryBitMask = PhysicsCategory.bottom
        addChild(bottomEdge)
    }

    func setupPaddle() {
        let defaultPaddleWidth: CGFloat = 100
        let maxPaddleWidth = size.width / 4  // Limit to 1/4 of the screen
        let logarithmicUpgrade = log10(CGFloat(paddleWidthUpgrade) + 1) / 2
        let paddleWidth = min(defaultPaddleWidth + (logarithmicUpgrade * 50), maxPaddleWidth)
        
        paddle.size = CGSize(width: paddleWidth, height: 20)
        paddle.position = CGPoint(x: size.width / 2, y: paddle.size.height * 2)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.paddle
        paddle.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.powerUp
        paddle.physicsBody?.collisionBitMask = PhysicsCategory.ball
        addChild(paddle)
    }

    func setupBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.fillColor = .red
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.paddle | PhysicsCategory.bottom
        ball.physicsBody?.collisionBitMask = PhysicsCategory.paddle | PhysicsCategory.brick
        addChild(ball)

        // Apply impulse to ball (start it moving)
        ball.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 1))
    }

    // Adjust brick size based on current rows and columns
    func adjustedBrickSize() -> CGSize {
        let brickWidth = (size.width - CGFloat(columns + 1) * 5) / CGFloat(columns)
        let brickHeight: CGFloat = 20
        return CGSize(width: brickWidth, height: brickHeight)
    }

    // Converts HP to an RGB color (scaled to 16-bit maximum)
    func colorFromHP(_ hp: Int) -> UIColor {
        let maxHP = 65535  // 16-bit max HP
        let normalizedHP = min(hp, maxHP)  // Ensure we don't go beyond 16-bit max

        // Map the HP into 24-bit RGB color components
        let red = CGFloat((normalizedHP >> 8) & 0xFF) / 255.0  // Higher byte for red
        let green = CGFloat((normalizedHP >> 4) & 0xF) / 15.0  // Middle byte for green
        let blue = CGFloat(normalizedHP & 0xF) / 15.0          // Lower byte for blue

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    // Creates a grid of bricks based on rows and columns
    func createBricks(rows: Int, columns: Int) {
        let brickSize = adjustedBrickSize()

        for row in 0..<rows {
            for column in 0..<columns {
                let xPosition = CGFloat(column) * (brickSize.width + 5) + brickSize.width / 2 + 5
                let yPosition = size.height - CGFloat(row) * (brickSize.height + 5) - brickSize.height / 2 - 50

                let brickHP = baseBrickHP  // Set base HP for each brick
                let brickColor = colorFromHP(brickHP)  // Convert HP to color

                let brick = SKSpriteNode(color: brickColor, size: brickSize)
                brick.position = CGPoint(x: xPosition, y: yPosition)
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
                brick.name = "brick"
                brick.userData = ["hp": brickHP]  // Store HP in userData

                addChild(brick)
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // Ensure we are sorting the bodies correctly based on categoryBitMask
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Ball hits a brick
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.brick {
            if let brick = secondBody.node as? SKSpriteNode {
                if let hp = brick.userData?["hp"] as? Int {
                    let damage = 1 + ballPower  // Damage is 1 base plus the ball power level

                    if hp > damage {
                        brick.userData?["hp"] = hp - damage
                        brick.color = colorFromHP(hp - damage)  // Update brick color based on new HP
                        print("Brick hit! HP remaining: \(hp - damage)")
                    } else {
                        score += 10 * hp  // Multiply score by brick's HP
                        brick.removeFromParent()
                        print("Brick destroyed with HP: \(hp)")
                        
                        // Random chance to spawn a power-up
                        if !powerUpActive && Double.random(in: 0..<1) < powerUpSpawnRate {
                            spawnPowerUp(at: brick.position)
                            powerUpSpawnRate = 0.05  // Reset the power-up spawn rate
                        }
                    }
                }
                updateUI()
            }

            // Check if no bricks are left, add a new level with more rows and columns
            if children.filter({ $0.name == "brick" }).isEmpty {
                baseBrickHP += 1  // Increase the base HP for new bricks
                rows += 1
                columns += 1
                createBricks(rows: rows, columns: columns)
            }
        }

        // Ball hits the paddle
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.paddle {
            ricochetBallOffPaddle(contactPoint: firstBody.node!.position)
        }

        // Ball hits the bottom (lose a life)
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.bottom {
            lives -= 1
            print("Life lost! Remaining lives: \(lives)")
            checkForGameOver()
            resetBall()
            updateUI()
        }

        // Power-up hits the paddle (activate power-up)
        if firstBody.categoryBitMask == PhysicsCategory.powerUp && secondBody.categoryBitMask == PhysicsCategory.paddle {
            activatePowerUp()  // Trigger one of the 10 power-ups
            print("Power-up collected!")
        }

        // Power-up hits the bottom (remove it)
        if firstBody.categoryBitMask == PhysicsCategory.powerUp && secondBody.categoryBitMask == PhysicsCategory.bottom {
            powerUp?.removeFromParent()
            powerUpActive = false
            powerUpSpawnRate = 0.05  // Reset spawn rate for the next power-up
            print("Power-up missed!")
        }
    }
    
    // MARK: - Power-ups

    func spawnPowerUp(at position: CGPoint) {
        guard !powerUpActive else { return }  // Prevent multiple power-ups at the same time
        powerUpActive = true
        
        powerUp = SKShapeNode(circleOfRadius: 8)  // Smaller than the ball
        powerUp?.fillColor = .yellow
        powerUp?.position = position
        powerUp?.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        powerUp?.physicsBody?.isDynamic = true
        powerUp?.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUp?.physicsBody?.contactTestBitMask = PhysicsCategory.paddle | PhysicsCategory.bottom
        powerUp?.physicsBody?.collisionBitMask = PhysicsCategory.none  // No collision with ball
        addChild(powerUp!)
        
        // Apply downward velocity to make the power-up fall
        powerUp?.physicsBody?.velocity = CGVector(dx: 0, dy: -200)
    }

    func activatePowerUp() {
        let powerUpType = Int.random(in: 1...10)
        switch powerUpType {
        case 1:
            doubleBallSpeed()
        case 2:
            temporaryWidePaddle()
        case 3:
            stickyPaddle()
        case 4:
            gainExtraLife()
        case 5:
            slowMotionBall()
        case 6:
            triplePoints()
        case 7:
            explosiveBricks()
        case 8:
            spawnExtraBall()
        case 9:
            shieldProtection()
        case 10:
            instantWin()
        default:
            break
        }
        powerUp?.removeFromParent()
        powerUpActive = false
        powerUpSpawnRate = 0.05  // Reset the spawn rate after power-up
    }

    // MARK: - Superpower Implementations

    func doubleBallSpeed() {
        ball.physicsBody?.velocity.dx *= 2
        ball.physicsBody?.velocity.dy *= 2
    }

    func temporaryWidePaddle() {
        paddle.size.width *= 1.5
        run(SKAction.wait(forDuration: 10)) { [weak self] in
            self?.paddle.size.width /= 1.5
        }
    }

    func stickyPaddle() {
        // Ball sticks to paddle for one shot
    }

    func gainExtraLife() {
        lives += 1
        updateUI()
    }

    func slowMotionBall() {
        ball.physicsBody?.velocity.dx /= 2
        ball.physicsBody?.velocity.dy /= 2
    }

    func triplePoints() {
        score *= 3
        updateUI()
    }

    func explosiveBricks() {
        // Destroy a brick and neighboring bricks
    }

    func spawnExtraBall() {
        let extraBall = SKShapeNode(circleOfRadius: 10)
        extraBall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        extraBall.fillColor = .green
        extraBall.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        extraBall.physicsBody?.isDynamic = true
        extraBall.physicsBody?.categoryBitMask = PhysicsCategory.ball
        extraBall.physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.paddle | PhysicsCategory.bottom
        extraBall.physicsBody?.collisionBitMask = PhysicsCategory.paddle | PhysicsCategory.brick
        addChild(extraBall)
        extraBall.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 1))
    }

    func shieldProtection() {
        // Prevent losing a life once
    }

    func instantWin() {
        // Destroy all bricks
    }

    // MARK: - Helper Functions
    // MARK: - Paddle Ricochet Logic

    func ricochetBallOffPaddle(contactPoint: CGPoint) {
        guard let physicsBody = ball.physicsBody else { return }

        // Calculate how far from the center of the paddle the ball hit
        let paddleCenter = paddle.position.x
        let paddleWidth = paddle.size.width
        let hitOffset = (contactPoint.x - paddleCenter) / (paddleWidth / 2)  // normalized value [-1, 1]

        // Modify the ball's velocity based on the hit offset
        let currentVelocity = physicsBody.velocity
        let speedIncreaseFactor: CGFloat = 1.000001
        let newVelocityX = currentVelocity.dx + (hitOffset * 300)  // Adjust the multiplier to control the strength of the ricochet
        let newVelocityY = abs(currentVelocity.dy) * speedIncreaseFactor  // Keep the Y velocity positive and increase slightly

        let newVelocity = CGVector(dx: newVelocityX, dy: newVelocityY)
        physicsBody.velocity = newVelocity

        print("Ball ricocheted with new velocity: \(newVelocity)")
    }

    func resetBall() {
        ball.removeFromParent()
        setupBall()
    }

    func checkForGameOver() {
        if lives <= 0 {
            // Check if the current score is higher than the stored high score
            let highScore = UserDefaults.standard.integer(forKey: "HighScore")
            if score > highScore {
                UserDefaults.standard.set(score, forKey: "HighScore")
                print("New high score: \(score)")
            }

            // Transition to GameOverScene
            let gameOverScene = GameOverScene(size: size, score: score)
            gameOverScene.scaleMode = .aspectFill
            let transition = SKTransition.crossFade(withDuration: 1.0)
            view?.presentScene(gameOverScene, transition: transition)
        }
    }

    // MARK: - UI

    func setupUI() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(scoreLabel)

        livesLabel = SKLabelNode(text: "Lives: 3")
        livesLabel.fontSize = 24
        livesLabel.position = CGPoint(x: size.width / 2, y: size.height - 70)
        addChild(livesLabel)
    }

    func updateUI() {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
    }
}
