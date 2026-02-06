//
//  Vehicle.swift
//  TwinFlame
//
//  Ported from Vehicle.js - manages physics of a single particle
//

import SpriteKit

class Vehicle {
    var position: CGPoint
    var velocity: CGVector
    var acceleration: CGVector
    var radius: CGFloat
    var maxSpeed: CGFloat
    var maxForce: CGFloat
    var node: SKShapeNode

    init(x: CGFloat, y: CGFloat) {
        self.position = CGPoint(x: x, y: y)
        self.velocity = CGVector(dx: 0, dy: 0)
        self.acceleration = CGVector(dx: 0, dy: 0)
        self.radius = 1
        self.maxSpeed = 5
        self.maxForce = 1

        // Create the visual node
        self.node = SKShapeNode(circleOfRadius: radius)
        self.node.fillColor = SKColor(white: 1.0, alpha: 0.78)  // 200/255 ≈ 0.78
        self.node.strokeColor = .clear
        self.node.position = position
    }

    func applyForce(_ force: CGVector) {
        acceleration = acceleration + force
    }

    func applyBehaviors(vehicles: [Vehicle], target: CGPoint) {
        let separateForce = separate(vehicles: vehicles)
        let seekForce = seek(target: target)

        // Apply weights
        let weightedSeparate = separateForce * 2.0
        let weightedSeek = seekForce * 1.0

        applyForce(weightedSeparate)
        applyForce(weightedSeek)
    }

    func applyAvoidTarget(_ target: CGPoint) {
        let fleeForce = flee(target: target)
        let weightedFlee = fleeForce * -5.0
        applyForce(weightedFlee)
    }

    // Method that calculates a steering force towards a target
    // Steering force = desired force - current velocity
    func seek(target: CGPoint) -> CGVector {
        var desired = CGVector(dx: target.x - position.x, dy: target.y - position.y)

        desired = desired.normalized() * maxSpeed
        var steeringForce = desired - velocity
        steeringForce = steeringForce.limited(to: maxForce)

        return steeringForce
    }

    func flee(target: CGPoint) -> CGVector {
        let desired = CGVector(dx: target.x - position.x, dy: target.y - position.y)
        let distance = desired.magnitude()

        if distance < 100 {
            let fleeDesired = desired.normalized() * maxSpeed
            var steeringForce = fleeDesired - velocity
            steeringForce = steeringForce.limited(to: maxForce)
            return steeringForce
        }
        return CGVector(dx: 0, dy: 0)
    }

    func separate(vehicles: [Vehicle]) -> CGVector {
        let desiredSeparation = radius
        var sum = CGVector(dx: 0, dy: 0)
        var count: CGFloat = 0

        // For every vehicle in the system, check if it's too close
        for vehicle in vehicles {
            let distance = self.position.distance(to: vehicle.position)
            if distance > 0 && distance < desiredSeparation {
                var difference = CGVector(
                    dx: position.x - vehicle.position.x,
                    dy: position.y - vehicle.position.y
                )
                difference = difference.normalized()
                difference = difference / distance
                sum = sum + difference
                count += 1
            }
        }

        if count > 0 {
            sum = sum / count
            sum = sum.normalized() * maxSpeed
            // Steering = Desired - velocity
            sum = sum - velocity
            sum = sum.limited(to: maxForce)
        }
        return sum
    }

    func update() {
        velocity = velocity + acceleration
        velocity = velocity.limited(to: maxSpeed)
        position = CGPoint(x: position.x + velocity.dx, y: position.y + velocity.dy)
        acceleration = CGVector(dx: 0, dy: 0)

        // Update node position
        node.position = position
    }
}

// MARK: - CGVector Extensions

extension CGVector {
    func magnitude() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    func normalized() -> CGVector {
        let mag = magnitude()
        if mag == 0 {
            return CGVector(dx: 0, dy: 0)
        }
        return CGVector(dx: dx / mag, dy: dy / mag)
    }

    func limited(to maxValue: CGFloat) -> CGVector {
        let mag = magnitude()
        if mag > maxValue {
            return normalized() * maxValue
        }
        return self
    }

    static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }

    static func - (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
    }

    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    static func / (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }
}

// MARK: - CGPoint Extensions

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx * dx + dy * dy)
    }
}
