//
//  MenuViewController.swift
//  EscapeGame
//
//  Created by admin on 02.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, effectsSwitchDelegate {
    var isEffectsEnabled : Bool = true
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SettingSegue"
        {
            (segue.destinationViewController as SettingsViewController).delegate = self
        }
        
        if segue.identifier == "GameSegue"
        {
            (segue.destinationViewController as GameViewController).isEffectsEnabled = isEffectsEnabled
        }
    }
    func effectsDidSwitched() {
        isEffectsEnabled = !isEffectsEnabled
    }
    
    
}
