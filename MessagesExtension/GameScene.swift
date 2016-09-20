//
//  GameScene.swift
//  Keep Ups
//
//  Created by Ace Green on 9/16/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import SpriteKit
import GameplayKit
import Messages

protocol GameSceneDelegate {
    func gameVCWillTransition(to presentationStyle: MSMessagesAppPresentationStyle)
    func gameVCWillTansition(to size: CGSize)
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameSceneDelegate {

    struct SpriteType {
        static let BallCategoryName = "ball"
        static let GameMessageName = "gameMessage"
    }
    
    struct CategoryBitMask {
        static let BallCategory   : UInt32 = 0x1 << 0
        //static let BottomCategory : UInt32 = 0x1 << 1
        static let BorderCategory : UInt32 = 0x1 << 1
    }
    
    let whistleSound = SKAction.playSoundFileNamed("whistle", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    let kickSound = SKAction.playSoundFileNamed("kick", waitForCompletion: false)
    
    var gameVCDelegate: GameVCDelegate?
    
    var ball: SKSpriteNode!
    
    var game = Game()
    
    var gameOver : Bool = false 
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        Playing(scene: self),
        GameOver(scene: self)])
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Setup environment
        self.ball = childNode(withName: SpriteType.BallCategoryName) as! SKSpriteNode
        centerBall()
        
        // Add generic scene boundaries
//        let bottom = SKNode()
//        bottom.physicsBody = SKPhysicsBody(edgeFrom: CGPoint.zero, to: CGPoint(x: self.size.width, y: 0.0))
//        bottom.position = .zero;
//        addChild(bottom)
        
        let leftEdge = SKNode()
        leftEdge.physicsBody = SKPhysicsBody(edgeFrom: CGPoint.zero, to: CGPoint(x: 0.0, y: self.size.height * 2))
        leftEdge.position = .zero;
        addChild(leftEdge)
        
        let rightEdge = SKNode()
        rightEdge.physicsBody = SKPhysicsBody(edgeFrom: CGPoint.zero, to: CGPoint(x: 0.0, y: self.size.height * 2))
        rightEdge.position = CGPoint(x: self.size.width, y: 0.0);
        addChild(rightEdge)
        
        // Add CategoryBitMask
        ball.physicsBody!.categoryBitMask = CategoryBitMask.BallCategory
//        bottom.physicsBody!.categoryBitMask = CategoryBitMask.BottomCategory
        leftEdge.physicsBody!.categoryBitMask = CategoryBitMask.BorderCategory
        leftEdge.physicsBody!.categoryBitMask = CategoryBitMask.BorderCategory
        
        // Add contactTestBitMask
        ball.physicsBody!.contactTestBitMask = CategoryBitMask.BallCategory
        
        // Assign contactDelegate
        physicsWorld.contactDelegate = self
        
        gameState.enter(Playing.self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        //let touchLocationBall = touch!.location(in: self.ball)
        
        switch gameState.currentState {
        case is Playing:
            
            gameVCDelegate?.updateScore(game: self.game)
        
            if let body = physicsWorld.body(at: touchLocation) {
                if body.node! == self.ball {
                    
                    let touchLocationX = touchLocation.x
                    let ballCenterX = self.ball.frame.midX
                    let xDifference = ballCenterX - touchLocationX
            
                    print(touchLocationX, ballCenterX, xDifference)
                    
                    let impulseBall = CGVector(dx: (xDifference * 10), dy: self.view!.frame.height)
                    
                    print("Began touch on ball")
                    
                    if body.pinned == true {
                        body.pinned = false
                    }
                    
                    print("hit ball")
                    
                    body.applyImpulse(impulseBall)
                    run(kickSound)
                    
                    // Increment score
                    self.game.currentScore += 1
                    gameVCDelegate?.updateScore(game: self.game)
                }
            }
            
        case is GameOver:
            
            if let newScene = GameScene(fileNamed:"GameScene") {

                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                self.view?.presentScene(newScene, transition: reveal)
                
                gameVCDelegate?.resetScene(scene: newScene)
            }
            
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    
        if self.frame.intersection(ball.frame).isNull && self.ball.position.y < 0 {
            
            if !self.gameOver {
                gameState.enter(GameOver.self)
                gameOver = true
                gameVCDelegate?.gameOver(game: self.game)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3
        if firstBody.categoryBitMask == CategoryBitMask.BallCategory && secondBody.categoryBitMask == CategoryBitMask.BallCategory {
        }
    }
    
    // GameSceneDelegate
    func gameVCWillTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        
        switch presentationStyle {
        case .compact:
            
            print("compact")
            
        case .expanded:
            
            print("expannded")
        }
    }
    
    func gameVCWillTansition(to size: CGSize) {
        print("VC Size", size)
    }
    
    // Helper functions
    func centerBall() {
        self.ball.position = CGPoint(x: self.view!.frame.midX, y: (self.ball.size.height / 2) + 50)
    }
}
