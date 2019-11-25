//
//  GameScene.swift
//  Dungeoff
//
//  Created by Fabio Staiano on 05/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.

import AVFoundation
import SpriteKit
import CoreMotion

// Grid Stuff
var rockMap : SKTileMapNode = SKTileMapNode()
var waterMap : SKTileMapNode = SKTileMapNode()
var currentRow = rockMap.numberOfColumns/2
var currentColumn = rockMap.numberOfRows/2 + 1
var moveVector = CGVector(dx: 0, dy: 0)
var skeletonBumpPosition = CGPoint.zero
let tileSet = rockMap.tileSet

var coinCounter:Int = 100000

class GameScene: SKScene {
    
    // Tutorial Stuff
    let hint1 = SKSpriteNode(imageNamed: "hint1")
    let hint2 = SKSpriteNode(imageNamed: "hint2")
    var hintLabel: SKLabelNode = SKLabelNode()
    let hints: Array<String> = ["Swipe to Move", "Great", "Shake to earn souls", "Trade souls for a light crystal", "Great, it's time to buy doors!", "Go for the final chest", "It's all on you, now"]
    var tutorialCounter :Int = 0
    
    let skeletonHP = CGFloat(4)
    var hitCounter = CGFloat(0)
    
    let lightNode = SKLightNode()
    
    var gesture = UISwipeGestureRecognizer()
    
    var shopView = ShopView()
    
    var cont = 0 // counter for BUMP action
    
    var heartContainers = SKSpriteNode(imageNamed: "3of3")
    
    var chestChecker = false // check if dragon should be spawn
    var dragonChecker = false
    var trapChecker = false
    var devilChecker = false
    var tutChecker = false
    
    let posCenter = SKSpriteNode()
    let devilEsclamation = SKLabelNode()
    var label = SKLabelNode(fontNamed: "Savior4")
    var esclamation = SKLabelNode(fontNamed: "Savior4")
    let dragonNode = SKSpriteNode(imageNamed:"dragon01")
    let skeletonNode = SKSpriteNode(imageNamed: "skeleton1")
    var lifeBar = SKSpriteNode(texture: nil)
    let cameraNode = SKCameraNode()
    let coinNode = SKSpriteNode(imageNamed: "soul2")
    let devilNode = SKSpriteNode(imageNamed: "devil1")
    let heroNode: Character = Character.init()
    let mapImage = UIImageView(frame: UIScreen.main.bounds)
    let overImage = SKSpriteNode(imageNamed: "gameover")
    let overImage2 = SKSpriteNode(imageNamed: "demoover")
    var shop = SKSpriteNode()
    let motion = CMMotionManager()
    var timer = Timer()
    
    var walkableTiles = ["A1", "A2", "A3", "B1", "B2", "B3","C1","C2","C3", "FAA1", "FAA2", "FAA3", "FBA1","FBA2","FBA3","FBA2v2","FBA2v3","FBA2v3","FBAv6","FCA1","FCA2","FCA3"]
    
    func checkPositions() {
        if comparePositionRound(position1: heroNode.position, position2: skeletonNode.position) {
            // attack(targetPosition: skeletonNode.position)
            let destinationPoint = CGPoint(x: heroNode.position.x - moveVector.dx, y: heroNode.position.y - moveVector.dy)
            if onLand(characterPosition: destinationPoint, map: rockMap) {
                bump(node: heroNode, arrivingDirection: moveVector)
            } else {
                skeletonNode.run(.move(to: skeletonBumpPosition, duration: 0.1))
                bump(node: heroNode, arrivingDirection: .zero)
            }
            checkHP()
            print("move Vector is \(moveVector)")
        } else if comparePositionRound(position1: heroNode.position, position2: devilNode.position) {
            // attack(targetPosition: skeletonNode.position)
            bumpNoDmg(node: heroNode, arrivingDirection: moveVector)
            heroNode.health += 1
            devilEsclamation.removeAction(forKey: "devilDialog")
            devilNode.run(.fadeAlpha(to: 1, duration: 0))
            devilNode.run(.fadeAlpha(to: 0, duration: 2))
            devilNode.run(.moveBy(x: 0, y: 400, duration: 3))
            devilEsclamation.text = "HOW DARE YOU!"
            devilNode.run(.playSoundFileNamed("fadeout", waitForCompletion: false))
        }
        
        
        // DRAGON SPAWN
        if heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 36).y.rounded() {
            
            while (dragonChecker == false) && (chestChecker == true){
                dragonSpawn()
            }
        }
        
