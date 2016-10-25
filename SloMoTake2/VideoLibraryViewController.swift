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
import AVFoundation

class VideoLibraryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var navigationBar: UINavigationBar!
    let controller = UIImagePickerController()
    var arrayOfUrls:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.topItem?.title = "My Videos"
        let takeVideoButton = UIBarButtonItem(title: "Take Video", style: .plain, target: self, action: #selector(takeVideoButtonTapped))
        self.navigationBar.topItem?.rightBarButtonItem = takeVideoButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //save video to documents directory
        let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        let videoData = NSData(contentsOf: videoURL as URL)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        //unique video name
        let date = NSDate()
        let timeSince = floor(date.timeIntervalSince1970)
        let string = String(format: "%.0f", timeSince)
        let path = String(format: "/vid%@.mp4", string)
        let dataPath = documentsDirectory.appending(path)
        videoData?.write(toFile: dataPath, atomically: false)
        //nsuserdefaults to save the URLs
        let defaults = UserDefaults()
        if (defaults.object(forKey: "URLs") != nil) {
            let tempArray = defaults.object(forKey: "URLs") as! NSArray
            self.arrayOfUrls = tempArray.mutableCopy() as! NSMutableArray
            self.arrayOfUrls.add(dataPath)
            defaults.set(self.arrayOfUrls.copy(), forKey: "URLs")
        } else {
            self.arrayOfUrls.add(dataPath)
            defaults.set(self.arrayOfUrls.copy(), forKey: "URLs")
        }
        defaults.synchronize()
        //self.collectionView?.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func createThumbnail(URLString:String) -> UIImage {
        do {
            let url = URL(fileURLWithPath: URLString)
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            let imageView = UIImageView(image: uiImage)
            //collectionview image view
        } catch let error as NSError {
            print("\(error), \(error.localizedDescription)")
        }

}


//create a collection view to hold the thumbnails
//create the thumbnails from the videos when saved











































