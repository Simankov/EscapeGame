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
    private var player : AVAudioPlayer!
    var isMusicEnabled : Bool {
        get {let defaults = NSUserDefaults.standardUserDefaults();
            return defaults.boolForKey("isMusicEnabled") ?? true;
        }
        set {
            defaults.setBool(newValue, forKey: "isMusicEnabled");
        }
    }
    
    var isEffectsEnabled : Bool {
        get {let defaults = NSUserDefaults.standardUserDefaults();
            return defaults.boolForKey("isEffectsEnabled") ?? true;
        }
        set {
            defaults.setBool(newValue, forKey: "isEffectsEnabled");
        }
    }
   
 
    private func returnNSURL(fileName: String) -> NSURL
    {
        let name = fileName.substringToIndex(fileName.rangeOfString(".")!.startIndex)
        let rightIndex = fileName.rangeOfString(".")!.startIndex.advancedBy(1)
        var type = fileName.substringFromIndex(rightIndex)
        
        return NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(name, ofType: type)!)
    }
    
    
    private var audioSets: [[TypeOfMusic: String?]] = [
        [.Background: "backgroundMusic.wav", .Jump: "jump.wav", .Fail: "lose.wav", .Menu : nil],
        [.Background: "EscapeMain.mp3", .Jump: nil, .Fail: "EscapeFail.wav", .Menu : "EscapeMenu.mp3"]
    ]
    private var currentSet = 1
    private var currentType: TypeOfMusic = .Menu
    
    private func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
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
        if ((type == TypeOfMusic.Background || type == TypeOfMusic.Menu) && (!isMusicEnabled)){
            return;
        }
        if ((type == TypeOfMusic.Fail || type == TypeOfMusic.Jump) && (!isEffectsEnabled)){
            return;
        }
        let currentAudioSet = audioSets[currentSet]
        
        if let fileName = currentAudioSet[type]
        {
          if let finalFileName = fileName
          {
            currentType = type
            if let player = player {
                player.stop();
            }
            player = try? AVAudioPlayer(contentsOfURL: returnNSURL(finalFileName))
            player.delegate = self
            player.play()
            }
        }
    }
    
    private func changeSet()
    {
        currentSet = 1
    }
    
    func play()
    {
        play(.Background)
    }
    
    func isPlaying() -> Bool
    {
        if let _ = player {
            return player.playing;
        } else {
            return false
        }
    }
    
    func stop()
    {
        player?.stop();
    }
    
    func musicSwitched(){
        if (isPlaying()){
            isMusicEnabled = false;
            stop();
        } else {
            isMusicEnabled = true;
            play();
        }
    }
    
    func effectsSwitched(){
        isEffectsEnabled = !isEffectsEnabled;
    }
}