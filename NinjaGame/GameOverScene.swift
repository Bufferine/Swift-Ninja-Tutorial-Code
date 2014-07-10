//
//  GameOverScene.swift
//  NinjaGame
//
//  Created by Catherine Jung on 10/07/2014.
//  Copyright (c) 2014 InPlayTime Ltd. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene{
    var won = false
    
    init(size: CGSize) {
        super.init(size:size)
    }
    convenience init(size:CGSize, won:Bool){
        self.init(size: size)
        self.backgroundColor = SKColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        var message:String
        if (won){
            message = "YOU WON!"
        }else{
            message = "YOU LOSE"
        }
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(label)
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock(doBlock)
            ]))
    }
    func doBlock(){
        let reveal:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
        let myScene:SKScene = GameScene(size:self.size)
        self.view.presentScene(myScene, transition: reveal)
    }
}
