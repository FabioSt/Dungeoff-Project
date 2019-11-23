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
let tileSet = rockMap.tileSet

// Tutorial Stuff
var hintLabel: SKLabelNode = SKLabelNode()
let hints: Array<String> = ["Shake to earn some coin", "Great, you can buy a torch!", "Swipe to Move", "Great"]
var tutorialCounter :Int = 0

let skeletonHP = CGFloat(6)
var hitCounter = CGFloat(0)

let lightNode = SKLightNode()

var gesture = UISwipeGestureRecognizer()

var shopView = ShopView()

var cont = 0 // counter for BUMP action
var coinCounter:Int = 0

var heartContainers = SKSpriteNode(imageNamed: "3of3")

class GameScene: SKScene {
    
    var chestChecker = false // check if dragon should be spawn
    var dragonChecker = false
    
    var label = SKLabelNode(fontNamed: "Savior4")
    var esclamation = SKLabelNode(fontNamed: "Savior4")
    let dragonNode = SKSpriteNode(imageNamed:"dragon01")
    let skeletonNode = SKSpriteNode(imageNamed: "skeleton1")
    var lifeBar = SKSpriteNode(texture: nil)
    let cameraNode = SKCameraNode()
    let coinNode = SKSpriteNode(imageNamed: "soul2")
    let heroNode: Character = Character.init()
    let mapImage = UIImageView(frame: UIScreen.main.bounds)
    let overImage = SKSpriteNode(imageNamed: "gameover")
    var shop = SKSpriteNode()
    let motion = CMMotionManager()
    var timer = Timer()
    
    var walkableTiles = ["A1", "A2", "A3", "B1", "B2", "B3","C1","C2","C3"]
    
    func checkPositions() {
        if comparePositionRound(position1: heroNode.position, position2: skeletonNode.position) {
            //            attack(targetPosition: skeletonNode.position)
            bump(node: heroNode, arrivingDirection: moveVector)
            checkHP()
            print("move Vector is \(moveVector)")
        } else if comparePositionRound(position1: heroNode.position, position2: coinNode.position) {
            if coinNode.parent != nil {
                coinCounter += 1
                coinNode.removeFromParent()
                print(coinCounter)
                label.text = "\(coinCounter)"
            }
        }
        
        
        // DRAGON SPAWN
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 25, row: 36).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 36).y.rounded() {
            
            while (dragonChecker == false) && (chestChecker == true){
                dragonSpawn()
            }
        }
        
        // DOOR 1 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 16, row: 17).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 16, row: 17).y.rounded() {
            let destination = rockMap.centerOfTile(atColumn: 16, row: 22)
            gesture.isEnabled = false
