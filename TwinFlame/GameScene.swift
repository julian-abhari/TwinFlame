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

    override func didMove(to view: SKView) {
        // Set background color to black
        backgroundColor = .black

        // Setup heart shapes
        outerHeartPoints = setupHeart(radius: 20)
        innerHeartPoints = setupHeart(radius: 8)

        // Create vehicles
        setupVehicles()

        // Create laces
        setupLaces()
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
                x: CGFloat.random(in: -halfWidth...halfWidth),
                y: CGFloat.random(in: -halfHeight...halfHeight)
            )
            let v2 = Vehicle(
                x: CGFloat.random(in: -halfWidth...halfWidth),
                y: CGFloat.random(in: -halfHeight...halfHeight)
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
                pixelLength: distance + 20
            )
            laceNet.append(lace)

            // Add lace segment nodes to scene
            lace.addNodesToScene(self)
        }
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
        if let touch = touches.first {
            touchLocation = touch.location(in: self)
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
