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
    var videos:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.navigationItem.title = "My Videos"
        
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
        return self.videos.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let currentVideo: Video = self.videos.object(at: indexPath.row) as! Video
        let image:UIImage = currentVideo.thumbnail!
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
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
        let subDirectory = NSString(format: "%@/Videos", documentsDirectory as! CVarArg)
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
        let thumbnail = createThumbnail(URLString: dataPathString)
        
        //create custom video object
        let newVideo = Video(videoName: string, videoPath: dataPathString)
        newVideo.thumbnail = thumbnail
        self.videos.add(newVideo)
        
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
        let subDirectory = NSString(format: "%@/Thumbnails", documentsDirectory as! CVarArg)
        do {
            try FileManager.default.createDirectory(atPath: subDirectory as String, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        if let data = UIImageJPEGRepresentation(uiImage, 0.8) {
            let dataPathString = "\(subDirectory)"
            fileName = dataPathString.appending("/\(lastComponent).jpg")
            try? data.write(to: URL(fileURLWithPath: fileName!))
            
        }
        return uiImage
    }
    
    func getVideos() {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let subDirectory = NSString(format: "%@/Videos", documentsDirectory as! CVarArg)
        let fileManager = FileManager.default
        self.videos.removeAllObjects()
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: subDirectory as String)
            for filename in fileList {
                let dirPath:String = "\(subDirectory)/\(filename)"
                //let url = URL(fileURLWithPath: dirPath, isDirectory: true)
                let newVideo = Video(videoName: filename, videoPath: dirPath)
                let newVideoThumbnail = getThumbnailForVideo(Video: newVideo)
                newVideo.thumbnail = newVideoThumbnail
                self.videos.add(newVideo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getThumbnailForVideo(Video: Video) -> UIImage {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let subDirectory = NSString(format: "%@/Thumbnails", documentsDirectory as! CVarArg)
        let dirPath:String = "\(subDirectory)/\(Video.videoName).jpg"
        let image = UIImage(contentsOfFile: dirPath)
        
        return image!
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
     func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width/3
        return CGSize(width: collectionViewWidth, height:collectionViewWidth) // The size of one cell
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



























