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

var cont = 0 // counter for BUMP action
var coinCounter:Int = 0

var heartContainers = SKSpriteNode(imageNamed: "3of3")

class GameScene: SKScene {
    
    var label = SKLabelNode(fontNamed: "Savior4")
    let skeletonNode = SKSpriteNode(imageNamed: "skeleton1")
    var lifeBar = SKSpriteNode(texture: nil)
    let cameraNode = SKCameraNode()
    let coinNode = SKSpriteNode(imageNamed: "soul2")
    let heroNode: Character = Character.init()
    let mapImage = UIImageView(frame: UIScreen.main.bounds)
    let overImage = SKSpriteNode(imageNamed: "gameOver")
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
        
        // DOOR 1 TELEPORT
        if heroNode.position == rockMap.centerOfTile(atColumn: 16, row: 17) {
            heroNode.position = rockMap.centerOfTile(atColumn: 16, row: 22)
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
           
           let columns = [16]
           let rows = [17]
        walkableTiles.append("WA2-door")
        
                for i in 0 ... columns.count-1  {
               let doorNode = SKSpriteNode(imageNamed: "door")
               
               doorNode.position = rockMap.centerOfTile(atColumn: columns[i], row: rows[i])
               doorNode.size = CGSize(width: 64, height: 64)
               doorNode.texture?.filteringMode = .nearest
               doorNode.lightingBitMask = 0b0001
               
               self.addChild(doorNode)
           }
          
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
            skeletonNode.run(.fadeAlpha(to: 0, duration: 1))
            skeletonNode.position = rockMap.centerOfTile(atColumn: 0, row: 0)
            //            skeletonNode.removeFromParent()
            return
        }
        hitCounter += 1
        let newSize = CGSize(width: skeletonNode.size.width - skeletonNode.size.width * hitCounter/skeletonHP, height: skeletonNode.size.height/5)
        print("\(hitCounter) / \(skeletonHP)")
        //        lifeBar.size = newSize
        print("\(hitCounter/skeletonHP)")
        lifeBar.run(.resize(toWidth: newSize.width, duration: 0.4))
        if hitCounter == skeletonHP {  }
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
        heroNode.position = rockMap.centerOfTile(atColumn: 16 , row: 14)
        heroNode.lightingBitMask = 0b0001
        
        // Change the frame per 0.2 sec
        let animation = SKAction.animate(with: heroFrames, timePerFrame: 0.2)
        heroNode.run(SKAction.repeatForever(animation))
        
        self.addChild(heroNode)
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
        coinNode.zPosition = 99
        
        
        label.position = CGPoint(x: -140, y: 357)
        label.horizontalAlignmentMode = .left
        label.fontColor = SKColor.white
        label.fontSize = 55
        label.zPosition = 99
        
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
         heartContainers.zPosition = 100
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
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
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
            heroNode.run(.move(by: .init(dx: 64, dy: 0), duration: 0.2))
            heroNode.xScale = 1.0;
            currentColumn += 1
            tutorialCounter+=1
            moveVector = .init(dx: 64, dy: 0)
            print("Gesture direction: Right")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
        case .left:
            let newPosition = CGPoint(x: heroNode.position.x - 64, y: heroNode.position.y)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRun()
            dashSound()
            heroNode.run(.move(by: .init(dx: -64, dy: 0), duration: 0.2))
            heroNode.xScale = -1.0;
            currentColumn -= 1
            tutorialCounter+=1
            moveVector = .init(dx: -64, dy: 0)
            print("Gesture direction: Left")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
            
        case .up:
            let newPosition = CGPoint(x: heroNode.position.x, y: heroNode.position.y + 64)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroRunUp()
            buyLights()
            heroNode.run(.move(by: .init(dx: 0, dy: 64), duration: 0.2))
            dashSound()
            currentRow += 1
            tutorialCounter+=1
            moveVector = .init(dx: 0, dy: 64)
            print("Gesture direction: Up")
            print("\(currentColumn) , \(currentRow)")
            print(heroNode.position)
            
        case .down:
            let newPosition = CGPoint(x: heroNode.position.x, y: heroNode.position.y - 64)
            if (onLand(characterPosition: newPosition, map: rockMap) == false){return}
            heroNode.run(.move(by: .init(dx: 0, dy: -64), duration: 0.2))
            heroRunDown()
            buyDoors()
            dashSound()
            currentRow -= 1
            tutorialCounter+=1
            moveVector = .init(dx: 0, dy: -64)
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
        overImage.size = CGSize(width: 320, height: 320)
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
        coinSpawn()
        skeletonSpawn()
        hearts()
        tutorial()
        
        shop = SKSpriteNode(imageNamed: "shop")
        shop.position = .init(x: self.frame.maxX - self.frame.maxX/10, y: self.frame.maxY - self.frame.maxY/10)
        shop.alpha = 0
        self.addChild(shop)
        
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
            
            camera!.setScale(1.5)
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
            run(.playSoundFileNamed("smb_1-up.wav", waitForCompletion: false))
        } else {
            run(.playSoundFileNamed("smb_coin.wav", waitForCompletion: false))
        }
        
        if coinCounter == 10 {
            shop.run(.fadeAlpha(to: 1, duration: 2.5))
        }
    }
    
    func jumpingCoin(node: SKNode) {
        node.run(SKAction.sequence([.moveBy(x: 0, y: 30, duration: 0.18), .moveBy(x: 0, y: -30, duration: 0.12), .moveBy(x: 0, y: 10, duration: 0.066), .moveBy(x: 0, y: -10, duration: 0.1)]))
    }

}

