

//
//  endGameViewController.swift
//  EscapeGame
//
//  Created by admin on 01.03.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {
    var score: Int?
    var highScore: Int?
  
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBAction func restart()
    {
        self.presentViewController( self.storyboard!.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController, animated: true, completion: nil)
    }
 
   
    
    override func viewWillAppear(animated: Bool) {
        
        scoreLabel.text = String(defaults.integerForKey("score"))
        highScoreLabel.text = String(defaults.integerForKey("highScore"))
    
    }
    
  
    
   }
