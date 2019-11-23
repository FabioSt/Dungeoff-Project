//
//  Functions.swift
//  Dungeoff
//
//  Created by Fabio Staiano on 18/11/2019.
//  Copyright © 2019 Fabio Staiano. All rights reserved.
//

import SpriteKit
import AVFoundation

func dashSound() {
       if let soundURL = Bundle.main.url(forResource: "sprint", withExtension: "mp3") {
           var mySound: SystemSoundID = 0
           AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
           AudioServicesPlaySystemSound(mySound);
       }
   }

func hitSound() {
       if let soundURL = Bundle.main.url(forResource: "pain", withExtension: "wav") {
           var mySound: SystemSoundID = 0
           AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
           AudioServicesPlaySystemSound(mySound);
       }
   }

func slashSound() {
    if let soundURL = Bundle.main.url(forResource: "hit", withExtension: "wav") {
//        by Mike Koenig
        var mySound: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
        AudioServicesPlaySystemSound(mySound);
    }
}

func menuMusic(father: SKNode) {
    var backgroundMusic: SKAudioNode!
            if let musicURL = Bundle.main.url(forResource: "opening", withExtension: "mp3") {
                backgroundMusic = SKAudioNode(url: musicURL)
                father.addChild(backgroundMusic)
            }
}
