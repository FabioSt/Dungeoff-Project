//
//  classePersonaggio.swift
//  Dungeoff
//
//  Created by Davide Russo on 18/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import UIKit
import SpriteKit

class Character: SKSpriteNode {
//        init() {
            
            let hero = SKSpriteNode(imageNamed: "hero-idle1")
            var health: Int = 5
            var maxHealth: Int = 5
            var died = false
//        }
    
    func die(){
        if (health == 0){
            print("you died")
            died = true
        }
    }
}
