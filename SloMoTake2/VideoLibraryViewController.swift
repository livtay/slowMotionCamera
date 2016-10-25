//
//  VideoLibraryViewController.swift
//  SloMoTake2
//
//  Created by Olivia Taylor on 10/25/16.
//  Copyright © 2016 Olivia Taylor. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary

class VideoLibraryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    let controller = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.topItem?.title = "My Videos"
        let takeVideoButton = UIBarButtonItem(title: "Take Video", style: .plain, target: self, action: #selector(takeVideoButtonTapped))
        self.navigationBar.topItem?.rightBarButtonItem = takeVideoButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takeVideoButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            controller.videoMaximumDuration = 10.0
            
            present(controller, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "No camera", message: "Sorry, there is no available camera", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }

}










































