//
//  Tony Keiser
//  MGD Term 1608
//  KeiserTony_Alpha
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Global Variable(s)
    var player:SKSpriteNode!
    var zombieA:SKSpriteNode!
    var zombieB:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
    // Category Mask(s)
    let bulletMask:UInt32 = 0x1 >> 0; // 1
    let zombieMask:UInt32 = 0x1 >> 1; // 2
    let playerMask:UInt32 = 0x1 >> 2; // 4

    override func didMoveToView(view: SKView) {
        // Setup Variables 
        player = self.childNodeWithName("player") as! SKSpriteNode
        zombieA = self.childNodeWithName("zombie1") as! SKSpriteNode
        zombieB = self.childNodeWithName("zombie2") as! SKSpriteNode
        self.physicsWorld.contactDelegate = self
        // Player Collision should only be with a Zombie
        player.physicsBody?.collisionBitMask = zombieMask
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set touchPoint to Touch
        touchPoint = touches.first!.locationInNode(self)
        
        // If Player is touched - Reload
        if player.containsPoint(touchPoint) {
            // Set up Prepared Sounds
            let eject = SKAction.playSoundFileNamed("ejectmag.wav", waitForCompletion: true)
            let load  = SKAction.playSoundFileNamed("loadmag.wav", waitForCompletion: true)
            // Play Prepared Sounds on Touch
            player.runAction(SKAction.sequence([eject, load]))
        }
        
        // If Zombie is touched - Noise
        if zombieA.containsPoint(touchPoint) {
            // Play Prepared Sound on Touch
            zombieA.runAction(SKAction.playSoundFileNamed("zombie1.wav", waitForCompletion: true))
        }
        
        // If Zombie is touched - Noise
        if zombieB.containsPoint(touchPoint) {
            // Play Prepared Sound on Touch
            zombieB.runAction(SKAction.playSoundFileNamed("zombie2.wav", waitForCompletion: true))
        }
        
        // If NOT Player - Fire Weapon
        if !player.containsPoint(touchPoint) {
            // Play Prepared Sound on Touch
            self.runAction(SKAction.playSoundFileNamed("gunfire.wav", waitForCompletion: false))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // If NOT Player spawn Bullet and move towards touch
        if !player.containsPoint(touchPoint) {
            let bullet:SKSpriteNode = SKScene(fileNamed: "Bullet")!
                .childNodeWithName("bullet")! as! SKSpriteNode
            bullet.removeFromParent()
            self.addChild(bullet)
            bullet.zPosition = 1
            bullet.position = player.position
            // Get Player Rotation & Set Bullet Speed & Line of Fire
            let playerAngle = Float(player.zRotation)
            let bulletSpeed = CGFloat(3.0)
            let velocityX:CGFloat = CGFloat(cosf(playerAngle)) * bulletSpeed
            let velocityY:CGFloat = CGFloat(sinf(playerAngle)) * bulletSpeed
            bullet.physicsBody?.applyImpulse(CGVectorMake(velocityX, velocityY))
            // Bullet Collision should only be with a Zombie
            bullet.physicsBody?.collisionBitMask = zombieMask
            bullet.physicsBody?.contactTestBitMask = bullet.physicsBody!.collisionBitMask
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set New touchPoint
        touchPoint = touches.first!.locationInNode(self)
    }
   
    override func update(currentTime: CFTimeInterval) {
        // Set Player's Rotation to Angle of touchPoint
        let touchPercent = touchPoint.x / size.width
        let playerAngle = touchPercent * 180 - 180
        player.zRotation = CGFloat(playerAngle) * CGFloat(M_PI) / 180.0
        
        // Set Zombies Destination
        let playerLocation = player.position
        let adx = playerLocation.x - zombieA.position.x
        let ady = playerLocation.y - zombieA.position.y
        let bdx = playerLocation.x - zombieB.position.x
        let bdy = playerLocation.y - zombieB.position.y
        let zAngleA:CGFloat = CGFloat(atan2(ady, adx))
        let zAngleB:CGFloat = CGFloat(atan2(bdy, bdx))
        // Face Zombie towards Player
        zombieA.zRotation = zAngleA
        zombieB.zRotation = zAngleB
        // Zombie Movement
        let ax:CGFloat = CGFloat(cos(zAngleA) * 0.7)
        let ay:CGFloat = CGFloat(sin(zAngleA) * 0.7)
        let bx:CGFloat = CGFloat(cos(zAngleB) * 0.4)
        let by:CGFloat = CGFloat(sin(zAngleB) * 0.4)
        // Zombie Apply Movement
        zombieA.position.x += ax
        zombieA.position.y += ay
        zombieB.position.x += bx
        zombieB.position.y += by
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        // Bullet Touched Zombie
        if (contact.bodyA.categoryBitMask == bulletMask) {
            // Remove Bullet Node From View
            let bullet = contact.bodyA
            bullet.node?.removeFromParent()
            player.colorBlendFactor = 0.0
            // let zombie = contact.bodyB
            self.runAction(SKAction.playSoundFileNamed("zombie1.wav", waitForCompletion: true))
        } else if (contact.bodyB.categoryBitMask == bulletMask) {
            // Remove Bullet Node From View
            let bullet = contact.bodyB
            bullet.node?.removeFromParent()
            player.colorBlendFactor = 0.0
            // let zombie = contact.bodyA
            self.runAction(SKAction.playSoundFileNamed("zombie2.wav", waitForCompletion: true))
        } else {
            // Zombie Touched Human
            player.colorBlendFactor = 1.0
            self.runAction(SKAction.playSoundFileNamed("pain.wav", waitForCompletion: true))
        }
    }
}
