

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
    weak var delegate: MenuViewController?

    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBAction func restart()
    {
        delegate!.gameRestarted()
    }
  
    @IBAction func menuPressed()
    {
        self.view.window?.rootViewController = delegate
    }
   
    
    override func viewWillAppear(animated: Bool) {
        
        scoreLabel.text = String(defaults.integerForKey("score"))
        highScoreLabel.text = String(defaults.integerForKey("highScore"))
    
    }
    
  
    
   }
