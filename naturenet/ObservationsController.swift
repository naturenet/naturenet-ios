//
//  ObservationsController.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/28/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData


class ObservationsController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                APIControllerProtocol, CLUploaderDelegate, SaveObservationProtocol, UpdateProgressViewDelegate {
    // UI Outlets
    @IBOutlet weak var observationCV: UICollectionView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var uploadProgressView: UIProgressView!
    
    // add an isFromGallery flag with the picked image
    struct PickedImage {
        var image: UIImage?
        var isFromGallery: Bool = false
    }

    // data
    var apiService = APIService()
    var celldata = [ObservationCell]()
    var cloudinary: CLCloudinary = CLCloudinary()
    var pickedImage: PickedImage?
    
    var refresher: UIRefreshControl!

    // data received after clicking "send" from ObservationDetailController 
    // values set in saveObservationDetail()
    var receivedNoteFromObservation: Note?
    var sourceViewController: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiService.delegate = self
        loadData()
        
        // if the received photo is from Activity/Tour/Location
//        if sourceViewController == NSStringFromClass(ActivityDetailTableViewController)
//            || sourceViewController == NSStringFromClass(TourViewController)
//            || sourceViewController == NSStringFromClass(LocationDetailViewController) {
//            self.receivedNoteFromObservation!.push(apiService)
//            self.updateReceivedNoteStatus(self.receivedNoteFromObservation!, state: NNModel.STATE.SENDING)
//            self.uploadProgressView.setProgress(0.01, animated: true)
//        }
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.observationCV.addSubview(refresher)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        var uploadNumbers: Int = 0
        for data in celldata {
            if data.getStatus() == "ready to send" {
                var noteObjectId = data.objectID
                let predicate = NSPredicate(format: "self = %@", noteObjectId)
                var note = NNModel.fetechEntitySingle(NSStringFromClass(Note), predicate: predicate) as! Note
                self.receivedNoteFromObservation = nil
                note.push(self.apiService)
                uploadNumbers++
            }
        }
        if uploadNumbers == 0 {
            refresher.endRefreshing()
        }
    }
    
    // after post, do it in background in case the user goes back home
    // when note uid is ready, order must follow this
    // upload feedback -> upload to cloudinary -> upload media
    // start the tasks from main thread(cloudinary requires main thread!!),
    // the async tasks in the push methods will do the task(e.g. handling request, image uploading)
    // in the background thread.
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if status == 600 {
                if let note = sourceData as? Note {
                    self.updateReceivedNoteStatus(note)
                }
                let alertTitle = "Internet Connection Problem"
                let alertMessage = "Please check your Internet connection"
                AlertControllerHelper.createGeneralAlert(alertTitle, message: alertMessage, controller: self)
                return
            }
            
            var uid = response["data"]!["id"] as! Int
            if from == "POST_" + NSStringFromClass(Note) {
                println("now after post_note, ready for uploading feedbacks")
                var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                if let newNote = sourceData as? Note {
                    newNote.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    newNote.doPushFeedbacks(self.apiService)
                    if let newNoteMedia = newNote.getSingleMedia() {
                        if newNoteMedia.url != nil {
                            self.updateReceivedNoteStatus(newNote)
                            self.refresher.endRefreshing()
                        } else {
                            newNoteMedia.apiService = self.apiService
                            newNoteMedia.updateProgressDelegate = self
                            newNoteMedia.uploadToCloudinary()
                        }
                    }
                }
            }
            if from == "POST_" + NSStringFromClass(Feedback) {
                println("now after post_feedback, if this is a new note, ready for uploading to cloudinary, otherwise, do update")
                var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                if let newNoteFeedback = sourceData as? Feedback {
                    newNoteFeedback.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                }
            }
            if from == "POST_" + NSStringFromClass(Media) {
                println("now after post_media")
                if let newNoteMedia = sourceData as? Media {
                    newNoteMedia.updateAfterPost(uid, modifiedAtFromServer: nil)
                    self.updateReceivedNoteStatus(newNoteMedia.note)
                    self.uploadProgressView.setProgress(0, animated: false)
                    self.refresher.endRefreshing()
                }
            }
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
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("obscell", forIndexPath: indexPath) as! HomeCell
        var cellImage = self.celldata[indexPath.row] as ObservationCell
        self.showImageIntoCell(cellImage, cell: cell, indexPath: indexPath)
        return cell
    }
    
    // programmatically set the cell's size
    // be carefull here
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            // let screenSize: CGRect = UIScreen.mainScreen().bounds
            let viewSize = collectionView.bounds
            let screenWidth = viewSize.width;
            return CGSize(width: screenWidth/2 , height: screenWidth/2)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ObservationsToDetail", sender: indexPath)
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ObservationsToDetail" {
            let detailVC = segue.destinationViewController as! ObservationDetailController
            detailVC.sourceViewController = NSStringFromClass(ObservationsController)
            // if passed from a cell
            if let indexPath = sender as? NSIndexPath {
                let selectedCell = celldata[indexPath.row]
                detailVC.noteIdFromObservations = selectedCell.objectID
                self.pickedImage = nil
            } else if self.pickedImage != nil { // else from a camera
                detailVC.imageFromObservation = self.pickedImage
            }
            // assign observationsController(self) to be a delegate for ObservationDetailController
            detailVC.saveObservationDelegate = self
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // observationDetailController's delegate(observationsController/self), the delegate conforms SaveObservationProtocol
    //----------------------------------------------------------------------------------------------------------------------
    func saveObservation(note: Note, media: Media?, feedback: Feedback?) {
        if media != nil {
            updateCollectionView(note, media: media!)
            self.uploadProgressView.setProgress(0.01, animated: false)
        }
        note.push(apiService)
//        self.receivedNoteFromObservation = note
        updateReceivedNoteStatus(note, state: NNModel.STATE.SENDING)
    }
    
    // refresh data
    func updateCollectionView(note: Note, media: Media) {
        var newCell = ObservationCell(objectID: note.objectID, state: note.state.integerValue,
            modifiedAt: note.modified_at)
        newCell.localFullPath = media.full_path
        celldata.insert(newCell, atIndex: 0)
        self.observationCV.reloadData()
    }
    
    // update status in the new created cell based on the state of note's media
    func updateReceivedNoteStatus(note: Note) {
        for obs in self.celldata {
            if obs.objectID == note.objectID {
                obs.state = note.state.integerValue
            }
        }
        self.observationCV.reloadData()
    }
    
    // manually update the status of uploading the note, e.g. "sending"
    func updateReceivedNoteStatus(note: Note, state: Int) {
        for obs in self.celldata {
            if obs.objectID == note.objectID {
                obs.state = state
            }
        }
        self.observationCV.reloadData()
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // the delegate conforms UpdateProgressViewDelegate
    //----------------------------------------------------------------------------------------------------------------------
    func onUpdateProgress(progress: Float) {
        self.uploadProgressView.setProgress(progress, animated: true)
    }

    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func pickImage(sender: AnyObject) {
        var picker:UIImagePickerController = UIImagePickerController()
        // remember to assign delegate to self
        picker.delegate = self
        self.pickedImage = PickedImage(image: nil, isFromGallery: false)
        
        var popover:UIPopoverController?
        var alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera(picker)
        }
        
        var gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) {
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
        }
    }
    
    func openCamera(picker: UIImagePickerController!) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.pickedImage?.isFromGallery = false
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            openGallary(picker)
        }
    }

    func openGallary(picker: UIImagePickerController!) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.pickedImage?.isFromGallery = true
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        // println("picker cancel.")
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.pickedImage?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("ObservationsToDetail", sender: self)
    }
    
    /* MARK
    func getLocaitonFromPhoto(info: [NSObject : AnyObject]) {
        // implement later if it is needed
    } */

    //----------------------------------------------------------------------------------------------
    // some utility functions
    //----------------------------------------------------------------------------------------------
    
    // load data for this collectionview
    func loadData() {
        if !Session.isSignedIn() {
            let alertMessage = "You have to signed in!"
            AlertControllerHelper.createGeneralAlert("Alert", message: alertMessage, controller: self)
            return
        }
        if let account = Session.getAccount() {
            var notes = account.getNotes()
            for note in notes {
                var mNote = note as Note
                var medias = mNote.getMedias()
                // println("you have \(medias.count) medias")
                for media in medias {
                    var mMedia = media as! Media
                    // url is empty, but has fullpath or thumbpath, then check whether the file exists
                    if mMedia.url == nil {
                        let fileManager = NSFileManager.defaultManager()
                        if (mMedia.thumb_path != nil && !fileManager.fileExistsAtPath(mMedia.thumb_path!))
                            || (mMedia.full_path != nil && !fileManager.fileExistsAtPath(mMedia.full_path!)) {
                                continue
                        }
                    }
                    
                    var obscell = ObservationCell(objectID: mNote.objectID,
                        state: mNote.state.integerValue, modifiedAt: mNote.modified_at)
                    if let tPath = mMedia.thumb_path {
                        obscell.localThumbPath = tPath
                    }
                    if let fPath = mMedia.full_path {
                        obscell.localFullPath = fPath
                    }
                    if let mediaURL = mMedia.url {
                        obscell.imageURL = mediaURL
                    }
                    celldata.append(obscell)
                }
            }
            celldata.sort({$0.modifiedAt.longLongValue > $1.modifiedAt.longLongValue})
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
            if fileManager.fileExistsAtPath(lPath) {
                cell.mImageView.image = UIImage(named: lPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                return
            }
        } else if let fPath = cellImage.localFullPath {
            // println("image local full path is :  \(fPath)")
            if fileManager.fileExistsAtPath(fPath) {
                cell.mImageView.image = UIImage(named: fPath)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                return
            }
        }
        
        if let imageurl = cellImage.imageURL {
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
                self.saveImageThumb(cellImage, data: data)
            }
        })
    }
    
    func saveImageThumb(cellImage: ObservationCell, data: NSData) {
        var fileName = String(cellImage.modifiedAt.longLongValue) + ".jpg"
        var tPath: String = ObservationCell.saveToDocumentDirectory(data, name: fileName)!
        cellImage.localThumbPath = tPath
        var predicate = NSPredicate(format: "SELF = %@", cellImage.objectID)
        
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        if let mNote = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Note), withPredicate: predicate, managedObjectContext: nsManagedContext) as? Note {
            var media = mNote.getSingleMedia()
            media!.setLocalThumbPath(tPath)
        }
    }
    
    

}

