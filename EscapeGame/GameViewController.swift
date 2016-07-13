//
//  GameViewController.swift
//  EscapeGame
//
//  Created by admin on 31.01.15.
//  Copyright (c) 2015 Sergey Simankov. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds



class GameViewController: UIViewController, viewEndGameDelegate {

var isEffectsEnabled = true
    @IBOutlet weak var gameView: UIView!
    
    @IBOutlet weak var banner: GADBannerView!
    var score : Int?
    weak var delegate: MenuViewController?
    var highScore : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene")
        {
            // Configure the view.
            let skView = gameView as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            banner.layer.zPosition = 100;
            banner.adUnitID = "ca-app-pub-5388282998795388/1787706150"
            banner.rootViewController = self
            let request = GADRequest();
            request.testDevices = [kGADSimulatorID];
            banner.loadRequest(request);
            print(self.view.frame.size);
            print(gameView.frame.size)
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.viewDelegate = self
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            audioPlayer.play(.Background)
            skView.presentScene(scene)
        }
    
    }

    override func shouldAutorotate() -> Bool {
        return true
        
    
    }
    
    func viewDidEndGame()
    {
//        self.score = score
//        self.highScore = highScore
//      self.presentViewController( self.storyboard!.instantiateViewControllerWithIdentifier("EndGameViewController") as EndGameViewController, animated: true, completion: nil)
//      
        
        delegate?.viewDidEndGame()
        
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