//            heroNode.position = destination
            let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
            heroNode.run(animation, completion: {
                gesture.isEnabled = true
            })
        }
        
        // DOOR 2 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 16, row: 21).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 16, row: 21).y.rounded() {
                    let destination = rockMap.centerOfTile(atColumn: 16, row: 16)
        //            heroNode.position = destination
            gesture.isEnabled = false
                    //         heroNode.position = destination
                    let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                    heroNode.run(animation, completion: {
                    gesture.isEnabled = true
                })
            }
        
        // DOOR 3 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 19, row: 24).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 19, row: 24).y.rounded() {
                    let destination = rockMap.centerOfTile(atColumn: 23, row: 24)
        //            heroNode.position = destination
            gesture.isEnabled = false
            //            heroNode.position = destination
                    let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                    heroNode.run(animation, completion: {
                    gesture.isEnabled = true
                    })
            }
        
        // DOOR 3 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 22, row: 24).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 22, row: 24).y.rounded() {
                    let destination = rockMap.centerOfTile(atColumn: 18, row: 24)
        //            heroNode.position = destination
            gesture.isEnabled = false
                    //            heroNode.position = destination
                let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                    heroNode.run(animation, completion: {
                    gesture.isEnabled = true
                    })
                }
        
        // DOOR 4 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 25, row: 27).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 27).y.rounded() {
                    
                    let destination = rockMap.centerOfTile(atColumn: 25, row: 32)
        //            heroNode.position = destination
                gesture.isEnabled = false
                    //            heroNode.position = destination
                    let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                    heroNode.run(animation, completion: {
                    gesture.isEnabled = true
                    })
                }
        
        // DOOR 5 TELEPORT
        if heroNode.position.x.rounded() == rockMap.centerOfTile(atColumn: 25, row: 31).x.rounded() && heroNode.position.y.rounded() == rockMap.centerOfTile(atColumn: 25, row: 31).y.rounded() {
                    let destination = rockMap.centerOfTile(atColumn: 25, row: 26)
        //            heroNode.position = destination
            gesture.isEnabled = false
            //            heroNode.position = destination
                        let animation = SKAction.sequence([.fadeAlpha(to: 0, duration: 0), .move(to: destination, duration: 0.3), .fadeAlpha(to: 1, duration: 0.15)])
                        heroNode.run(animation, completion: {
                            gesture.isEnabled = true
                        })
                }
        
    }
    
    override func update(_ currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
        let lifeBarPosition = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y + skeletonNode.size.height)
        lifeBar.position = lifeBarPosition
        
        lightNode.position = heroNode.position
        
        
        camera?.position = heroNode.position
        checkPositions()
        label.text = "\(coinCounter)"
        
        if skeletonNode.alpha == 0 { skeletonNode.removeFromParent() }
        
        if tutorialCounter == 4 {
            hintLabel.text = hints[3]
        }
        
        if coinCounter > 10 {
            shop.run(.fadeAlpha(to: 1, duration: 2.5))
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
        if node === self.overImage {
            let restart = GameScene(fileNamed: "Map")
            restart?.scaleMode = SKSceneScaleMode.aspectFit
            restart?.size = (view?.frame.size)!
            view?.presentScene(restart!)
            heroNode.position = rockMap.centerOfTile(atColumn: rockMap.numberOfRows/2 , row: rockMap.numberOfColumns/2)
            //            heroSpawn()
        }
        if node === self.heroNode {
            lightNode.run(.falloff(to: 1, duration: 0.2))
            lightNode.falloff = 1
            lightNode.lightColor = #colorLiteral(red: 0.7681630254, green: 0.9664419293, blue: 1, alpha: 1)
            backgroundColor = SKColor.init(red: 0.1647, green: 0.0745, blue: 0.1961, alpha: 1.0)
        }
        if node === self.shop {
            if (view?.subviews.contains(shopView))! {
                shopView.removeFromSuperview()
            } else {
                summonShop()
            }
        }
    }
    
    func summonShop() {
        shopView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let frame = CGRect(x: 30, y: 150, width: (view?.frame.width)!-60, height: (view?.frame.height)!-150)
        shopView.frame = frame
        shopView.backgroundColor = .white
        self.scene?.view?.addSubview(shopView)
        shopView.reloadData()
    }
    
    func buyLights() {
        
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
    
    func buyDoors() {
           
           let columns = [16, 16, 19, 22, 25, 25]
              let rows = [17, 21, 24, 24, 27, 31]
        walkableTiles.append("WA2-door")
        walkableTiles.append("WB1-door")
        walkableTiles.append("WB2-door")
        
                for i in 0 ... columns.count-1  {
               let doorNode = SKSpriteNode(imageNamed: "door")
               
               doorNode.position = rockMap.centerOfTile(atColumn: columns[i], row: rows[i])
               doorNode.size = CGSize(width: 64, height: 64)
               doorNode.texture?.filteringMode = .nearest
               doorNode.lightingBitMask = 0b0001
               
               self.addChild(doorNode)
           }
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
            coinCounter += 100
            lifeBar.removeFromParent()
            skeletonNode.run(.fadeAlpha(to: 0, duration: 1), completion: {
                self.skeletonNode.position = rockMap.centerOfTile(atColumn: 0, row: 0)
            })
            
            //            skeletonNode.removeFromParent()
            return
        } else if hitCounter >= skeletonHP {
            coinCounter += 100
            lifeBar.removeFromParent()
            skeletonNode.run(.fadeAlpha(to: 0, duration: 1), completion: {
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
        
        hintLabel.fontSize = 30
        hintLabel.fontName = "Savior4"
        hintLabel.fontColor = SKColor.white
        hintLabel.horizontalAlignmentMode = .center
        hintLabel.verticalAlignmentMode = .center
        hintLabel.zPosition = 99
        hintLabel.position = CGPoint(x: 0, y: -350)
        hintLabel.text = hints[2]
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
            self.gameOver()
        })
        
    self.addChild(dragonNode)
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
        skeletonNode.position = rockMap.centerOfTile(atColumn: 14, row: 13)
        skeletonNode.size = CGSize(width: 64, height: 64)
        skeletonNode.texture?.filteringMode = .nearest
        skeletonNode.lightingBitMask = 0b0001
        
        let barSize = CGSize(width: skeletonNode.size.width, height: skeletonNode.size.height/5)
        lifeBar = SKSpriteNode(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), size: barSize)
        lifeBar.lightingBitMask = 0b0001
        let lifeBarPosition = CGPoint(x: skeletonNode.position.x, y: skeletonNode.position.y + skeletonNode.size.height)
        lifeBar.position = lifeBarPosition
        self.addChild(lifeBar)
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: skelFrames, timePerFrame: 0.2)
        skeletonNode.run(SKAction.repeatForever(animation))
        self.addChild(skeletonNode)
        
        //        let move1 = SKAction.move(to: (rockMap.centerOfTile(atColumn: 13, row: 13)), duration: 0.2)
        let waitAction = SKAction.wait(forDuration: 1.5)
