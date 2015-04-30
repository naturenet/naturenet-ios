//
//  ActivityDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/19/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivityDetailTableViewController: UITableViewController, UINavigationControllerDelegate,
                        UIImagePickerControllerDelegate, SaveObservationProtocol, APIControllerProtocol {
    
    var activity: Context!
    var cameraImage: UIImage!
    var apiService = APIService()
    var notesInActivtity: [Note]?
    
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var numOfNoteInActivity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        apiService.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // self.edgesForExtendedLayout = UIRectEdge.None

        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    private func setupView() {
        var iconURL = activity.extras
        loadImageFromWeb(iconURL, imageView: activityIconImageView)
        self.navigationItem.title = activity.title
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180.0
        activityDescriptionLabel.text = activity.context_description
        self.notesInActivtity = Session.getAccount()?.getNotesByActivity(self.activity)
        let number: Int = notesInActivtity!.count
        self.numOfNoteInActivity.text = String(number)
    }
    
    private func loadImageFromWeb(iconURL: String, imageView: UIImageView) {
        if let url = NSURL(string: iconURL) {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                response, data, error in
                if error != nil {
                    let image = UIImage(named: "networkerror")
                    imageView.image = image
                } else {
                    let image = UIImage(data: data)
                    imageView.image = image
                }
            })
        }
    }

    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "activityToObservation" {
            let detailVC = segue.destinationViewController as! ObservationDetailController
            //            detailVC.imageFromCamera = self.cameraImage!
            //            detailVC.imageFromObservation?.image = self.cameraImage!
            //            detailVC.imageFromObservation?.isFromGallery = false
            detailVC.imageFromObservation = ObservationsController.PickedImage(image: self.cameraImage, isFromGallery: false)
            detailVC.activityNameFromActivityDetail = activity.title
            detailVC.saveObservationDelegate = self
            detailVC.sourceViewController = NSStringFromClass(ActivityDetailTableViewController)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func openCamera() {
        var picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        println("picker cancel.")
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("activityToObservation", sender: self)
    }
    
    
    // implement saveObservation to conform SaveObservationProtocol
    func saveObservation(note: Note, media: Media?, feedback: Feedback?) {
         note.push(apiService)
    }
    
    // implement didReceiveResults to conform APIControllerProtocol
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if status == 600 {
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
                        } else {
                            newNoteMedia.apiService = self.apiService
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

                }
            }
        })

    }
    
}
