//
//  MenuViewController.swift
//  EscapeGame
//
//  Created by admin on 02.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//
var parent : MenuViewController? = nil

var audioPlayer = AudioPlayer()

import UIKit
protocol restartGameDelegate: class
{
   func   gameRestarted()
    func menuPressed()
}

class MenuViewController: UIViewController, viewEndGameDelegate, restartGameDelegate {
    var isEffectsEnabled : Bool = true
    var gameViewController : GameViewController?
    var settingViewController : SettingsViewController?
    var endGameViewController : EndGameViewController?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        audioPlayer.play(.Menu)
    }
    
    func gameRestarted() {
        
            gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as? GameViewController
        gameViewController?.delegate = self
//        gameViewController?.resetViewController()
        navigationController?.dismissViewControllerAnimated(false, completion: nil)
        self.presentViewController(self.gameViewController!, animated: false, completion: nil)
//        UIApplication.sharedApplication().windows[0].rootViewController = gameViewController!
        
        audioPlayer.play(.Background)
    }

    func viewDidEndGame() {
        
        
        
        endGameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EndGameViewControllerv2") as? EndGameViewController
        endGameViewController?.delegate = self
        endGameViewController?.gameVC = gameViewController
        gameViewController?.presentViewController(endGameViewController!, animated: false, completion: nil)
        audioPlayer.play(.Menu)
        
       
        
      
    }
    
    func menuPressed() {
        navigationController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func gameResumed(){
        gameViewController?.resumeGame();
    }
    
    @IBAction func startNewGame()
    {
        gameViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as? GameViewController
        gameViewController?.delegate = self
        self.presentViewController(gameViewController!, animated: false, completion: nil)
        audioPlayer.play(.Background)
    }
    
    @IBAction func settingButtonEnabled()
    {
        if (navigationController == nil){
            settingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
            let navigationController = UINavigationController();
            self.view.window?.rootViewController = navigationController;
            navigationController.pushViewController(self, animated: false)
            navigationController.pushViewController(settingViewController!, animated: true)
        } else {
            settingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
            assert(navigationController != nil);
            navigationController!.pushViewController(settingViewController!, animated: true)
        }
        
    }
    
    
}
