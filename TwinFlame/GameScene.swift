//
//  GameScene.swift
//  TwinFlame
//
//  Created by Julian Abhari on 1/31/26.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene {

    // Heart shape points
    private var outerHeartPoints: [CGPoint] = []
    private var innerHeartPoints: [CGPoint] = []

    // Vehicles
    private var vehicles1: [Vehicle] = []
    private var vehicles2: [Vehicle] = []

    // Laces
    private var laceNet: [Lace] = []

    // Configuration
    private let radiusIncrement: CGFloat = 0.06
    private let maxAngle: CGFloat = 2 * .pi

    // Time tracking
    private var time: CGFloat = 0
    private let timeIncrement: CGFloat = 0.005

    // Touch location for flee behavior
    private var touchLocation: CGPoint?

    // Sparkle button
    private var sparkleButton: SparkleButtonNode?

    override func didMove(to view: SKView) {
        // Set background color to black
        backgroundColor = .black

        // Define horizontal padding so the heart doesn't press against screen edges
        let horizontalPadding: CGFloat = 24  // adjust to taste

        // Compute available width with padding and choose scale based on the smaller dimension
        let availableWidth = max(0, view.frame.width - 2 * horizontalPadding)
        let availableHeight = view.frame.height

        // The original heart was designed for a reference dimension of around 400-500 points.
        let referenceDimension: CGFloat = 430

        // Use the smaller of availableWidth and availableHeight to keep the heart fully visible.
        let scaleFactor = min(availableWidth, availableHeight) / referenceDimension

        // Setup heart shapes with scaled radius
        outerHeartPoints = setupHeart(radius: 20 * scaleFactor)
        innerHeartPoints = setupHeart(radius: 8 * scaleFactor)

        // Create vehicles
        setupVehicles()

        // Create laces
        setupLaces()

        // Create sparkle button
        setupSparkleButton()
    }

    private func setupHeart(radius: CGFloat) -> [CGPoint] {
        var heart: [CGPoint] = []
        var angle: CGFloat = 0

        while angle < maxAngle {
            // Parametric heart equation
            let x = radius * 16 * pow(sin(angle), 3)
            let y =
                radius
                * (13 * cos(angle) - 5 * cos(2 * angle) - 2 * cos(3 * angle) - cos(4 * angle))
            heart.append(CGPoint(x: x, y: y))
            angle += radiusIncrement
        }

        return heart
    }

    private func setupVehicles() {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        var angle: CGFloat = 0
        while angle < maxAngle {
            // Create vehicles at random positions
            let v1 = Vehicle(
                x: innerHeartPoints[Int(angle / radiusIncrement)].x,
                y: innerHeartPoints[Int(angle / radiusIncrement)].y
            )
            let v2 = Vehicle(
                x: outerHeartPoints[Int(angle / radiusIncrement)].x,
                y: outerHeartPoints[Int(angle / radiusIncrement)].y
            )

            vehicles1.append(v1)
            vehicles2.append(v2)

            // Add vehicle nodes to scene
            addChild(v1.node)
            addChild(v2.node)

            angle += radiusIncrement
        }
    }

    private func setupLaces() {
        for i in 0..<vehicles2.count {
            // Calculate distance between outer and inner heart points
            let distance = outerHeartPoints[i].distance(to: innerHeartPoints[i])
            let lace = Lace(
                x: vehicles2[i].position.x,
                y: vehicles2[i].position.y,
                pixelLength: distance + 40
            )
            laceNet.append(lace)

            // Add lace segment nodes to scene
            lace.addNodesToScene(self)
        }
    }

    private func setupSparkleButton() {
        sparkleButton = SparkleButtonNode(size: CGSize(width: 40, height: 40))
        if let button = sparkleButton {
            button.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            addChild(button)
        }
    }

    private func animateMessage() {
        let messageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        messageLabel.text = MessageStore.getTodaysMessage()
        messageLabel.fontSize = 24
        messageLabel.fontColor = .white
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center

        // Create a container node for the label and its background
        let container = SKNode()
        container.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 50)
        container.alpha = 0

        container.addChild(messageLabel)

        addChild(container)

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 0.5)
        let group = SKAction.group([fadeIn, moveUp])
        container.run(group)
    }

    override func update(_ currentTime: TimeInterval) {
        // Update time
        time += timeIncrement

        // Combine all vehicles for separation behavior
        let allVehicles = vehicles1 + vehicles2

        for i in 0..<vehicles1.count {
            // Determine target based on time (alternating between inner and outer heart)
            let useOuter = Int(time) % 2 == 0
            let target1 = useOuter ? outerHeartPoints[i] : innerHeartPoints[i]
            let target2 = useOuter ? innerHeartPoints[i] : outerHeartPoints[i]

            // Update vehicle 1
            vehicles1[i].applyBehaviors(vehicles: allVehicles, target: target1)
            if let touch = touchLocation {
                vehicles1[i].applyAvoidTarget(touch)
            }
            vehicles1[i].update()

            // Update vehicle 2
            vehicles2[i].applyBehaviors(vehicles: allVehicles, target: target2)
            if let touch = touchLocation {
                vehicles2[i].applyAvoidTarget(touch)
            }
            vehicles2[i].update()

            // Update lace position and display
            laceNet[i].position = vehicles2[i].position
            laceNet[i].show(target: vehicles1[i].position)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let button = sparkleButton, button.contains(location) {
            button.tapped {
                self.animateMessage()
            }
            sparkleButton = nil
        } else {
            touchLocation = location
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchLocation = touch.location(in: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
}
