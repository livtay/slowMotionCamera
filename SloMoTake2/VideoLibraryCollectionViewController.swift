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
        
        getImages()
        getVideos()
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.collectionView?.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfImages.count
        
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
        
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        let subDirectory =   NSString(format: "%@/Videos", documentsDirectory as! CVarArg)  //  documentsDirectory .appendingPathComponent("Videos")
        if !fileManager.fileExists(atPath: subDirectory as String, isDirectory:&isDir) {
            //create a sub-directory named "videos" to put these in
            do {
                try FileManager.default.createDirectory(atPath: subDirectory as String, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }

        }
        
        //unique video name
        let date = NSDate()
        let timeSince = floor(date.timeIntervalSince1970)
        let string = String(format: "%.0f", timeSince)
        let path = String(format: "/vid%@.mp4", string)
        let dataPath = subDirectory.appendingPathComponent(path)
        let dataPathString = "\(dataPath)"
        videoData?.write(toFile: dataPathString, atomically: false)
        //create thumbnail
        _ = createThumbnail(URLString: dataPathString)
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
        //create a sub-directory named "thumbnails" to put these in
       // let subDirectory = documentsDirectory.appendingPathComponent("Thumbnails")!
        let subDirectory =   NSString(format: "%@/Thumbnails", documentsDirectory as! CVarArg)
        do {
            try FileManager.default.createDirectory(atPath: subDirectory as String, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        if let data = UIImageJPEGRepresentation(uiImage, 0.8) {
//            fileName = documentsDirectory.appending("/\(lastComponent).jpg")
            let dataPathString = "\(subDirectory)"
            fileName = dataPathString.appending("/\(lastComponent).jpg")
            try? data.write(to: URL(fileURLWithPath: fileName!))
            print("THIS IS THE FILE NAME:" + fileName!)
        }
        
        self.arrayOfImages.add(uiImage)
        return uiImage
    }
    
    func getImages() {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let subDirectory = NSString(format: "%@/Thumbnails", documentsDirectory as! CVarArg)
        let fileManager = FileManager.default
        self.arrayOfImages.removeAllObjects()
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: subDirectory as String)
            for filename in fileList {
                let dirPath:String = "\(subDirectory)/\(filename)"
                let image = UIImage(contentsOfFile: dirPath)
                print(dirPath)
                self.arrayOfImages.add(image)
            }

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getVideos() {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let subDirectory = NSString(format: "%@/Videos", documentsDirectory as! CVarArg)
        let fileManager = FileManager.default
        self.arrayOfUrls.removeAllObjects()
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: subDirectory as String)
            for filename in fileList {
                let dirPath:String = "\(subDirectory)/\(filename)"
                let url = URL(fileURLWithPath: dirPath, isDirectory: true)
                print(url)
                self.arrayOfUrls.add(url)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
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



























