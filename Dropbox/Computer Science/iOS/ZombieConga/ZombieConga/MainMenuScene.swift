//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by User on 9/9/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuSence: SKScene {
       override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
//        runAction(SKAction.waitForDuration(20))
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
    }
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        sceneTapped()
//    }
    #if os(iOS)
    override func touchesBegan (touch: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    #else
    override func mouseDown(theEvent: NSEvent) {
        sceneTapped()
    }
    #endif
    func sceneTapped() {
        let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorwayWithDuration(0.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
}
