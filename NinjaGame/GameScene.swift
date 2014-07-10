//
//  GameScene.swift
//  NinjaGame
//
//  Created by Catherine Jung on 08/07/2014.
//  Copyright (c) 2014 InPlayTime Ltd. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    /*
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
   
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    */
    var player: SKSpriteNode!
    
    init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = SKColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        self.player = SKSpriteNode(imageNamed: "player")
        self.player.position = CGPoint(x:self.player.size.width/2, y: self.frame.size.height/2)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func addMonster(){
        let monster = SKSpriteNode(imageNamed:"monster")
        let minY = monster.size.height/2
        let maxY = self.frame.size.height - monster.size.height/2
        let rangeY = maxY - minY
        let actualY:Float = (Float(arc4random()) % rangeY) + minY
        
        monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY)
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody.dynamic = true
        monster.physicsBody.categoryBitMask = monsterCategory
        monster.physicsBody.contactTestBitMask = projectileCategory
        monster.physicsBody.collisionBitMask = projectileCategory
        
        
        self.addChild(monster)
        
        let minDuration = NSTimeInterval(4.0)
        let maxDuration = NSTimeInterval(8.0)
        let rangeDuration:NSTimeInterval = maxDuration - minDuration
        let actualDuration:NSTimeInterval = (NSTimeInterval(arc4random()) % rangeDuration) + minDuration
        
        let actionMove = SKAction.moveTo(CGPointMake(-monster.size.width/2, actualY), duration:actualDuration)
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock({
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size:self.size, won:false)
            self.view.presentScene(gameOverScene, transition:reveal)
            })

        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))

    }
    
    var lastSpawnTimeInterval:NSTimeInterval = -1
    var lastUpdateTimeInterval:NSTimeInterval = -1
    
    func updateWithTimeSinceLastUpdate(timeSinceLast:CFTimeInterval) {
        self.lastSpawnTimeInterval += timeSinceLast
        if (self.lastSpawnTimeInterval > 1){
            self.lastSpawnTimeInterval = 0
            self.addMonster()
        }
    }
    override func update(currentTime:NSTimeInterval){
        var timeSinceLast = currentTime - self.lastUpdateTimeInterval
        self.lastUpdateTimeInterval = currentTime
        if (timeSinceLast > 1){
            timeSinceLast = 1.0/60.0
            self.lastUpdateTimeInterval = currentTime
        }
        self.updateWithTimeSinceLastUpdate(timeSinceLast)
    }
    func rwAdd(a:CGPoint, b:CGPoint) -> CGPoint {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    func rwSubtract(a:CGPoint, b:CGPoint) -> CGPoint {
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    func rwMultiply(a:CGPoint, f:Float) -> CGPoint {
        return CGPointMake(a.x * f, a.y * f)
    }
    func rwLength(a:CGPoint) -> Float{
        return sqrtf(a.x * a.x + a.y * a.y)
    }
    func rwNormalize(a:CGPoint) -> CGPoint{
        let length = rwLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = self.player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody.dynamic = true
        projectile.physicsBody.categoryBitMask = projectileCategory
        projectile.physicsBody.contactTestBitMask = monsterCategory
        projectile.physicsBody.collisionBitMask = monsterCategory
        projectile.physicsBody.usesPreciseCollisionDetection = true
        
        let offset = rwSubtract(location, b:projectile.position)
        if (offset.x <= 0) {return}
        self.addChild(projectile)
        let amount:Float = 1000
        let direction = rwNormalize(offset)
        let shootAmount = rwMultiply(direction, f:amount)
        let realDest = rwAdd(shootAmount, b:projectile.position)
        let velocity:Float = 480
        let realMoveDuration:NSTimeInterval = NSTimeInterval(self.size.width / velocity)
        let actionMove:SKAction = SKAction.moveTo(realDest, duration:realMoveDuration)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    let projectileCategory:UInt32  = 0x1 << 0
    let monsterCategory:UInt32 = 0x1 << 1;
    
    func didCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode){
//        projectile.removeFromParent()
        monster.removeFromParent()
        self.monstersDestroyed += 1
        if (self.monstersDestroyed > 5){
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size:self.size, won:true)
            self.view.presentScene(gameOverScene, transition:reveal)
        }
    }
    func didBeginContact(contact:SKPhysicsContact){
        var firstBody, secondBody : SKPhysicsBody
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & projectileCategory ) != 0 &&
            (secondBody.categoryBitMask & monsterCategory) != 0){
                let one = firstBody.node as SKSpriteNode
                let two = secondBody.node as SKSpriteNode
                didCollideWithMonster(one, monster: two)
        }
    }
    var monstersDestroyed = 0
 
}
