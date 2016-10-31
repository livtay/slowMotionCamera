//
//  Video.swift
//  SloMoTake2
//
//  Created by Olivia Taylor on 10/27/16.
//  Copyright © 2016 Olivia Taylor. All rights reserved.
//

import Foundation
import UIKit

class Video {
    
    var videoName:String
    var videoPath:String
    var thumbnail:UIImage?
    
    init(videoName: String, videoPath:String) {
        self.videoName = videoName
        self.videoPath = videoPath
    }
    
}

//then when you segue to new VC from selected image in collection view, pass video object to new VC
//then display video/play/stop on that VC
//do slow-mo feature






