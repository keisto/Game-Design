//
//  Tony Keiser
//  MGD Term 1608
//  KeiserTony_Gold
//

import SpriteKit

class MainMenu: SKScene {
    // Global Variable(s)
    var playButton:SKSpriteNode!
    var howButton:SKSpriteNode!
    var creditsButton:SKSpriteNode!
    var touchPoint:CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        // Setup Variables
        playButton    = self.childNodeWithName("playButton") as! SKSpriteNode
        howButton     = self.childNodeWithName("howButton") as! SKSpriteNode
        creditsButton = self.childNodeWithName("creditsButton") as! SKSpriteNode
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Set touchPoint to Touch
        touchPoint = touches.first!.locationInNode(self)
        
        // If touch playButton -> Go to GameScene
        if playButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "GameScene")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
        
        // If touch creditsButton -> Go to Howto
        if howButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "Howto")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
        
        // If touch creditsButton -> Go to Credits
        if creditsButton.containsPoint(touchPoint) {
            // Go to Scene
            let game:GameScene = GameScene(fileNamed: "Credits")!
            game.scaleMode = .AspectFit
            let sceneTransition:SKTransition = SKTransition.doorsOpenVerticalWithDuration(3.0)
            self.view?.presentScene(game, transition: sceneTransition)
        }
    }
}
