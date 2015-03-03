//
//  GameViewController.swift
//  EscapeGame
//
//  Created by admin on 31.01.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit
import SpriteKit




class GameViewController: UIViewController, viewEndGameDelegate {

var isEffectsEnabled = true
    
    var score : Int?
    var highScore : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView = self.view as SKView
           skView.showsFPS = true
            skView.showsNodeCount = true
            
           
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.viewDelegate = self
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.isEffectsEnabled = isEffectsEnabled
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
        
    
    }
    
    
    func viewDidEndGame(sender: AnyObject ,score: Int, highScore : Int)
    {
//        self.score = score
//        self.highScore = highScore
//      self.presentViewController( self.storyboard!.instantiateViewControllerWithIdentifier("EndGameViewController") as EndGameViewController, animated: true, completion: nil)
//      
        var parentController = self.presentingViewController ;
      
        dismissViewControllerAnimated(true){
            if parentController?.title != "Menu"{
                return
            }
            parentController!.performSegueWithIdentifier("EndGame",sender:self)
            };
       
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
