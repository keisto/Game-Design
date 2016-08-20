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
    var pauseButton:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
   
    // Bar Variable(s)
    var healthBar:SKSpriteNode!
    
    // Weapon Varible(s)
    var ammoText:SKLabelNode!
    let emptyClip = 0
    var shotsRemaining = 12 // Bullets Remaining in Clip
    var pistolClip = 12
    var maxAmmoPistol = 96
    
    // Category Mask(s)
    let bulletMask:UInt32 = 0x1 >> 0; // 1
    let zombieMask:UInt32 = 0x1 >> 1; // 2
    let playerMask:UInt32 = 0x1 >> 2; // 4

    override func didMoveToView(view: SKView) {
        // Setup Variables 
        player = self.childNodeWithName("player") as! SKSpriteNode
        zombieA = self.childNodeWithName("zombie1") as! SKSpriteNode
        zombieB = self.childNodeWithName("zombie2") as! SKSpriteNode
        pauseButton = self.childNodeWithName("pauseButton") as! SKSpriteNode
        healthBar = self.childNodeWithName("healthBar") as! SKSpriteNode
        ammoText = self.childNodeWithName("AmmoText") as! SKLabelNode
        ammoText.text = "\(pistolClip) | \(maxAmmoPistol)"
        self.physicsWorld.contactDelegate = self
        // Player Collision should only be with a Zombie
        player.physicsBody?.collisionBitMask = zombieMask
        // HeathBar Width to fit scene size
        healthBar.size.width = size.width
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set touchPoint to Touch
        touchPoint = touches.first!.locationInNode(self)
        
        // If Player is touched - Reload
        if player.containsPoint(touchPoint) {
            // Update Ammo Text
            if (maxAmmoPistol != emptyClip) {
                maxAmmoPistol-=pistolClip
                shotsRemaining = pistolClip
                ammoText.text = "\(shotsRemaining) | \(maxAmmoPistol)"
                // Set up Prepared Sounds
                let eject = SKAction.playSoundFileNamed("ejectmag.wav", waitForCompletion: true)
                let load  = SKAction.playSoundFileNamed("loadmag.wav", waitForCompletion: true)
                // Play Prepared Sounds on Touch
                player.runAction(SKAction.sequence([eject, load]))
            }
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
            // Update Ammo Text
            if (shotsRemaining != emptyClip) {
                shotsRemaining-=1
                ammoText.text = "\(shotsRemaining) | \(maxAmmoPistol)"
                // Create Bullet
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
            
                // Play Prepared Sound on Touch
                self.runAction(SKAction.playSoundFileNamed("gunfire.wav", waitForCompletion: false))
            }
        }
        
        // If Pause Button is touched
        if pauseButton.containsPoint(touchPoint) {
            let pauseOverlay:SKSpriteNode = SKScene(fileNamed: "Pause")!
                .childNodeWithName("PauseOverlay")! as! SKSpriteNode
            pauseOverlay.removeFromParent()
            self.addChild(pauseOverlay)
            pauseOverlay.zPosition = 10
            pauseOverlay.position.x = size.width / 2
            pauseOverlay.position.y = size.height / 2
        }
        
        if (scene!.view!.paused == true) {
            scene!.view!.paused = false
            scene!.childNodeWithName("PauseOverlay")?.removeFromParent()
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
        
        // If PauseOverlay Exists - Pause the Scene
        if (childNodeWithName("PauseOverlay") != nil) {
            scene!.view!.paused = true
        }
        
        // If WinLossOverlay Exists - Pause the Scene
        if (childNodeWithName("WinLossOverlay") != nil) {
            scene!.view!.paused = true
        }
        
        // If No More Zombies ( Game Victory )
        if (childNodeWithName("zombie1")==nil && childNodeWithName("zombie2")==nil) {
            let winLossOverlay:SKSpriteNode = SKScene(fileNamed: "WinLoss")!
                .childNodeWithName("WinLossOverlay")! as! SKSpriteNode
            winLossOverlay.removeFromParent()
            winLossOverlay.color = SKColor.blueColor()
            self.addChild(winLossOverlay)
            winLossOverlay.zPosition = 10
            winLossOverlay.position.x = size.width / 2
            winLossOverlay.position.y = size.height / 2
            let winLossText:SKLabelNode = SKScene(fileNamed: "WinLoss")!
                .childNodeWithName("WinLossText")! as! SKLabelNode
            winLossText.removeFromParent()
            self.addChild(winLossText)
            winLossText.text = "Victory"
            winLossText.zPosition = 11
            winLossText.position.x = size.width / 2
            winLossText.position.y = size.height / 2
        }
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
            // Zombie Die Animation
            let zdAtlas = SKTextureAtlas(named: "zombiedeath")
            
            let zd1  = zdAtlas.textureNamed("death01_0000.png")
            let zd2  = zdAtlas.textureNamed("death01_0001.png")
            let zd3  = zdAtlas.textureNamed("death01_0002.png")
            let zd4  = zdAtlas.textureNamed("death01_0003.png")
            let zd5  = zdAtlas.textureNamed("death01_0004.png")
            let zd6  = zdAtlas.textureNamed("death01_0005.png")
            let zd7  = zdAtlas.textureNamed("death01_0006.png")
            let zd8  = zdAtlas.textureNamed("death01_0007.png")
            let zd9  = zdAtlas.textureNamed("death01_0008.png")
            let zd10 = zdAtlas.textureNamed("death01_0009.png")
            let zd11 = zdAtlas.textureNamed("death01_0010.png")
            let zd12 = zdAtlas.textureNamed("death01_0011.png")
            let zd13 = zdAtlas.textureNamed("death01_0012.png")
            let zd14 = zdAtlas.textureNamed("death01_0013.png")
            let zd15 = zdAtlas.textureNamed("death01_0014.png")
            let zd16 = zdAtlas.textureNamed("death01_0015.png")
            let zd17 = zdAtlas.textureNamed("death01_0016.png")
            
            // ZombieA Death
            if (contact.bodyA.node!.name == "zombie1") {
                zombieA.runAction(SKAction.animateWithTextures([zd1, zd2, zd3, zd4, zd5, zd6, zd7,
                    zd8, zd9, zd10, zd11, zd12, zd13, zd14, zd15, zd16, zd17],
                    timePerFrame: 0.035, resize: false, restore: false)) {
                        self.zombieA.removeFromParent()
                }
            }
            
            // ZombieB Death
            if (contact.bodyA.node!.name == "zombie2") {
                zombieB.runAction(SKAction.animateWithTextures([zd1, zd2, zd3, zd4, zd5, zd6, zd7,
                    zd8, zd9, zd10, zd11, zd12, zd13, zd14, zd15, zd16, zd17],
                    timePerFrame: 0.035, resize: false, restore: false)) {
                        self.zombieB.removeFromParent()
                }
            }
        } else {
            // Zombie Touched Human
            player.colorBlendFactor = 1.0
            self.runAction(SKAction.playSoundFileNamed("pain.wav", waitForCompletion: true))
            if (healthBar.size.width>0) {
                healthBar.size.width-=(size.width*0.5)
            } else {
                // Player Died ( Game Over )
                let winLossOverlay:SKSpriteNode = SKScene(fileNamed: "WinLoss")!
                    .childNodeWithName("WinLossOverlay")! as! SKSpriteNode
                winLossOverlay.removeFromParent()
                winLossOverlay.color = SKColor.redColor()
                self.addChild(winLossOverlay)
                winLossOverlay.zPosition = 10
                winLossOverlay.position.x = size.width / 2
                winLossOverlay.position.y = size.height / 2
                let winLossText:SKLabelNode = SKScene(fileNamed: "WinLoss")!
                    .childNodeWithName("WinLossText")! as! SKLabelNode
                winLossText.removeFromParent()
                self.addChild(winLossText)
                winLossText.text = "GAME OVER"
                winLossText.zPosition = 11
                winLossText.position.x = size.width / 2
                winLossText.position.y = size.height / 2
            }
        }
    }
}
