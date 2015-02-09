//
//  ObservationsController.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/28/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ObservationsController: UIViewController, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var observationCV: UICollectionView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    
    var celldata = [ObservationCell]()
    var cameraImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
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
        var cellImage = self.celldata[indexPath.row] as ObservationCell
        var newurl = cellImage.getThumbnailURL()
        let url = NSURL(string: newurl)
        cell.mLabel.text = cellImage.getStatus()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        cell.addSubview(activityIndicator)
        activityIndicator.frame = cell.bounds
        activityIndicator.startAnimating()
        // println("haha, I am here again \(indexPath.row)th")
        if let lPath = cellImage.localThumbPath {
            // println("image local path is :  \(lPath)")
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(lPath) {
                cell.mImageView.image = UIImage(named: lPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            else {
                self.loadImageFromWeb(url!, cell: cell, activityIndicator: activityIndicator, index: indexPath.row)
            }
        } else {
            self.loadImageFromWeb(url!, cell: cell, activityIndicator: activityIndicator, index: indexPath.row)
        }
        
        return cell
    }
    
    // programmatically set the cell's size
    // be carefull here
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("observationDetailSegue", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "observationDetailSegue" {
            let destinationVC = segue.destinationViewController as UINavigationController
            let detailVC = destinationVC.topViewController as ObservationDetailController

            if self.cameraImage != nil {
                detailVC.imageFromCamera = self.cameraImage!
            } else {
                // let indexPath = self.observationCV.indexPathForCell(sender as HomeCell)
                var indexPath = sender as NSIndexPath
                let selectedCell = celldata[indexPath.row]
                detailVC.mediaIdFromObservations = selectedCell.uid
            }
        }
    }
    
    // IBAction for exit in observation detail page
    @IBAction func cancelToObservationsViewController(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveObservationDetail(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        var picker:UIImagePickerController = UIImagePickerController()
        // remember to assign delegate to self
        picker.delegate = self
        var popover:UIPopoverController?

        var alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera(picker)
        }
        
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openGallary(picker)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            self.imagePickerControllerDidCancel(picker)
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            popover = UIPopoverController(contentViewController: alert)
            // popover!.presentPopoverFromRect(cameraBtn.vie, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera(picker: UIImagePickerController!) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            openGallary(picker)
        }
    }

    func openGallary(picker: UIImagePickerController!) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        println("picker cancel.")
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("observationDetailSegue", sender: self)
        
//        var obscell = ObservationCell(url: nil, id: 0, state: NNModel.STATE.NEW, modifiedAt: 0)
//        celldata.append(obscell)
    }
    
    // implement later if it is needed
    func getLocaitonFromPhoto(info: [NSObject : AnyObject]) {

    }
    
    // load data for this collectionview
    func loadData() {
        if !Session.isSignedIn() {
            return
        }
        if let account = Session.getAccount() {
            var notes = account.getNotes()
            for note in notes {
                var mNote = note as Note
                var medias = mNote.getMedias()
                // println("you have \(medias.count) medias")
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
    
    //----------------------------------------------------------------------------------------------
    // some utility functions
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
        var tPath: String = ObservationCell.saveToDocumentDirectory(data, name: fileName)!
        cellImage.localThumbPath = tPath
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
    class func saveToDocumentDirectory(data: NSData, name: String) -> String?  {
        var documentDirectory: String?
        var savedPath: String?
        
        // LibraryDirectory may need to be changed to DocumentationDirectory when it is deployed on a phone
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            documentDirectory = paths[0] as? String
            savedPath = documentDirectory! + "/\(name)"
            NSFileManager.defaultManager().createFileAtPath(savedPath!, contents: data, attributes: nil)
        }
//        localThumbPath = savedPath
        return savedPath
    }

}


