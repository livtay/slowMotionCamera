//
//  VideoLibraryCollectionViewController.swift
//  SloMoTake2
//
//  Created by Olivia Taylor on 10/25/16.
//  Copyright © 2016 Olivia Taylor. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import QuartzCore

private let reuseIdentifier = "Cell"

class VideoLibraryCollectionViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    let controller = UIImagePickerController()
    var arrayOfUrls:NSMutableArray = []
    var arrayOfImages:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.navigationItem.title = "My Videos"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if self.arrayOfUrls.count != 0 {
////            self.createImageArray()
//            self.collectionView?.reloadData()
//        }
        self.collectionView?.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfUrls.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageView = UIImageView(image: self.arrayOfImages.object(at: indexPath.row) as? UIImage)
        cell.backgroundView = imageView
        return cell

    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //go to next VC for video player
        
        return true
    }
    
    @IBAction func takeNewVideo(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.delegate = self
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.allowsEditing = true
            controller.videoQuality = .typeHigh
            controller.videoMaximumDuration = 60.0
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
        //create thumbnail
        _ = createThumbnail(URLString: videoURL.path!)
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
        self.collectionView?.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func createThumbnail(URLString:String) -> UIImage {
        
        let url = URL(fileURLWithPath: URLString)
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        var actualTime:CMTime = CMTimeMake(0, 0)
        var displayImage: CGImage?
        
        do {
            displayImage = try imgGenerator.copyCGImage(at: CMTimeMakeWithSeconds(0, 1), actualTime: &actualTime)
            
        } catch let error as NSError {
            print("\(error), \(error.localizedDescription)")
        }
        
        //save image to documents directory with same name as video
        let uiImage = UIImage(cgImage: displayImage!)
        let fileUrl = URL(fileURLWithPath: URLString)
        let lastComponent = fileUrl.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        var fileName:String?
        
        if let data = UIImageJPEGRepresentation(uiImage, 0.8) {
            fileName = documentsDirectory.appending("/\(lastComponent).jpg")
            try? data.write(to: URL(fileURLWithPath: fileName!))
            print("THIS IS THE FILE NAME:" + fileName!)
        }
        
        self.arrayOfImages.add(uiImage)
        
//        let defaults = UserDefaults()
//        if (defaults.object(forKey: "Images") != nil) {
//            let tempArray = defaults.object(forKey: "Images") as! NSArray
//            self.arrayOfImages = tempArray.mutableCopy() as! NSMutableArray
//            self.arrayOfImages.add(fileName)
//            defaults.set(self.arrayOfImages.copy(), forKey: "Images")
//        } else {
//            self.arrayOfImages.add(fileName)
//            defaults.set(self.arrayOfImages.copy(), forKey: "Images")
//        }
//        defaults.synchronize()
        
        return uiImage
    }
    
    func getImages() {
        
    }
    
//    func createImageArray() -> Void {
//        
//        let defaults = UserDefaults()
//        let tempArray = defaults.object(forKey: "URLs") as! NSArray
//        self.arrayOfUrls = tempArray.mutableCopy() as! NSMutableArray
//        self.arrayOfImages.removeAllObjects()
//        for i in self.arrayOfUrls {
//            let tempImage:UIImage = self.createThumbnail(URLString: i as! String)
//            self.arrayOfImages.add(tempImage)
//        }
//    }
    
 
    
    // MARK: UICollectionViewDelegateFlowLayout
    
     func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height:90) // The size of one cell
    }
    
    //Use for interspacing
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

}



























