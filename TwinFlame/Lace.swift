//
//  Lace.swift
//  TwinFlame
//
//  Ported from Lace.js - manages an array of Segment objects
//

import SpriteKit

class Lace {
    var position: CGPoint
    var segments: [Segment]
    var length: Int

    init(x: CGFloat, y: CGFloat, pixelLength: CGFloat) {
        let segmentLength: CGFloat = 1
        let numSegments = max(1, Int(pixelLength / segmentLength))

        self.length = numSegments
        self.position = CGPoint(x: x, y: y)
        self.segments = []

        // Create the first segment
        segments.append(Segment(position: position, length: segmentLength, segmentNumber: 1))

        // Create the rest of the segments
        for i in 1..<length {
            let parent = segments[i - 1]
            segments.append(Segment(parent: parent, length: segmentLength, segmentNumber: i + 2))
        }
    }

    func addNodesToScene(_ scene: SKScene) {
        for segment in segments {
            scene.addChild(segment.node)
        }
    }

    func show(target: CGPoint) {
        // End segment follows the target
        let endSegment = segments[length - 1]
        endSegment.follow(target: target)
        endSegment.update()

        // Each segment follows the one after it (inverse kinematics)
        for i in stride(from: length - 2, through: 0, by: -1) {
            segments[i].follow(target: segments[i + 1].position)
            segments[i].update()
        }

        // Set base position for first segment
        segments[0].setBasePosition(position)

        // Update all other segments to follow from the base
        for i in 1..<length {
            segments[i].setBasePosition(segments[i - 1].secondPos)
        }
    }
}
