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

    @IBOutlet weak var containmentView: UIView!
    var isEffectsEnabled = true
    @IBOutlet weak var gameView: UIView!
    var onPause = false;
    
    @IBOutlet weak var banner: GADBannerView!
    var score : Int?
    weak var delegate: MenuViewController?
    var highScore : Int?
    weak var sceneVar : SKScene?
    override func viewDidLoad() {
        super.viewDidLoad()
         (self.childViewControllers[0] as! EndGameViewController).gameVC = self
        presentScene()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func presentScene(){
        let scene = GameScene(fileNamed: "GameScene")!
        sceneVar = scene;
        // Configure the view.
        let skView = gameView as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        banner.layer.zPosition = 100;
        banner.adUnitID = "ca-app-pub-5388282998795388/1787706150"
        banner.rootViewController = self
        banner.adSize = kGADAdSizeSmartBannerPortrait
        let request = GADRequest();
//        request.testDevices = [kGADSimulatorID];
        banner.loadRequest(request);
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        scene.viewDelegate = self
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)

    }
    @IBAction func pauseGame(sender: AnyObject) {
        sceneVar?.paused = true;
        (self.childViewControllers[0] as! EndGameViewController).isPause = true;
        (self.childViewControllers[0] as! EndGameViewController).delegate = self.delegate;
        (self.childViewControllers[0] as! EndGameViewController).gameVC = self
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
            self.containmentView.userInteractionEnabled = true;
            self.containmentView.hidden = false
            let width : CGFloat = 350;
            let height : CGFloat = 260;
            self.containmentView.frame = CGRectMake(self.view.frame.width/2 - width/2, self.view.frame.height/2 - height/2 - 50, width,height);
            }, completion: nil)
            self.containmentView.frame = CGRectInset(self.containmentView.frame, -2, -2);
            self.containmentView.layer.borderColor = UIColor.blackColor().CGColor;
            self.containmentView.layer.borderWidth = 2;
            self.onPause = true;
    }
    
    func resumeGame(){
        sceneVar?.paused = false;
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
            self.containmentView.userInteractionEnabled = false;
            self.containmentView.hidden = true
        }, completion: nil)

    }
    
    func viewDidEndGame()
    {
        delegate?.viewDidEndGame()
    }
    
//    func resetViewController(){
//        containmentView.hidden = true;
//        if let scene = sceneVar {
//            scene.removeFromParent();
//            scene.removeAllChildren();
//            scene.removeAllActions()
//            scene.physicsWorld.removeAllJoints()
//        }
//        presentScene()
//    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func restartGame(pause: Bool){
        if (pause){
            containmentView.hidden = true
            presentScene()
        } else {
            
            dismissViewControllerAnimated(false, completion: nil)
            containmentView.hidden  = true
            presentScene()
        }
    }
    
}
