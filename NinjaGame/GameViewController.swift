//
//  GameViewController.swift
//  NinjaGame
//
//  Created by Catherine Jung on 08/07/2014.
//  Copyright (c) 2014 InPlayTime Ltd. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
var scene: GameScene!


    override func shouldAutorotate() -> Bool {
        return true
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
 
    }

    
}
