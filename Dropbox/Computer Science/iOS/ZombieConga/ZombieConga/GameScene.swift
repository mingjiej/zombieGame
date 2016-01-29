//
//  GameScene.swift
//  ZombieConga
//
//  Created by User on 9/6/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * pi
    var lastUpdateTime : NSTimeInterval = 0
    var dt : NSTimeInterval = 0.0
    let zombieMoveoPointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    let playablerect: CGRect
    let zombieAnimation: SKAction
    var invinceable = false
    var lastTouchLocation: CGPoint?
    let catMovePointsPerSec:CGFloat = 480.0
    var lives = 5
    var gameOver = false
    let backgroundMovePointsPerSec: CGFloat = 200.0
    let backgroundlayer = SKNode()
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableheight = size.width / maxAspectRatio
        let playablemargin = (size.height - playableheight) / 2.0
        playablerect = CGRect(x: 0, y: playablemargin, width: size.width, height: playableheight)
        var texture: [SKTexture] = []
        for i in 1...4 {
            texture.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        texture.append(texture[2])
        texture.append(texture[1])
        zombieAnimation = SKAction.animateWithTextures(texture, timePerFrame: 0.1)
        super.init(size: size)
        
    }
    required init (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let catCollsionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollsionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    override func didMoveToView(view: SKView){
        playBackGroundMusic("backgroundMusic.mp3")
        backgroundlayer.zPosition = -1
        addChild(backgroundlayer)
        backgroundColor = SKColor.whiteColor()
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            backgroundlayer.addChild(background)
        }
        zombie.zPosition = 100
        backgroundlayer.addChild(zombie)
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat), SKAction.waitForDuration(1.0)])))
        zombie.position = CGPoint(x: 400, y: 400)
    }
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        if let lastTouch = lastTouchLocation {
            let diff = lastTouchLocation! - zombie.position
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
        boundcheckingZombie()
        moveTrain()
        moveBackground()
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverSence(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        sprite.position += amountToMove
    }
    func moveZombieToward(location: CGPoint){
        startZombieAnimation()
        let offset = location - zombie.position
        let length = offset.length()
        let direction = offset.normalize()
        velocity = CGPoint(x: direction.x * zombieMoveoPointsPerSec, y: direction.y * zombieMoveoPointsPerSec)
    }
    func sceneTouched (touchLocation: CGPoint){
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    #if os(iOS)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(backgroundlayer)
        sceneTouched(touchLocation)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(backgroundlayer)
        sceneTouched(touchLocation)
    }
    #else
    override func mouseDown(theEvent: NSEvent) {
        let touchLocation = theEvent.locationInNode(backgroundlayer)
        sceneTouched(touchLocation)
    }
    override func mouseDragged(theEvent: NSEvent) {
        let touchLocation = theEvent.locationInNode(backgroundlayer)
        sceneTouched(touchLocation)
    }
    #endif
    func boundcheckingZombie() {
        let bottemleft = backgroundlayer.convertPoint(CGPoint(x: 0, y: CGRectGetMinY(playablerect)), fromNode: self)
        let topright = backgroundlayer.convertPoint(CGPoint(x: size.width, y: CGRectGetMaxY(playablerect)), fromNode: self)
        if zombie.position.x <= bottemleft.x {
            zombie.position.x = bottemleft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topright.x {
            zombie.position.x = topright.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottemleft.y {
            zombie.position.y = bottemleft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topright.y {
            zombie.position.y = topright.y
            velocity.y = -velocity.y
        }
    }
    func rotateSprite (sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, angel2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        let enemyScreenPos = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playablerect)+enemy.size.height/2, max: CGRectGetMaxY(playablerect)-enemy.size.height/2))
        enemy.position = backgroundlayer.convertPoint(enemyScreenPos, fromNode: self)
        backgroundlayer.addChild(enemy)
        let actionMove = SKAction.moveByX(-size.width-enemy.size.width/2, y: 0.0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    func stopzombieAniamtion() {
        zombie.removeActionForKey("animation")
    }
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        let catScreenPos = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playablerect), max: CGRectGetMaxX(playablerect)), y: CGFloat.random(min: CGRectGetMinY(playablerect), max: CGRectGetMaxY(playablerect)))
        cat.position = backgroundlayer.convertPoint(catScreenPos, fromNode: self)
        cat.setScale(0)
        backgroundlayer.addChild(cat)
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        cat.zRotation = -pi/16.0
        let leftWiggle = SKAction.rotateByAngle(pi/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let removeFromParent = SKAction.removeFromParent()
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale,fullWiggle])
        let groupwait = SKAction.repeatAction(group, count: 10)
        let action = [appear, groupwait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(action))
    }
    func zombieHitCat(cat: SKSpriteNode) {
//        cat.removeFromParent()
        runAction(catCollsionSound)
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0.0
        cat.runAction(SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2))
        
        
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
//        enemy.removeFromParent()
        runAction(enemyCollsionSound)
        loseCats()
        lives--
        invinceable = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock() {
            self.zombie.hidden = false
            self.invinceable = false
        }
        zombie.runAction(SKAction.sequence([blinkAction, setHidden]))
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        backgroundlayer.enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame){
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        if invinceable {
            return
        }
        var hitEnemies: [SKSpriteNode] = []
        backgroundlayer.enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame,20, 20), self.zombie.frame){
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }

    }
    override func didEvaluateActions() {
        checkCollisions()
    }
    func moveTrain() {
        var trainCount = 0;
        var targetPosition = zombie.position
        backgroundlayer.enumerateChildNodesWithName("train"){ node, stop in
            trainCount++
            if !node.hasActions(){
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalize()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        if trainCount >= 30 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            let gameOverScene = GameOverSence(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    func loseCats() {
        var loseCount = 0
        backgroundlayer.enumerateChildNodesWithName("train") {
            node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            node.name = ""
            node.runAction(SKAction.sequence([SKAction.group([SKAction.rotateByAngle(pi * 4, duration: 1.0),
                SKAction.moveTo(randomSpot, duration: 1.0),
                SKAction.scaleTo(0, duration: 1.0)]), SKAction.removeFromParent()
                ]))
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background2.size.height)
        return backgroundNode
    }
    func moveBackground() {
        let backgroundVelocity =
        CGPoint(x: -backgroundMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundlayer.position += amountToMove
        
        backgroundlayer.enumerateChildNodesWithName("background") {
            node, _ in
            let background = node as! SKSpriteNode
            let backgroundScreenPos = self.backgroundlayer.convertPoint(
                background.position, toNode: self)
            if backgroundScreenPos.x <= -background.size.width {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }

 }

