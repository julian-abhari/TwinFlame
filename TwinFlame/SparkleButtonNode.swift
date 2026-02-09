//
//  SparkleButtonNode.swift
//  TwinFlame
//
//  Created by Julian Abhari on 2/8/26.
//

import SpriteKit

class SparkleButtonNode: SKSpriteNode {

    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        self.name = "sparkleButton"
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let path = fourPointStarPath(outer: self.size)

        let shape = SKShapeNode(path: path.cgPath)
        shape.fillColor = .white
        shape.lineWidth = 2
        addChild(shape)
    }

    func tapped(completion: @escaping () -> Void) {
        let rotate = SKAction.rotate(byAngle: .pi * 4, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scale = SKAction.scale(to: 0.1, duration: 0.2)
        let group = SKAction.group([fadeOut, scale])
        let remove = SKAction.removeFromParent()
        let completionAction = SKAction.run(completion)
        let sequence = SKAction.sequence([rotate, group, remove, completionAction])
        run(sequence)
    }
    
    private func fourPointStarPath(outer: CGSize, innerScale: CGFloat = 0.4) -> UIBezierPath {
        let outerX = outer.width / 2
        let outerY = outer.height / 2
        let innerX = outerX * innerScale
        let innerY = outerY * innerScale

        let path = UIBezierPath()
        // Start at top outer
        path.move(to: CGPoint(x: 0, y: outerY))            // top outer
        path.addLine(to: CGPoint(x: innerX, y: innerY))    // top-right inner
        path.addLine(to: CGPoint(x: outerX, y: 0))         // right outer
        path.addLine(to: CGPoint(x: innerX, y: -innerY))   // bottom-right inner
        path.addLine(to: CGPoint(x: 0, y: -outerY))        // bottom outer
        path.addLine(to: CGPoint(x: -innerX, y: -innerY))  // bottom-left inner
        path.addLine(to: CGPoint(x: -outerX, y: 0))        // left outer
        path.addLine(to: CGPoint(x: -innerX, y: innerY))   // top-left inner
        path.close()
        return path
    }
}
