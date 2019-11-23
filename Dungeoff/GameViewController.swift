//
//  GameViewController.swift
//  Dungeoff
//
//  Created by Fabio Staiano on 05/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import SpriteKit
var sceneDung = GameScene()
 
class GameViewController: UIViewController {
 
    override func viewDidLoad() {
        let scene = MenuScene(size: view.frame.size)
//        let scene = GameScene(fileNamed: "Map")
        let skView = view as! SKView
        skView.presentScene(scene)
        
    }
    override var prefersStatusBarHidden: Bool {
    return true
    }
}
