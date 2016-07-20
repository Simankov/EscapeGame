

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
    var pause : Bool = false
    var highScore: Int?
    var isPause : Bool {
        
        get {
            return self.pause
        }
        

        set {
            self.pause = newValue
            playButton?.hidden = !newValue;
        }
        
    }
    weak var delegate: MenuViewController?
    weak var gameVC : GameViewController?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    
    
    
    @IBAction func restart()
    {
        gameVC!.restartGame(pause);
    }
  
    @IBAction func menuPressed()
    {
        delegate!.menuPressed()
    }
   
    
    override func viewWillAppear(animated: Bool) {
        
        scoreLabel.text = String(defaults.integerForKey("score"))
        highScoreLabel.text = String(defaults.integerForKey("highScore"))
    
    }
    
    @IBAction func resume(sender: AnyObject) {
        delegate!.gameResumed()
    }
  
    
   }
