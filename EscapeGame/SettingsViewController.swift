//
//  SettingsViewController.swift
//  EscapeGame
//
//  Created by admin on 02.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController {
  
    @IBOutlet weak var musicSwitchButton: UISwitch!
    @IBOutlet weak var effectsSwitchButton: UISwitch!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
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
        
    }
}
