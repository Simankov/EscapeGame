//
//  MenuViewController.swift
//  EscapeGame
//
//  Created by admin on 02.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//
var parent : MenuViewController? = nil

import UIKit
protocol restartGameDelegate: class
{
   func   gameRestarted()
}

class MenuViewController: UIViewController, viewEndGameDelegate, restartGameDelegate {
    var isEffectsEnabled : Bool = true
    var gameViewController : GameViewController?
    var settingViewController : SettingsViewController?
    var endGameViewController : EndGameViewController?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    func gameRestarted() {
        
        gameViewController = nil
        gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as? GameViewController
        gameViewController?.delegate = self
       
         endGameViewController?.view.window?.rootViewController = gameViewController
    }

    func viewDidEndGame() {
        
        
        
            endGameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EndGameViewController") as? EndGameViewController
            endGameViewController?.delegate = self
        gameViewController?.view.window?.rootViewController = endGameViewController
        
        
       
        
      
    }
    
    @IBAction func startNewGame()
    {
        gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as? GameViewController
        parent = self
        gameViewController!.delegate = self
        
        self.view.window?.rootViewController = gameViewController
    }
    
    @IBAction func settingButtonEnabled()
    {
        settingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
        
        
        navigationController!.pushViewController(settingViewController!, animated: true)
    }
    

    
  deinit
  {
    println("noope")
    }
    
    
}