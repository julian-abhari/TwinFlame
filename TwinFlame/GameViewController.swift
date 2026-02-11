//
//  GameViewController.swift
//  TwinFlame
//
//  Created by Julian Abhari on 1/31/26.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let loaded = SKScene(fileNamed: "GameScene") {
                // Try to cast to GameScene to inject repository
                if let scene = loaded as? GameScene {
                    scene.scaleMode = .aspectFill
                    scene.repository = FirebaseManager.shared
                    view.presentScene(scene)
                } else {
                    // Fallback: instantiate GameScene programmatically if .sks custom class isn't set
                    let scene = GameScene(size: view.bounds.size)
                    scene.scaleMode = .aspectFill
                    scene.repository = FirebaseManager.shared
                    view.presentScene(scene)
                }
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
