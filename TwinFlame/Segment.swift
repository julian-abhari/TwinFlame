//
//  Segment.swift
//  TwinFlame
//
//  Ported from Segment.js - represents a segment of the lace
//

import SpriteKit

class Segment {
    var position: CGPoint
    var secondPos: CGPoint
    var angle: CGFloat
    var length: CGFloat
    var segmentNumber: Int
    var node: SKShapeNode

    init(position: CGPoint, length: CGFloat, segmentNumber: Int = 1) {
        self.position = position
        self.length = length
        self.angle = 0
        self.segmentNumber = segmentNumber
        self.secondPos = Segment.calculateSecondPosition(from: position, angle: 0, length: length)

        // Create the visual node
        self.node = SKShapeNode()
        self.node.strokeColor = SKColor(white: 1.0, alpha: CGFloat(segmentNumber) / 255.0)
        self.node.lineWidth = length
        updateNodePath()
    }

    convenience init(parent: Segment, length: CGFloat, segmentNumber: Int) {
        self.init(position: parent.secondPos, length: length, segmentNumber: segmentNumber)
    }

    func follow(target: CGPoint) {
        let direction = CGVector(dx: target.x - position.x, dy: target.y - position.y)

        angle = atan2(direction.dy, direction.dx)
        let magnitude = length
        let offsetX = -cos(angle) * magnitude
        let offsetY = -sin(angle) * magnitude
        position = CGPoint(x: target.x + offsetX, y: target.y + offsetY)
    }

    func update() {
        secondPos = Segment.calculateSecondPosition(from: position, angle: angle, length: length)
        updateNodePath()
    }

    func setBasePosition(_ base: CGPoint) {
        position = base
        secondPos = Segment.calculateSecondPosition(from: position, angle: angle, length: length)
        updateNodePath()
    }

    private func updateNodePath() {
        let path = CGMutablePath()
        path.move(to: position)
        path.addLine(to: secondPos)
        node.path = path
    }

    static func calculateSecondPosition(
        from initialPosition: CGPoint, angle: CGFloat, length: CGFloat
    ) -> CGPoint {
        let changeX = length * cos(angle)
        let changeY = length * sin(angle)
        return CGPoint(x: initialPosition.x + changeX, y: initialPosition.y + changeY)
    }
}
