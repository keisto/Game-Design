//
//  Tony Keiser
//  MGD Term 1608
//  KeiserTony_Proof
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    // Global Variable(s)
    var player:SKSpriteNode!
    var zombieA:SKSpriteNode!
    var zombieB:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        // Setup Variables 
        player = self.childNodeWithName("player") as! SKSpriteNode
        zombieA = self.childNodeWithName("zombie1") as! SKSpriteNode
        zombieB = self.childNodeWithName("zombie2") as! SKSpriteNode
        // Prepare Sound File(s)
        do {
            // Preloading Sound Files to Prevent Delay
            let soundFiles = ["ejectmag", "loadmag", "zombie1", "zombie2", "gunfire"]
            for soundFile in soundFiles {
                let mediaPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath:
                    NSBundle.mainBundle().pathForResource(soundFile, ofType: "wav")!))
                mediaPlayer.prepareToPlay()
            }
        } catch {
            // Handle Error(s)
        }
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
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set New touchPoint
        touchPoint = touches.first!.locationInNode(self)
    }

    override func update(currentTime: CFTimeInterval) {
        // Set Player's Rotation to Angle of touchPoint
        let touchPercent = touchPoint.x / size.width
        let playerAngle = touchPercent * 180 - 180
        player.zRotation = CGFloat(playerAngle) * CGFloat(M_PI) / 180.0
    }
}