//        skeletonNode.run(SKAction.repeatForever(SKAction.sequence([chaseHero(hunterNode: skeletonNode, huntedNode: heroNode),waitAction])))
        
    }
    
    func chaseHero(hunterNode: SKSpriteNode, huntedNode: SKSpriteNode) -> SKAction {
        
        let hunterX = hunterNode.position.x
        let hunterY = hunterNode.position.y
        
        let huntedX = huntedNode.position.x
        let huntedY = huntedNode.position.y
        
        let distanceX = huntedX - hunterX
        let distanceY = huntedY - hunterY
        
        let travelDistanceX = rockMap.tileSize.width
        let travelDistanceY = rockMap.tileSize.height
        
        if abs(distanceX) < abs(distanceY) && distanceX != 0 {
            if distanceX > 0 {
                return .moveBy(x: travelDistanceX, y: 0, duration: 0.2)
            } else { return .moveBy(x: -travelDistanceX, y: 0, duration: 0.2) }
        } else if abs(distanceX) > abs(distanceY) && distanceY != 0 {
            if distanceY > 0 {
                return .moveBy(x: 0, y: travelDistanceY, duration: 0.2)
            } else { return .moveBy(x: 0, y: -travelDistanceY, duration: 0.2) }
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
    
    
    
    func bump(node: SKNode, arrivingDirection: CGVector) {
        cont += 1
        if(cont != 2)
        {
            let bounceDestination = CGPoint(x: -arrivingDirection.dx, y: -arrivingDirection.dy)
            //        node.run(.move(to: bounceDestination, duration: 0.1))
            node.run(.moveBy(x: bounceDestination.x, y: bounceDestination.y, duration: 0.1))
            heroNode.health -= 1
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
            buyDoors()
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
    
    
    
    override func didMove(to view: SKView) {
        
        //        menuMusic(father: self)
        
        backgroundColor = SKColor.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        addSwipe()
        camera!.setScale(1.2)
        
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
        skeletonSpawn()
        hearts()
        tutorial()
        
        buyChests()
        
        shop = SKSpriteNode(imageNamed: "shop")
        shop.position = .init(x: 180, y: 370)
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

