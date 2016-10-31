//
//  PlayerViewController.swift
//  SloMoTake2
//
//  Created by Olivia Taylor on 10/31/16.
//  Copyright © 2016 Olivia Taylor. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    var videoPath:String?
    var videoUrl:NSURL?
    var player:AVPlayer?
    var sloMoSwitch:UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.title = "Normal Speed"
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let playButton = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playVideo))
        let pauseButton = UIBarButtonItem(title: "Pause", style: .plain, target: self, action: #selector(pauseVideo))
        self.sloMoSwitch = UISwitch()
        self.sloMoSwitch?.isOn = false
        self.sloMoSwitch?.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        let toolSwitch:UIBarButtonItem = UIBarButtonItem(customView: self.sloMoSwitch!)
        self.toolbarItems = [spacer, playButton, spacer, pauseButton, spacer, toolSwitch, spacer]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.videoUrl = NSURL(fileURLWithPath: self.videoPath!)
        self.player = AVPlayer(url: self.videoUrl as! URL)
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    func playVideo() {
        
        if (self.sloMoSwitch?.isOn)! {
            self.player?.rate = 0.1
        } else {
            self.player?.rate = 1
        }
    }

    func playerDidFinishPlaying(){
        self.player?.seek(to: kCMTimeZero)
    }
    
    func pauseVideo() {
        self.player?.pause()
    }
    
    func switchChanged() {
        if (self.sloMoSwitch?.isOn)! {
            self.title = "Slow Motion"
        } else {
            self.title = "Normal Speed"
        }
    }
    
}







































