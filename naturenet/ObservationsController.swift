//
//  ObservationsController.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/28/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class ObservationsController: UIViewController, UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate, APIControllerProtocol  {
    // UI Outlets
    @IBOutlet weak var observationCV: UICollectionView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    
    // data
    var apiService = APIService()
    var celldata = [ObservationCell]()
    var cameraImage: UIImage?
    
    // data received after clicking "send" from ObservationDetailController 
    // values set in saveObservationDetail()
    var receivedNoteFromObservation: Note?
    var receivedMediaFromObservation: Media?
    var receivedFeedbackFromObservation: Feedback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiService.delegate = self
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
//        observationCV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // after post, when note uid is ready, doPushNew for media, then for feedback
    // start the tasks from main thread(cloudinary requires main thread!!),
    // the async tasks in the push methods will do the task(e.g. handling request, image uploading)
    // in the background thread.
    func didReceiveResults(from: String, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var uid = response["data"]!["id"] as Int
            if from == "POST_" + NSStringFromClass(Note) {
                println("now after post_note")
                var modifiedAt = response["data"]!["modified_at"] as Int
                self.receivedNoteFromObservation!.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                self.receivedNoteFromObservation!.doPushFeedbacks(self.apiService)
            }
            if from == "POST_" + NSStringFromClass(Feedback) {
                println("now after post_feedback")
                var modifiedAt = response["data"]!["modified_at"] as Int
                if self.receivedFeedbackFromObservation != nil {
                    self.receivedFeedbackFromObservation!.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    if self.receivedMediaFromObservation != nil {
                        self.receivedNoteFromObservation!.doPushMedias(self.apiService)
                    }
                    for obs in self.celldata {
                        var media = self.receivedNoteFromObservation?.getSingleMedia()?
                        if obs.objectID == media?.objectID {
                            obs.state = NNModel.STATE.SYNCED
                            if media?.state != NNModel.STATE.SYNCED {
                                media?.commit()
                            }
                        }
                    }
                    self.observationCV.reloadData()
                }
                
            }
            if from == "POST_" + NSStringFromClass(Media) {
                println("now after post_media")
                self.receivedMediaFromObservation!.updateAfterPost(uid, modifiedAtFromServer: nil)

            }
        })
        
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // println("from: \(from) response: \(response)")
        })
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // collectionview setup
    //----------------------------------------------------------------------------------------------------------------------
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.celldata.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("obscell", forIndexPath: indexPath) as HomeCell
        var cellImage = self.celldata[indexPath.row] as ObservationCell
        self.showImageIntoCell(cellImage, cell: cell, indexPath: indexPath)
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
    
    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "observationDetailSegue" {
            let destinationVC = segue.destinationViewController as UINavigationController
            let detailVC = destinationVC.topViewController as ObservationDetailController
            // if passed from a cell
            if let indexPath = sender as? NSIndexPath {
                let selectedCell = celldata[indexPath.row]
                detailVC.mediaIdFromObservations = selectedCell.objectID
                self.cameraImage = nil
            } else if self.cameraImage != nil { // else from a camera
                detailVC.imageFromCamera = self.cameraImage!
            }

        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for receiced data passed back
    //----------------------------------------------------------------------------------------------------------------------
    
    // IBAction for exit in observation detail page
    @IBAction func cancelToObservationsViewController(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveObservationDetail(segue:UIStoryboardSegue) {
        dismissViewControllerAnimated(true, completion: nil)
        let originVC = segue.sourceViewController as ObservationDetailController
        if self.cameraImage != nil {
            self.receivedNoteFromObservation = originVC.saveNote()
            self.receivedMediaFromObservation = originVC.noteMedia
            self.receivedFeedbackFromObservation = originVC.feedback
            var media = originVC.noteMedia
            var newCell = ObservationCell(objectID: media!.objectID, state: media!.state.integerValue,
                modifiedAt: media!.modified_at.integerValue)
            newCell.localFullPath = media!.full_path
            celldata.insert(newCell, atIndex: 0)
            self.observationCV.reloadData()
//            let indexPath = NSIndexPath(forRow: celldata.count-1, inSection: 0)
//            observationCV.insertItemsAtIndexPaths([indexPath])
            self.receivedNoteFromObservation!.push(apiService)
        } else {
            self.receivedNoteFromObservation = originVC.updateNote()
            self.receivedFeedbackFromObservation = originVC.feedback
            self.receivedNoteFromObservation?.push(apiService)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------

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
        picker.dismissViewControllerAnimated(true, completion: nil)
        println("picker cancel.")
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("observationDetailSegue", sender: self)
    }
    
    // implement later if it is needed
    func getLocaitonFromPhoto(info: [NSObject : AnyObject]) {

    }

    
    
    //----------------------------------------------------------------------------------------------
    // some utility functions
    //----------------------------------------------------------------------------------------------
    
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
                    var obscell = ObservationCell(objectID: mMedia.objectID,
                        state: mMedia.state.integerValue, modifiedAt: mMedia.created_at.integerValue)
                    if let tPath = mMedia.thumb_path {
                        obscell.localThumbPath = tPath
                    }
                    if let fPath = mMedia.full_path {
                        obscell.localFullPath = fPath
                    }
                    if let mediaURL = mMedia.url {
                        obscell.imageURL = mediaURL
                    }
                    // only the media has url && full_path && thumb_path can be
                    if mMedia.url != nil {
                        celldata.append(obscell)
                    }
                }
            }
            celldata.sort({$0.modifiedAt > $1.modifiedAt})
//            println("total notes: \(notes.count) total celldata: \(celldata.count)")
        }
    }
    
    // if local thumbnail exists, show local thumbnail to each cell
    // else if local full path exists, show local full to each cell
    // if both of them failed, try web nail and show web nail to each cell
    func showImageIntoCell(cellImage: ObservationCell, cell: HomeCell, indexPath: NSIndexPath) {
        cell.mLabel.text = cellImage.getStatus()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        cell.addSubview(activityIndicator)
        activityIndicator.frame = cell.bounds
        activityIndicator.startAnimating()
        let fileManager = NSFileManager.defaultManager()
        // println("haha, I am here again \(indexPath.row)th")
        if let lPath = cellImage.localThumbPath {
            // println("image local path is :  \(lPath)")
            if fileManager.fileExistsAtPath(lPath) {
                cell.mImageView.image = UIImage(named: lPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                return
            }
        } else if let fPath = cellImage.localFullPath {
            println("image local full path is :  \(fPath)")
            if fileManager.fileExistsAtPath(fPath) {
                // println("local full path exists")
                cell.mImageView.image = UIImage(named: fPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                return
            }
        }
        
        if let imageurl = cellImage.imageURL {
            // println("no local path exists")
            var url = cellImage.getThumbnailURL()
            let nsurl = NSURL(string: url)
            self.loadImageFromWeb(nsurl!, cell: cell, activityIndicator: activityIndicator, index: indexPath.row)
        }
    }
    
    // load iamge to cell and save the thumbnail file path
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
        var predicate = NSPredicate(format: "SELF = %@", cellImage.objectID)
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        if let nMedia = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Media), withPredicate: predicate, managedObjectContext: nsManagedContext) as Media? {
            nMedia.setLocalThumbPath(tPath)
        }
        
//        if let tMedia = NNModel.doPullByObjcIDFromCoreData("Media", objectID: cellImage.uid) as Media? {
//            tMedia.setLocalThumbPath(tPath)
//        }
        
    }
}

//----------------------------------------------------------------------------------------------
// ObservationCell class
//----------------------------------------------------------------------------------------------
class ObservationCell {
    var modifiedAt: Int
    var state: Int
    var objectID: NSManagedObjectID
    var imageURL: String?
    var localThumbPath: String?
    var localFullPath: String?
    
    init(objectID: NSManagedObjectID, state: Int, modifiedAt: Int) {
        self.objectID = objectID
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
        var urlArr = split(imageURL!) {$0 == "/"}
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
//      localThumbPath = savedPath
        return savedPath
    }

}


