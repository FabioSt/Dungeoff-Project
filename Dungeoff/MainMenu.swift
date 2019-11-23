//
//  MainMenu.swift
//  Dungeoff
//
//  Created by Fabio Staiano on 18/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    
    // you can use another font for the label if you want...
    let tapStartLabel = SKLabelNode(fontNamed: "Savior4")
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var background = SKSpriteNode(imageNamed: "bg")
    
    override func didMove(to view: SKView) {
        
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.6)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.6)
        
        
        menuMusic(father: self)
        
        // set the background
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = view.bounds.size
        addChild(background)
        
        // set size, color, position and text of the tapStartLabel
        tapStartLabel.fontSize = 32
        tapStartLabel.fontColor = .white
        tapStartLabel.horizontalAlignmentMode = .center
        tapStartLabel.verticalAlignmentMode = .center
        tapStartLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        tapStartLabel.text = "Tap to Start"
        tapStartLabel.run(SKAction.repeatForever(SKAction.sequence([fadeOut,fadeIn])))
        
        // add the label to the scene
        addChild(tapStartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneDung = GameScene(fileNamed: "Map")!
        
        sceneDung.scaleMode = SKSceneScaleMode.aspectFill
        sceneDung.size = (view?.frame.size)!
        
        // use a transition to the gameScene
        let reveal = SKTransition.push(with: .up, duration: 1.4)
        
        // transition from current scene to the new scene
        view!.presentScene(sceneDung, transition: reveal)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
}
