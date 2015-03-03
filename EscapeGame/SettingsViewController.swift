//
//  SettingsViewController.swift
//  EscapeGame
//
//  Created by admin on 02.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit

protocol effectsSwitchDelegate : class{
    func effectsDidSwitched()
    
}

class SettingsViewController: UIViewController {
    var delegate: effectsSwitchDelegate?
    @IBOutlet weak var musicSwitchButton: UISwitch!
    @IBOutlet weak var effectsSwitchButton: UISwitch!
    
    @IBAction func musicSwitched()
    {
        
         
        
      if audioPlayer1.playing
      {
        audioPlayer1.pause()
      }
        else
      {
        audioPlayer1.play()
       }
       
    }
    
    @IBAction func effectsSwitched()
    {
        delegate?.effectsDidSwitched()
    }
}
