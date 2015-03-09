//
//  AudioPlayer.swift
//  EscapeGame
//
//  Created by admin on 09/03/15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import Foundation
import AVFoundation

enum TypeOfMusic    {
    case Background
    case Menu
    case Jump
    case Fail
}

class AudioPlayer: NSObject, AVAudioPlayerDelegate
{
    var player : AVAudioPlayer = AVAudioPlayer()
   
 
    func returnNSURL(fileName: String) -> NSURL
    {
        let name = fileName.substringToIndex(fileName.rangeOfString(".")!.startIndex)
        let rightIndex = advance(fileName.rangeOfString(".")!.startIndex, 1)
        var type = fileName.substringFromIndex(rightIndex)
        
        return NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: type)!)!
    }
    
    
    var audioSets: [[TypeOfMusic: String?]] = [
        [.Background: "backgroundMusic.wav", .Jump: "jump.wav", .Fail: "lose.wav", .Menu : nil],
        [.Background: "EscapeMain.mp3", .Jump: nil, .Fail: "EscapeFail.mp3", .Menu : "EscapeMenu.mp3"]
    ]
    var currentSet = 1
    var currentType: TypeOfMusic = .Menu
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        switch(currentType)
        {
        case .Background, .Menu:
            player.stop()
            player.play()
        default:
            player.stop()
        }
    }
    
    func play(type: TypeOfMusic)
    {
        
        let currentAudioSet = audioSets[currentSet]
        
        if let fileName = currentAudioSet[type]
        {
          if let finalFileName = fileName
          {
            currentType = type
            player = AVAudioPlayer(contentsOfURL: returnNSURL(finalFileName),error : nil)
            player.delegate = self
            play()
            }
        }
    }
    
    func changeSet()
    {
        currentSet = 1
    }
    
    func play()
    {
        player.play()
       
    }
}