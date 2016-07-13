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
        super.viewDidLoad();
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        musicSwitchButton.on = audioPlayer.isMusicEnabled;
        effectsSwitchButton.on = audioPlayer.isEffectsEnabled;
    }
    
    @IBAction func musicSwitched()
    {
        audioPlayer.musicSwitched();
    }
    
    @IBAction func effectsSwitched()
    {
        audioPlayer.effectsSwitched();
    }
}