        //HEALT SPOT
         if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 27, row: 26).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 27, row: 26).y.rounded() {
            heroNode.health = 3
            heartContainers.texture = SKTexture(imageNamed: "3of3")
               }
        
        // TRAP Appears
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 16, row: 22).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 16, row: 22).y.rounded() {
            if !trapChecker {
                if trapsBought {
                    buyTraps()
                    bump(node: heroNode, arrivingDirection: CGVector(dx: 0, dy: -rockMap.tileSize.height))
                    heroNode.health -= 1
                }
                while !devilChecker {
                    devilSpawn()
                    devilNode.run(.playSoundFileNamed("laugh", waitForCompletion: true))
                }
            }
        }
        
        doorTeleport(user: heroNode)
    }
    
    func doorTeleport(user: SKSpriteNode) {
                // DOOR 1 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 16, row: 17).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 16, row: 17).y.rounded() {
                    let destination = rockMap.centerOfTile(atColumn: 16, row: 22)
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")                            //            user.position = destination
        //            user.position = destination
                    let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                    user.run(animation, completion: {
                        self.view?.isUserInteractionEnabled = true
                    })
                }
                
                // DOOR 2 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 16, row: 21).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 16, row: 21).y.rounded() {
                            let destination = rockMap.centerOfTile(atColumn: 16, row: 16)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")                            //            user.position = destination
                            //         user.position = destination
                            let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                            user.run(animation, completion: {
                                self.view?.isUserInteractionEnabled = true
                        })
                    }
                
                // DOOR 3 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 19, row: 24).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 19, row: 24).y.rounded() {
                   // if skeletonBought { skeletonSpawn() }
                            let destination = rockMap.centerOfTile(atColumn: 23, row: 24)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")                            //            user.position = destination
                    //            user.position = destination
                            let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                            user.run(animation, completion: {
                                self.view?.isUserInteractionEnabled = true
                            })
                    }
                
                // DOOR 4 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 22, row: 24).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 22, row: 24).y.rounded() {
                            let destination = rockMap.centerOfTile(atColumn: 18, row: 24)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")                            //            user.position = destination
                            //            user.position = destination
                        let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                            user.run(animation, completion: {
                                self.view?.isUserInteractionEnabled = true
                            })
                        }
                
                // DOOR 5 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 25, row: 27).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 27).y.rounded() {
                            
                            let destination = rockMap.centerOfTile(atColumn: 25, row: 32)
                //            user.position = destination
                        view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")                            //            user.position = destination
                            let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                            user.run(animation, completion: {
                                self.view?.isUserInteractionEnabled = true
                            })
                        }
                
                // DOOR 6 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 25, row: 31).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 31).y.rounded() {
                            let destination = rockMap.centerOfTile(atColumn: 25, row: 26)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")
                    //            user.position = destination
                                let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                                user.run(animation, completion: {
                                    self.view?.isUserInteractionEnabled = true
                                })
                        }
        
                // DOOR 7 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 28, row: 24).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 28, row: 24).y.rounded() {
                            let destination = rockMap.centerOfTile(atColumn: 32, row: 24)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")
                    //            user.position = destination
                                let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                                user.run(animation, completion: {
                                    self.view?.isUserInteractionEnabled = true
                                })
                        }
        
                // DOOR 8 TELEPORT
                if user.position.x.rounded() == rockMap.centerOfTile(atColumn: 31, row: 24).x.rounded() && user.position.y.rounded() == rockMap.centerOfTile(atColumn: 32, row: 24).y.rounded() {
                            let destination = rockMap.centerOfTile(atColumn: 27, row: 24)
                //            user.position = destination
                    view?.isUserInteractionEnabled = false
                    user.removeAction(forKey: "chase")
                    //            user.position = destination
                                let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                                user.run(animation, completion: {
                                    self.view?.isUserInteractionEnabled = true
                                })
                        }
    }
    
    override func update(_ currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        let lifeBarPosition = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y + skeletonNode.size.height)
        lifeBar.position = lifeBarPosition
        lifeBar.alpha = skeletonNode.alpha
        
        lightNode.position = heroNode.position
        
        
        camera?.position = heroNode.position
        checkPositions()
        label.text = "\(coinCounter)"
        
        if lifeBar.size == .zero { skeletonNode.removeFromParent() }
        
        
        if tutorialCounter == 4 {
            hintLabel.text = hints[1]
        } else if tutorialCounter == 6 {
            hintLabel.text = hints[2]
        } else if (tutorialCounter >= 7) && (coinCounter > 10) {
            
            if tutChecker == false {
                tutChecker = true
                hintLabel.text = hints[3]
            }
        }
        
        if coinCounter > 10 {
            shop.run(.fadeAlpha(to: 1, duration: 2.5))
        }
        
        doorTeleport(user: skeletonNode)
        
        if self.children.contains(skeletonNode) && (skeletonNode.action(forKey: "chase") == nil){
            skeletonNode.run(.sequence([chaseHero(hunterNode: skeletonNode, huntedNode: heroNode), .wait(forDuration: 1)]), withKey: "chase")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let location = touches.first?.location(in: self) {
            nodeTapped(node: self.atPoint(location))
        }
    }
    
    func nodeTapped(node : SKNode) {
        
        if node === self.skeletonNode {
            if isInRange(protagoNode: heroNode, enemyNode: skeletonNode) {
                checkHP()
                slashSound()
                heroAttack()
            }
        }
        
        if node === self.heroNode {
            
               }
        
        if node === self.hint1 {
            posCenter.removeAllChildren()
            posCenter.addChild(hint2)
            
        }
        
        if node === self.hint2 {
            posCenter.removeAllChildren()
            skeletonSpawn()
        }
        
        if node === self.overImage {
            let restart = MenuScene()
            restart.scaleMode = SKSceneScaleMode.aspectFit
            restart.size = (view?.frame.size)!
            view?.presentScene(restart)
            heroNode.position = rockMap.centerOfTile(atColumn: rockMap.numberOfRows/2 , row: rockMap.numberOfColumns/2)
            
            //            heroSpawn()
        }
        if node === self.heroNode {
            
        }
        if node === self.shop {
            if (view?.subviews.contains(shopView))! {
                shop.texture = .init(imageNamed: "shop")
                shopView.removeFromSuperview()
            } else {
                shop.texture = .init(imageNamed: "cross")
                summonShop()
            }
        }
    }
    
    func summonShop() {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        shopView.register(cell.classForCoder, forCellReuseIdentifier: "cell")
        let frame = CGRect(x: 30, y: 150, width: (view?.frame.width)!-60, height: (view?.frame.height)!-150)
        shopView.frame = frame
        shopView.backgroundColor = .white
        self.scene?.view?.addSubview(shopView)
        shopView.reloadData()
    }
    
    func buyLights() {
        backgroundColor = SKColor.init(red: 0.1647, green: 0.0745, blue: 0.1961, alpha: 1.0)
        let columns = [15, 17]
        let rows = [17, 17]
        
        for i in 0 ... columns.count-1  {
            let torchNode = SKSpriteNode(imageNamed: "torch00")
            let torch0 = SKTexture.init(imageNamed: "torch00")
            let torch1 = SKTexture.init(imageNamed: "torch01")
            let torch2 = SKTexture.init(imageNamed: "torch02")
            let torch3 = SKTexture.init(imageNamed: "torch03")
            let torchFrames: [SKTexture] = [torch0, torch1, torch2, torch3]
            torch0.filteringMode = .nearest
            torch1.filteringMode = .nearest
            torch2.filteringMode = .nearest
            torch3.filteringMode = .nearest
            
            // Load the first frame as initialization
            torchNode.position = rockMap.centerOfTile(atColumn: columns[i], row: rows[i])
            torchNode.size = CGSize(width: 64, height: 64)
            torchNode.texture?.filteringMode = .nearest
            torchNode.lightingBitMask = 0b0001
            
            // Change the frame per 0.2 sec
            let animation = SKAction.animate(with: torchFrames, timePerFrame: 0.2)
            torchNode.run(SKAction.repeatForever(animation))
            self.addChild(torchNode)
        }
        lightNode.isEnabled = false
    }
    
    func buyCrystal() {
        hintLabel.text = hints[4]
        lightNode.run(.falloff(to: 1, duration: 0.2))
        lightNode.falloff = 1
        lightNode.lightColor = #colorLiteral(red: 0.7681630254, green: 0.9664419293, blue: 1, alpha: 1)
    }
    
    func buyDoors() {
        
        hintLabel.text = hints[5]
        let seq = SKAction.sequence([.wait(forDuration: 3), .fadeAlpha(to: 0, duration: 0.1)])
        hintLabel.run(SKAction.sequence([seq]),completion: {
            self.hintLabel.text = self.hints[6]
            self.hintLabel.run(SKAction.sequence([.fadeAlpha(to: 1, duration: 0.1), .wait(forDuration: 3), .fadeAlpha(to: 0, duration: 0.1)]))
        })
        
        let columns = [16, 16, 25, 25]
        let rows = [17, 21, 27, 31]
        walkableTiles.append("WA2-door")
        walkableTiles.append("WB1-door")
        walkableTiles.append("WB2-door")
        
        let columnsLeft = [22, 31]
        let rowsLeft = [24, 24]
        
        let columnsRight = [19, 28]
        let rowsRight = [24, 24]
        
        for i in 0 ... columns.count-1  {
            let doorNode = SKSpriteNode(imageNamed: "door")
            
            doorNode.position = rockMap.centerOfTile(atColumn: columns[i], row: rows[i])
            doorNode.size = CGSize(width: 64, height: 64)
            doorNode.texture?.filteringMode = .nearest
            doorNode.lightingBitMask = 0b0001
            
            self.addChild(doorNode)
        }
        
        for i in 0 ... columnsLeft.count-1  {
            let doorNode = SKSpriteNode(imageNamed: "door-left")
            
            doorNode.position = rockMap.centerOfTile(atColumn: columnsLeft[i], row: rowsLeft[i])
            doorNode.size = CGSize(width: 64, height: 64)
            doorNode.texture?.filteringMode = .nearest
            doorNode.lightingBitMask = 0b0001
            
            self.addChild(doorNode)
        }
        
        for i in 0 ... columnsRight.count-1  {
            let doorNode = SKSpriteNode(imageNamed: "door-right")
            
            doorNode.position = rockMap.centerOfTile(atColumn: columnsRight[i], row: rowsRight[i])
            doorNode.size = CGSize(width: 64, height: 64)
            doorNode.texture?.filteringMode = .nearest
            doorNode.lightingBitMask = 0b0001
            
            self.addChild(doorNode)
        }
    }
    
    func buyTraps() {
        trapChecker = true
        let columns = [16]
        let rows = [22]
        //        let columns = [16, 26, 24]
        //        let rows = [22, 25, 23]
        
        for i in 0 ... columns.count-1  {
            let trapsNode = SKSpriteNode(imageNamed: "trap")
            
            // Load the first frame as initialization
            trapsNode.position = rockMap.centerOfTile(atColumn: columns[i], row: rows[i])
            trapsNode.size = CGSize(width: 64, height: 64)
            trapsNode.texture?.filteringMode = .nearest
            trapsNode.lightingBitMask = 0b0001
            
            // Change the frame per 0.2 sec
            trapsNode.run(.sequence([.fadeAlpha(to: 0, duration: 0),.playSoundFileNamed("trap", waitForCompletion: false), .fadeAlpha(to: 1, duration: 0.2), .wait(forDuration: 1.5), .fadeAlpha(to: 0, duration: 0.2)]))
            self.addChild(trapsNode)
        }
    }
    
    func buyHeal() {
        
        let healNode = SKSpriteNode(imageNamed: "chest")
        healNode.position = rockMap.centerOfTile(atColumn: 27, row: 26)
        healNode.size = CGSize(width: 64, height: 64)
        healNode.texture?.filteringMode = .nearest
        healNode.lightingBitMask = 0b0001
        
        self.addChild(healNode)
    }
    
    func buyChests() {
        chestChecker = true
        let chestNode = SKSpriteNode(imageNamed: "chest")
        chestNode.position = rockMap.centerOfTile(atColumn: 25, row: 39)
        chestNode.size = CGSize(width: 64, height: 64)
        chestNode.texture?.filteringMode = .nearest
        chestNode.lightingBitMask = 0b0001
        self.addChild(chestNode)
    }
    
    
    func isInRange(protagoNode: SKNode, enemyNode: SKNode) -> Bool {
        let heroX = protagoNode.position.x
        let heroY = protagoNode.position.y
        
        let enemyX = enemyNode.position.x
        let enemyY = enemyNode.position.y
        
        let xDistance = abs(heroX - enemyX)
        let yDistance = abs(heroY - enemyY)
        
        return xDistance < 1.9 * rockMap.tileSize.width && yDistance < 1.9 * rockMap.tileSize.height
    }
    
    func checkHP(){
        if lifeBar.size.width == .zero {
            coinCounter += 300
            lifeBar.removeFromParent()
            skeletonNode.run(.fadeAlpha(to: 0, duration: 0.5), completion: {
                self.skeletonNode.position = rockMap.centerOfTile(atColumn: 0, row: 0)
            })
            
            //            skeletonNode.removeFromParent()
            return
        } else if hitCounter >= skeletonHP {
            coinCounter += 300
            lifeBar.removeFromParent()
            skeletonNode.run(.fadeAlpha(to: 0, duration: 0.5), completion: {
                self.skeletonNode.position = rockMap.centerOfTile(atColumn: 0, row: 0)
            })
            
        }
        hitCounter += 1
        let newSize = CGSize(width: skeletonNode.size.width - skeletonNode.size.width * hitCounter/skeletonHP, height: skeletonNode.size.height/5)
        print("\(hitCounter) / \(skeletonHP)")
        //        lifeBar.size = newSize
        print("\(hitCounter/skeletonHP)")
        lifeBar.run(.resize(toWidth: newSize.width, duration: 0.4))
        if hitCounter == skeletonHP {  }
    }
    
    
    
    func tutorial() {
        
        hintLabel.fontSize = 32
        hintLabel.fontName = "Savior4"
        hintLabel.fontColor = SKColor.white
        hintLabel.horizontalAlignmentMode = .center
        hintLabel.verticalAlignmentMode = .center
        hintLabel.zPosition = 99
        hintLabel.position = CGPoint(x: 0, y: -350)
        hintLabel.text = hints[0]
        camera!.addChild(hintLabel)
        
    }
    
    func heroEsclamation() {
        
        esclamation.fontSize = 20
        esclamation.fontName = "Savior4"
        esclamation.fontColor = SKColor.white
        esclamation.horizontalAlignmentMode = .center
        esclamation.verticalAlignmentMode = .center
        esclamation.zPosition = 99
        esclamation.position = CGPoint(x: 0, y: 50)
        esclamation.text = "Where am I?"
        esclamation.run(.sequence([.fadeAlpha(to: 0, duration: 0), .fadeAlpha(to: 1, duration: 0.2), .wait(forDuration: 3), .fadeOut(withDuration: 0.2)]))
        heroNode.addChild(esclamation)
        
    }
    
    func heroRun() {
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "hero-run1")
        let herof1 = SKTexture.init(imageNamed: "hero-run2")
        let herof2 = SKTexture.init(imageNamed: "hero-run3")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.08)
        heroNode.run(SKAction.repeat(animation, count: 1))
    }
    
    func heroRunLeft() {
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "hero-run1-left")
        let herof1 = SKTexture.init(imageNamed: "hero-run2-left")
        let herof2 = SKTexture.init(imageNamed: "hero-run3-left")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.08)
        heroNode.run(SKAction.repeat(animation, count: 1))
    }
    
    func heroRunUp() {
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "hero-run1-up")
        let herof1 = SKTexture.init(imageNamed: "hero-run2-up")
        let herof2 = SKTexture.init(imageNamed: "hero-run3-up")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.08)
        heroNode.run(SKAction.repeat(animation, count: 1))
    }
    
    func heroRunDown() {
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "hero-run1-down")
        let herof1 = SKTexture.init(imageNamed: "hero-run2-down")
        let herof2 = SKTexture.init(imageNamed: "hero-run3-down")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.08)
        heroNode.run(SKAction.repeat(animation, count: 1))
    }
    
    func heroAttack() {
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "heroattack1")
        let herof1 = SKTexture.init(imageNamed: "heroattack2")
        let herof2 = SKTexture.init(imageNamed: "heroattack3")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.05)
        heroNode.run(SKAction.repeat(animation, count: 1))
    }
    
    func devilSpawn(){
        
        // hero frames
        
        let devil0 = SKTexture.init(imageNamed: "devil1")
        let devil1 = SKTexture.init(imageNamed: "devil2")
        let devil2 = SKTexture.init(imageNamed: "devil3")
        let devilFrames: [SKTexture] = [devil0, devil1, devil2]
        let devilTalk = ["HEHEHE!", "YOU OWE THE DEVIL, NOW.", "EARN PLENTY OF SOULS", "AND YOU'LL BE FREE."]
        
        devil0.filteringMode = .nearest
        devil1.filteringMode = .nearest
        devil2.filteringMode = .nearest
        
        // Load the first frame as initialization
        devilNode.size = CGSize(width: 64, height: 64)
        devilNode.texture?.filteringMode = .nearest
        devilNode.zPosition = 666
        devilNode.position = rockMap.centerOfTile(atColumn: 16 , row: 25)
        devilNode.lightingBitMask = 0b0001
        
        devilEsclamation.fontSize = 25
        devilEsclamation.fontName = "Savior4"
        devilEsclamation.fontColor = SKColor.white
        devilEsclamation.horizontalAlignmentMode = .center
        devilEsclamation.verticalAlignmentMode = .center
        devilEsclamation.zPosition = 99
        devilEsclamation.position = CGPoint(x: 0, y: 50)
        
        devilNode.addChild(devilEsclamation)
        
        let dialog1 = SKAction.run {
            self.devilEsclamation.text = devilTalk[0]
        }
        let dialog2 = SKAction.run {
            self.devilEsclamation.text = devilTalk[1]
        }
        let dialog3 = SKAction.run {
            self.devilEsclamation.text = devilTalk[2]
        }
        let dialog4 = SKAction.run {
            self.devilEsclamation.text = devilTalk[3]
        }
        
        let anim = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .fadeAlpha(to: 1, duration: 0.2), .wait(forDuration: 3), .fadeOut(withDuration: 0.2), .wait(forDuration: 1)])
        
        devilEsclamation.run(.sequence([dialog1,anim, dialog2, anim, dialog3, anim, dialog4, anim]), withKey: "devilDialog")
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: devilFrames, timePerFrame: 0.2)
        devilNode.run(SKAction.repeatForever(animation))
        
        self.addChild(devilNode)
        devilChecker = true
    }
    
    func heroSpawn(){
        
        // hero frames
        let herof0 = SKTexture.init(imageNamed: "hero-idle1")
        let herof1 = SKTexture.init(imageNamed: "hero-idle2")
        let herof2 = SKTexture.init(imageNamed: "hero-idle3")
        let heroFrames: [SKTexture] = [herof0, herof1, herof2]
        
        herof0.filteringMode = .nearest
        herof1.filteringMode = .nearest
        herof2.filteringMode = .nearest
        
        // Load the first frame as initialization
        heroNode.size = CGSize(width: 64, height: 64)
        heroNode.texture?.filteringMode = .nearest
        heroNode.zPosition = 1000
        heroNode.position = rockMap.centerOfTile(atColumn: 16 , row: 14)
        heroNode.lightingBitMask = 0b0001
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.2)
        heroNode.run(SKAction.repeatForever(animation))
        
        self.addChild(heroNode)
    }
    
    func dragonSpawn(){
        dragonChecker = true
        view?.isUserInteractionEnabled = false
        let dragon1 = SKTexture.init(imageNamed:"dragon00")
        let dragon2 = SKTexture.init(imageNamed:"dragon01")
        let dragFrames: [SKTexture] = [dragon1, dragon2]
        dragon1.filteringMode = .nearest
        dragon2.filteringMode = .nearest
        dragonNode.position = rockMap.centerOfTile(atColumn: 25, row: 50)
        dragonNode.size = CGSize(width: 512, height: 512)
        dragonNode.lightingBitMask = 0b0001
        dragonNode.zPosition = 1001
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let fallDown = SKAction.move(to: (rockMap.centerOfTile(atColumn: 25, row: 39)), duration: 0.5)
        let audio = SKAction.playSoundFileNamed("slam", waitForCompletion: false)
        let shake = SKAction.run {
            self.sceneShake(shakeCount: 1, intensity: CGVector(dx: 20, dy: 20), shakeDuration: 1)
            self.sceneShake(shakeCount: 1, intensity: CGVector(dx: 10, dy: 5), shakeDuration: 0.2)
        }
        let wait = SKAction.wait(forDuration: 0.2)
        let animation = SKAction.animate(with: dragFrames, timePerFrame: 0.5)
        let seq = SKAction.repeat(animation, count: 2)
        let end = SKAction.move(to: (heroNode.position), duration: 0.2)
        
        dragonNode.run(SKAction.repeat(.sequence([fadeIn, fallDown, audio, shake, wait, seq, end]),count: 1),completion: {
            self.demoOver()
        })
        
        self.addChild(dragonNode)
    }
    
    func hintSpawn() {
        hint1.position = CGPoint(x: 0, y: 0)
        hint1.zPosition = 1500
        hint1.size.width = 405
        hint1.size.height = 250
        
        posCenter.zPosition = 1500
        posCenter.position = CGPoint(x:0, y:0)
        camera!.addChild(posCenter)
        posCenter.addChild(hint1)
        
        //        camera!.addChild(hint1)
        
        hint2.position = CGPoint(x: 0, y: 0)
        hint2.zPosition = 1501
        hint2.size.width = 405
        hint2.size.height = 250
    }
    
    func skeletonSpawn(){
        
        
        // 4 skel frames
        let skelf0 = SKTexture.init(imageNamed: "skeleton1")
        let skelf1 = SKTexture.init(imageNamed: "skeleton2")
        let skelf2 = SKTexture.init(imageNamed: "skeleton3")
        let skelFrames: [SKTexture] = [skelf0, skelf1, skelf2]
        skelf0.filteringMode = .nearest
        skelf1.filteringMode = .nearest
        skelf2.filteringMode = .nearest
        
        // Load the first frame as initialization
        skeletonNode.position = rockMap.centerOfTile(atColumn: 26, row: 24)
        skeletonNode.size = CGSize(width: 64, height: 64)
        skeletonNode.texture?.filteringMode = .nearest
        skeletonNode.lightingBitMask = 0b0001
        
        let barSize = CGSize(width: skeletonNode.size.width, height: skeletonNode.size.height/5)
        lifeBar = SKSpriteNode(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), size: barSize)
        lifeBar.lightingBitMask = 0b0001
        lifeBar.zPosition = 1001
        let lifeBarPosition = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y + skeletonNode.size.height)
        lifeBar.position = lifeBarPosition
        self.addChild(lifeBar)
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: skelFrames, timePerFrame: 0.2)
        skeletonNode.run(SKAction.repeatForever(animation))
        self.addChild(skeletonNode)
        
        //        let move1 = SKAction.move(to: (rockMap.centerOfTile(atColumn: 13, row: 13)), duration: 0.2)
        //        let waitAction = SKAction.wait(forDuration: 1.5)
        //        skeletonNode.run(SKAction.repeatForever(SKAction.sequence([chaseHero(hunterNode: skeletonNode, huntedNode: heroNode),waitAction])))
        
    }
    
    func chaseHero(hunterNode: SKSpriteNode, huntedNode: SKSpriteNode) -> SKAction {
        
        let hunterX = hunterNode.position.x
        let hunterY = hunterNode.position.y
        
        let huntedX = huntedNode.position.x
        let huntedY = huntedNode.position.y
        
        let distanceX = huntedX.rounded() - hunterX.rounded()
        let distanceY = huntedY.rounded() - hunterY.rounded()
        
        let travelDistanceX = rockMap.tileSize.width
        let travelDistanceY = rockMap.tileSize.height
        
        //        if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
        
        if abs(distanceX) > abs(distanceY) && distanceX != 0 {
            if distanceX > 0 {
                let destinationPoint = CGPoint(x: skeletonNode.position.x + travelDistanceX, y: skeletonNode.position.y)
                if !onLand(characterPosition: destinationPoint, map: rockMap) { return .wait(forDuration: 0.2) }
                skeletonBumpPosition = skeletonNode.position
                return .moveBy(x: travelDistanceX, y: 0, duration: 0.2)
            } else {
                let destinationPoint = CGPoint(x: skeletonNode.position.x - travelDistanceX, y: skeletonNode.position.y)
                if !onLand(characterPosition: destinationPoint, map: rockMap) { return .wait(forDuration: 0.2) }
                skeletonBumpPosition = skeletonNode.position
                return .moveBy(x: -travelDistanceX, y: 0, duration: 0.2)
            }
        } else if abs(distanceX) <= abs(distanceY) && distanceY != 0 {
            if distanceY > 0 {
                let destinationPoint = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y + travelDistanceY)
                if !onLand(characterPosition: destinationPoint, map: rockMap) { return .wait(forDuration: 0.2) }
                skeletonBumpPosition = skeletonNode.position
                return .moveBy(x: 0, y: travelDistanceY, duration: 0.2)
            } else {
                let destinationPoint = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y - travelDistanceY)
                if !onLand(characterPosition: destinationPoint, map: rockMap) { return .wait(forDuration: 0.2) }
                skeletonBumpPosition = skeletonNode.position
                return .moveBy(x: 0, y: -travelDistanceY, duration: 0.2)
            }
        }
        return .moveBy(x: 0, y: 0, duration: 0)
    }
    
    func coinSpawn(){
        
        coinNode.position = CGPoint(x: -170, y: 370)
        coinNode.size = CGSize(width: 40, height: 40)
        coinNode.texture?.filteringMode = .nearest
        coinNode.zPosition = 1002
        
        
        label.position = CGPoint(x: -140, y: 357)
        label.horizontalAlignmentMode = .left
        label.fontColor = SKColor.white
        label.fontSize = 55
        label.zPosition = 1002
        
        camera!.addChild(label)
        camera!.addChild(coinNode)
        
    }
    
    //    func hearts(health:Int) {
    //
    //        let i:Int = health
    //        var positionAdd:CGFloat = 10.0
    //        for _ in 0 ... i-1 {
    //            let heartContainers = SKSpriteNode(imageNamed: "heart-empty")
    //            heartContainers.size = CGSize(width: 30, height: 30)
    //            heartContainers.position = CGPoint(x: -180 + positionAdd, y: 325)
    //            heartContainers.zPosition = 99
    //            positionAdd += 40.0
    //            camera!.addChild(heartContainers)
    //        }
    //    }
    //
    //    func heartsFull(health:Int) {
    //
    //        let i:Int = health
    //        var positionAdd:CGFloat = 10.0
    //
    //        for _ in 0 ... i-1 {
    //            let fullHearts = SKSpriteNode(imageNamed: "heart-full")
    //            fullHearts.size = CGSize(width: 30, height: 30)
    //            fullHearts.position = CGPoint(x: -180 + positionAdd, y: 325)
    //            fullHearts.zPosition = 100
    //            positionAdd += 40.0
    //            camera!.addChild(fullHearts)
    //        }
    //    }
    func hearts() {
        heartContainers.size = CGSize(width: 118, height: 30)
        heartContainers.position = CGPoint(x: -134, y: 325)
        heartContainers.zPosition = 1002
        camera!.addChild(heartContainers)
    }
    
    func heartsDown() {
        if (heroNode.health == 3) {
            heartContainers.texture = SKTexture(imageNamed: "3of3")
        } else if (heroNode.health == 2) {
            heartContainers.texture = SKTexture(imageNamed: "2of3")
        } else if (heroNode.health == 1) {
            heartContainers.texture = SKTexture(imageNamed: "1of3")
        }
    }
    
    func attack(targetPosition: CGPoint) {
        let newPosition = CGPoint.init(x: (Int.random(in: -3...3)*Int(rockMap.tileSize.width)) + Int(targetPosition.x), y: (Int.random(in: -6...6) * Int(rockMap.tileSize.height)) + Int(targetPosition.y))
        
        let column = rockMap.tileColumnIndex(fromPosition: newPosition)
        let row = rockMap.tileRowIndex(fromPosition: newPosition)
        
        skeletonNode.position = rockMap.centerOfTile(atColumn: column, row: row)
    }
    
    func bumpNoDmg(node: SKNode, arrivingDirection: CGVector) {
        cont += 1
        if(cont != 2)
        {
            let bounceDestination = CGPoint(x: -arrivingDirection.dx, y: -arrivingDirection.dy)
            node.run(.moveBy(x: bounceDestination.x, y: bounceDestination.y, duration: 0.1))
        }else{
            cont = 0
        }
    }
    
    
    func bump(node: SKNode, arrivingDirection: CGVector) {
        cont += 1
        if(cont != 2)
        {
            let bounceDestination = CGPoint(x: -arrivingDirection.dx, y: -arrivingDirection.dy)
            //        node.run(.move(to: bounceDestination, duration: 0.1))
            node.run(.moveBy(x: bounceDestination.x, y: bounceDestination.y, duration: 0.1))
            heroNode.health -= 1
            let anim1 = SKAction.fadeOut(withDuration: 0.09)
            let anim2 = SKAction.fadeIn(withDuration: 0.09)
            let anim3 = SKAction.fadeOut(withDuration: 0.07)
            let anim4 = SKAction.fadeIn(withDuration: 0.07)
            heroNode.run(SKAction.sequence([anim1, anim2, anim3, anim4]))
            //            heartsDamages(health: heroNode.health)
            hitSound()
            heartsDown()
            heroNode.die()
            print(heroNode.health)
            if (heroNode.died == true){
                scene?.view?.isPaused = true
                gameOver()
            }
        }else{
            cont = 0
        }
    }
    
    
    
    func addSwipe() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            gesture.direction = direction
            view?.addGestureRecognizer(gesture)// sel.view
        }
    }
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        let direction = sender.direction
        switch direction {
        case .right:
            let newPosition = CGPoint(x: heroNode.position.x + 64, y: heroNode.position.y)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRun()
            dashSound()
            let move = SKAction.move(by: .init(dx:64, dy:0), duration: 0.15)
            heroNode.run(move, completion:{
                currentColumn += 1
                moveVector = .init(dx: 64, dy: 0)
            } )
            tutorialCounter+=1
            print("Gesture direction: Right")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
        case .left:
            let newPosition = CGPoint(x: heroNode.position.x - 64, y: heroNode.position.y)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRunLeft()
            dashSound()
            let move = SKAction.move(by: .init(dx:-64, dy:0), duration: 0.15)
            heroNode.run(move, completion:{
                currentColumn -= 1
                moveVector = .init(dx: -64, dy: 0)
            } )
            tutorialCounter+=1
            print("Gesture direction: Left")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
            
        case .up:
            let newPosition = CGPoint(x: heroNode.position.x, y: heroNode.position.y + 64)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRunUp()
            //            buyLights()
            let move = SKAction.move(by: .init(dx:0, dy:64), duration: 0.15)
            heroNode.run(move, completion:{
                currentRow += 1
                moveVector = .init(dx: 0, dy: 64)
            } )
            dashSound()
            tutorialCounter+=1
            print("Gesture direction: Up")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
            
        case .down:
            let newPosition = CGPoint(x: heroNode.position.x, y: heroNode.position.y - 64)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRunDown()
            let move = SKAction.move(by: .init(dx:0, dy:-64), duration: 0.15)
            heroNode.run(move, completion:{
                currentRow -= 1
                moveVector = .init(dx: 0, dy: -64)
            } )
            //            buyDoors()
            dashSound()
            tutorialCounter+=1
            print("Gesture direction: Down")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
            
        default:
            print("Unrecognized Gesture Direction")
        }
    }
    
    func onLand(characterPosition: CGPoint, map: SKTileMapNode) -> Bool {
        let column = map.tileColumnIndex(fromPosition: characterPosition)
        let row = map.tileRowIndex(fromPosition: characterPosition)
        var counter = false
        
        for i in walkableTiles.indices {
            if map.tileDefinition(atColumn: column, row: row)?.name != walkableTiles[i]   {
                
            } else { counter = true }
        }
        print(counter)
        return counter
    }
    
    
    
    func comparePositionRound(position1: CGPoint, position2: CGPoint) -> Bool {
        if position1.x.rounded() == position2.x.rounded() && position1.y.rounded() == position2.y.rounded() {
            return true
        }
        else {
            return false
        }
    }
    
    func addMap() {
        mapImage.image = UIImage(named: "map")
        mapImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view?.insertSubview(mapImage, at: 0)
    }
    
    
    func gameOver() {
        removeAllChildren()
        removeAllActions()
        hitCounter = CGFloat(-1)
        overImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        overImage.anchorPoint = CGPoint(x: 1, y:1)
        overImage.size = view!.bounds.size
        addChild(overImage)
        view?.scene?.isPaused = false
    }
    
    func demoOver() {
        view?.isUserInteractionEnabled = true
        removeAllChildren()
        removeAllActions()
        hitCounter = CGFloat(-1)
        overImage2.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        overImage2.anchorPoint = CGPoint(x: 1, y:1)
        overImage2.size = view!.bounds.size
        addChild(overImage2)
        view?.scene?.isPaused = false
        let wait = SKAction.wait(forDuration: 2)
        let reset = SKAction.run {
            let gameScene = MenuScene(size: self.view!.frame.size)
            gameScene.scaleMode = .aspectFit
            self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.5))
        }
        scene!.run(SKAction.repeat(.sequence([wait, reset]),count: 1),completion: {
            
        })
    }
    
    
    override func didMove(to view: SKView) {
        
        shopList = [[],[SoldProduct(image: crystalPic, price: 10, priceShow:"Spend 10", name: "Light Crystal", soldOut: false, amount: 1), SoldProduct(image: doorPic, price: 100, priceShow: "Spend 100", name: "Doors", soldOut: false, amount: 1), SoldProduct(image: trapsPic, price:-200, priceShow: "Earn 200", name: "Traps", soldOut: false, amount:1) ,SoldProduct(image: torchPic, price:100, priceShow:"Spend 100", name:"Torches", soldOut: false, amount:1), SoldProduct(image: chestPic, price: 1000, priceShow:"Spend 1.000", name:"Chests", soldOut: false, amount:1)],[SoldProduct(image: skeletonPic, price: -70, priceShow: "Earn 70 Souls - Kill it for 1.000", name: "Skeletons", soldOut: false, amount: 1)], [SoldProduct(image: nil, price: 0, priceShow: "0", name: "Coming Soon", soldOut: true, amount: 0)]]
        
        
        coinCounter = 10000
        
        backgroundColor = SKColor.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        addSwipe()
        camera!.setScale(1.2)
        
        gameMusic(father: self)
        
        heartContainers = SKSpriteNode(imageNamed: "3of3")
        
        // Function for apply PixelArt shit to the tiles
        for tileGroup in tileSet.tileGroups {
            for tileRule in tileGroup.rules {
                for tileDefinition in tileRule.tileDefinitions {
                    for texture in tileDefinition.textures {
                        texture.filteringMode = .nearest
                        tileDefinition.size = rockMap.tileSize
                    }
                }
            }
        }
        
        for node in self.children {
            if ( node.name == "rocks") {
                rockMap = node as! SKTileMapNode
            } else if ( node.name == "water"){
                waterMap = node as! SKTileMapNode
            }
        }
        
        rockMap.lightingBitMask = 0b0001
        
        lightNode.position = heroNode.position
        lightNode.categoryBitMask = 0b0001
        lightNode.lightColor = .white
        lightNode.falloff = 4
        
        self.addChild(lightNode)
        
        startAccelerometers()
        heroSpawn()
        heroEsclamation()
        coinSpawn()
        hearts()
        tutorial()
        buyHeal()
        
        shop = SKSpriteNode(imageNamed: "shop")
        shop.position = .init(x: 160, y: 370)
        shop.size = CGSize(width: 48, height: 48)
        shop.alpha = 0
        shop.zPosition = 1000
        camera!.addChild(shop)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
        camera!.run(pinch)
        sender.scale = 1.0
        
        if (camera!.xScale > 3 ){
            addMap()
            mapImage.alpha = 1
        }else {mapImage.alpha = 0}
        
        if(camera!.xScale < 1){
            camera!.setScale(1)
        }
    }
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.timer = Timer(fire: Date(), interval: (8.0/60.0), /*change the value here to change the coin aquision speed*/
                repeats: true, block: { (timer) in
                    // Get the accelerometer data.
                    if let data = self.motion.accelerometerData {
                        let x = data.acceleration.x
                        let y = data.acceleration.y
                        let z = data.acceleration.z
                        // Use the accelerometer data in your app.
                        if abs(x)>1.1 || abs(y)>1.1 || abs(z)>1.1 { self.eventCoin() }
                        //                self.timer.timeInterval = 1.0 / x
                        
                    }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    func eventCoin() {
        coinCounter += 1
        label.text = "\(coinCounter)"
        jumpingCoin(node: coinNode)
        if coinCounter % 100 == 0 {
            run(.playSoundFileNamed("soul.wav", waitForCompletion: false))
        } else {
            run(.playSoundFileNamed("soul.wav", waitForCompletion: false))
        }
    }
    
    func jumpingCoin(node: SKNode) {
        node.run(SKAction.sequence([.moveBy(x: 0, y: 20, duration: 0.18), .moveBy(x: 0, y: -20, duration: 0.12), .moveBy(x: 0, y: 10, duration: 0.066), .moveBy(x: 0, y: -10, duration: 0.1)]))
    }
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
        let sceneView = self.scene!.view! as UIView
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = shakeDuration / Double(shakeCount)
        shakeAnimation.repeatCount = Float(shakeCount)
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))
        sceneView.layer.add(shakeAnimation, forKey: "position")
    }
}

