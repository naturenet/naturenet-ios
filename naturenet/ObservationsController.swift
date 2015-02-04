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
    
    @IBOutlet weak var observationCV: UICollectionView!
    var celldata = [ObservationCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if !Session.isSignedIn() {
            return
        }
        if let account = Session.getAccount() {
            var notes = account.getNotes()
            for note in notes {
                var mNote = note as Note
                var medias = mNote.getMedias()
                println("you have \(medias.count) medias")
                for media in medias {
                    var mMedia = media as Media
                    // println("in obs: \(mMedia.toString())")
                    var obscell = ObservationCell(url: mMedia.getMediaURL(), id: mMedia.uid.integerValue,
                        state: mMedia.state.integerValue, modifiedAt: mMedia.created_at.integerValue)
                    if let tPath = mMedia.thumb_path {
                        obscell.localThumbPath = tPath
                    }
                    celldata.append(obscell)
                }
            }
            celldata.sort({$0.modifiedAt > $1.modifiedAt})
        }

        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.celldata.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("obscell", forIndexPath: indexPath) as HomeCell
        var cellImage = self.celldata[indexPath.row] as ObservationCell
        var newurl = cellImage.getThumbnailURL()
        let url = NSURL(string: newurl)
        cell.mLabel.text = cellImage.getStatus()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        cell.addSubview(activityIndicator)
        activityIndicator.frame = cell.bounds
        activityIndicator.startAnimating()
        println("haha, I am here againn \(indexPath.row)th")
        if let lPath = cellImage.localThumbPath {
            // println("image local path is :  \(lPath)")
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(lPath) {
                // println("FILE AVAILABLE");
                cell.mImageView.image = UIImage(named: lPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            else {
                // println("FILE NOT AVAILABLE");
                self.loadImageFromWeb(url!, cell: cell, activityIndicator: activityIndicator, index: indexPath.row)
            }
        } else {
            self.loadImageFromWeb(url!, cell: cell, activityIndicator: activityIndicator, index: indexPath.row)
        }
        
        return cell
    }
    
    // programmatically set the cell's size
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width;
            let screenHeight = screenSize.height;
            
            return CGSize(width: screenWidth/2-5, height: screenWidth/2-5)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "observationDetailSegue" {
            let destinationVC = segue.destinationViewController as UINavigationController
            let indexPath = self.observationCV.indexPathForCell(sender as HomeCell)
            let selectedCell = celldata[indexPath!.row]
            let detailVC = destinationVC.topViewController as ObservationDetailController
            detailVC.receivedCellData = selectedCell
        }

    }
    
    // IBAction for exit
    @IBAction func cancelToObservationsViewController(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveObservationDetail(segue:UIStoryboardSegue) {
        
    }
    
    func loadImageFromWeb(url: NSURL, cell: HomeCell, activityIndicator: UIActivityIndicatorView, index: Int ) {
        let urlRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
                
            } else {
                let image = UIImage(data: data)
                cell.mImageView.image = image
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                var cellImage = self.celldata[index] as ObservationCell
                self.saveImage(cellImage, data: data)
            }
        })
        
    }
    
    func saveImage(cellImage: ObservationCell, data: NSData) {
        var fileName = String(cellImage.modifiedAt) + ".jpg"
        var tPath: String = cellImage.saveToDocumentDirectory(data, name: fileName)!
        if let tMedia = NNModel.doPullByUIDFromCoreData("Media", uid: cellImage.uid) as Media? {
            tMedia.setLocalThumbPath(tPath)
        }
    }
}

class ObservationCell {
    var imageURL: String
    // var status: String
    var modifiedAt: Int
    var state: Int
    var uid: Int
    var localThumbPath: String?
    
    init(url: String, id: Int, state: Int, modifiedAt: Int) {
        self.imageURL = url
        self.uid = id
        self.state = state
        self.modifiedAt = modifiedAt
    }
    
    func getStatus() -> String {
        var status: String = "ready to send"
        if (self.state == NNModel.STATE.DOWNLOADED || self.state == NNModel.STATE.NEW) {
            status = "ready to send"
        }
        
        if (self.state == NNModel.STATE.SYNCED) {
            status = "sent"
        }
        
        return status
    }
    
    func getThumbnailURL() -> String {
        var urlArr = split(imageURL) {$0 == "/"}
        var newURL = "http:"
        for str in urlArr {
            if str == "http:" {
                newURL += "/"
            } else {
                newURL += "/" + str
            }
            if str == "upload" {
                newURL += "/w_600,h_600,c_fit"
            }
        }
        // println("new url is " + newURL)
        return newURL
    }
    
    // save to local document directory
    func saveToDocumentDirectory(data: NSData, name: String) -> String?  {
        var documentDirectory: String?
        var savedPath: String?
        
        // LibraryDirectory may need to be changed to DocumentationDirectory when it is deployed on a phone
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            documentDirectory = paths[0] as? String
            savedPath = documentDirectory! + "/\(name)"
            // println("saved path is \(savedPath)")
            NSFileManager.defaultManager().createFileAtPath(savedPath!, contents: data, attributes: nil)
        }
        localThumbPath = savedPath
        return savedPath
        
    }

}


