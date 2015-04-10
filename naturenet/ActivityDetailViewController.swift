//
//  ActivityDetailViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/15/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var activity: Context!

    @IBOutlet weak var activityNavItem: UINavigationItem!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityDescriptionTextView: UITextView!
    
    var cameraImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        var iconURL = activity.extras
        loadImageFromWeb(iconURL, imageView: activityIconImageView)
        activityNavItem.title = activity.title
        activityDescriptionTextView.text = activity.context_description
    }
    
    private func loadImageFromWeb(iconURL: String, imageView: UIImageView) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
            } else {
                let image = UIImage(data: data)
                imageView.image = image
            }
        })
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
            detailVC.sourceViewController = NSStringFromClass(ActivityDetailViewController)
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
    

}
