//
//  ObservationsController.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/28/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ObservationsController: UIViewController, UICollectionViewDataSource,
                    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var items = ["Observations", "Activities", "Design Ideas", "ACES Tour", "Profile", "About"]
    var images = ["camera", "activity", "bulb", "map", "profile", "about"]
    var notes = NNModel.doPullAllByEntityFromCoreData(NSStringFromClass(Note))
    var celldata = [ObservationCell]()
    var urls = [String] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for note in notes {
            var mNote = note as Note
            var medias = mNote.getMedias()
            for media in medias {
                var mMedia = media as Media
                println("in obs: \(mMedia.toString())")
                var obscell = ObservationCell(url: mMedia.getMediaURL(), status: mNote.status)
                // mNote.modified_at
                urls.append(mMedia.getMediaURL())
                celldata.append(obscell)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.celldata.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("obscell", forIndexPath: indexPath) as HomeCell
//        cell.mLabel.text = self.items[indexPath.row]
//        cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.whiteColor() : UIColor.lightGrayColor()
//        cell.mImageView.image = UIImage(named: self.images[indexPath.row])
        let url = NSURL(string: self.celldata[indexPath.row].imageURL)
        cell.mLabel.text = self.celldata[indexPath.row].status
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        cell.addSubview(activityIndicator)
        activityIndicator.frame = cell.bounds
        activityIndicator.startAnimating()
//        let url = NSURL(string: self.urls[indexPath.row])

        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in

            if error != nil {
                
            } else {
                let image = UIImage(data: data)
                cell.mImageView.image = image
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()

//                var documentDirectory: String?
//                var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory,
//                            NSSearchPathDomainMask.UserDomainMask, true)
//                if paths.count > 0 {
//                
//                    documentDirectory = paths[0] as? String
//                    var savedPath = documentDirectory! + "/"
//                    NSFileManager.defaultManager().createFileAtPath(savedPath, contents: data, attributes: nil)
//                    cell.mImageView.image = UIImage(named: savedPath)
//
//                }
            }
        })
        return cell
    }
    
    // programmatically set the cell's size
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//            var photoPath =  self.images[indexPath.row]
//            var mImage = UIImage(named: self.images[indexPath.row])
          
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width;
            let screenHeight = screenSize.height;
            
            return CGSize(width: screenWidth/2-5, height: screenWidth/2-5)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // implement UICollectionViewDelegate
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        switch indexPath.row {
//        case 0 :
//            self.performSegueWithIdentifier("observationSeg", sender: self)
//        case 1 :
//            self.performSegueWithIdentifier("activitiesSeg", sender: self)
//        default:
//            return
//        }
//    }

}

class ObservationCell {
    var imageURL: String
    var status: String
    
    init(url: String, status: String) {
        self.imageURL = url
        self.status = status
    }
}