//----------------------------------------------------------------------------------------------
// ObservationCell class
//----------------------------------------------------------------------------------------------
class ObservationCell {
    var modifiedAt: NSNumber
    var state: Int
    var objectID: NSManagedObjectID
    var imageURL: String?
    var localThumbPath: String?
    var localFullPath: String?
    
    init(objectID: NSManagedObjectID, state: Int, modifiedAt: NSNumber) {
        self.objectID = objectID
        self.state = state
        self.modifiedAt = modifiedAt
    }
    
    func getStatus() -> String {
        var status: String = "ready to send"
        if (self.state == NNModel.STATE.DOWNLOADED || self.state == NNModel.STATE.NEW
            || self.state == NNModel.STATE.SAVED) {
            status = "ready to send"
        }
        
        if self.state == NNModel.STATE.SYNCED {
            status = "sent"
        }
        
        if self.state == NNModel.STATE.SENDING {
            status = "sending"
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
    
    func toString() -> String {
        return "cell modified at \(self.modifiedAt.longLongValue) local thumpath is: \(self.localThumbPath) local fullpath is: \(self.localFullPath)"
    }
    
    // save to local document directory
    class func saveToDocumentDirectory(data: NSData, name: String) -> String?  {
        var documentDirectory: String?
        var savedPath: String?
        
        // LibraryDirectory may need to be changed to DocumentationDirectory when it is deployed on a phone
        // changed from LibraryDirectory to CachesDirectory to handle data storage efficiency.
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            documentDirectory = paths[0] as? String
            savedPath = documentDirectory! + "/\(name)"
            NSFileManager.defaultManager().createFileAtPath(savedPath!, contents: data, attributes: nil)
        }
        return savedPath
    }

}


