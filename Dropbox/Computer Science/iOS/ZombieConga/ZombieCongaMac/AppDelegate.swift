//
//  AppDelegate.swift
//  ZombieCongaMac
//
//  Created by User on 9/10/15.
//  Copyright (c) 2015 User. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let scene = MainMenuSence(size: CGSize(width: 2048, height: 1536))
            scene.scaleMode = .AspectFit
            self.skView!.presentScene(scene)
            self.skView!.ignoresSiblingOrder = true
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
