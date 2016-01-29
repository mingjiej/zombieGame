//
//  GameViewController.swift
//  ZombieConga
//
//  Created by User on 9/6/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        let scene = MainMenuSence(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
