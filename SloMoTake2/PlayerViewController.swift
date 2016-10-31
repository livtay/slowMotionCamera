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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigationController?.title = "Normal Speed"
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        let playButton = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playVideo))
        let pauseButton = UIBarButtonItem(title: "Pause", style: .plain, target: self, action: #selector(pauseVideo))
        toolbarItems = [playButton, pauseButton]
    }
    
    func playVideo() {
        self.player?.rate = 1
    }

    func pauseVideo() {
        self.player?.pause()
    }
    
}







































