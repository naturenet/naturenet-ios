//
//  LocationDetailViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/24/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var locationTitle: String!
    var locationDescription: String!
    var cameraImage: UIImage?
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if locationTitle == "Other" {
            navItem.title = locationTitle
        } else {
            var substrings = locationTitle.componentsSeparatedByString(".")
            navItem.title = substrings[0]
        }
        titleTextField.text = locationTitle
        descriptionTextView.text = locationDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backpressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func openCamera() {
        let picker:UIImagePickerController = UIImagePickerController()
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
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("tourDetailToObservation", sender: self)
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailVC = segue.destinationViewController as! ObservationDetailController
        detailVC.imageFromObservation = ObservationsController.PickedImage(image: self.cameraImage, isFromGallery: false)
        detailVC.sourceViewController = NSStringFromClass(LocationDetailViewController)

    }

}
