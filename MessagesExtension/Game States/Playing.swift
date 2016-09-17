//
//  Playing.swift
//  BreakoutSpriteKitTutorial
//
//  Created by Michael Briscoe on 1/16/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -25)
        
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        print("Playing State")

        scene.run(scene.whistleSound)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
    }
    
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        return stateClass is GameOver.Type
//    }
}
