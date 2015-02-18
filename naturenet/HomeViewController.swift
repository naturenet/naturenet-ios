//
//  HomeViewController.swift
//  nn
//
//  Created by Jinyue Xia on 12/30/14.
//  Copyright (c) 2014 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController : UIViewController, UICollectionViewDataSource,
                        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signinBtn: UIButton!
    
    var prevViewController: ObservationDetailController?
    
    var items = ["Observations", "Activities", "Design Ideas", "ACES Tour", "Profile", "About"]
    var images = ["camera", "activity", "bulb", "map", "profile", "about"]
    
    override func viewWillAppear(animated: Bool) {
        if Session.isSignedIn() {
            signinBtn.hidden = true
            var account = Session.getAccount()
            welcomeLabel.text = "welcome, " + account!.username
            welcomeLabel.hidden = false
        } else {
            signinBtn.hidden = false
            welcomeLabel.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //----------------------------------------------------------------------------------------------------------------------
    // collectionView
    //----------------------------------------------------------------------------------------------------------------------
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("homecell", forIndexPath: indexPath) as HomeCell
        cell.mLabel.text = self.items[indexPath.row]
        // cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.whiteColor() : UIColor.lightGrayColor()
        cell.mImageView.image = UIImage(named: self.images[indexPath.row])
        return cell
    }
    
    // programmatically set the cell's size
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            var photoPath =  self.images[indexPath.row]
            var mImage = UIImage(named: self.images[indexPath.row])
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenWidth = screenSize.width;
            let screenHeight = screenSize.height;
            
            return CGSize(width: screenWidth/2 - 30, height: screenWidth/2 - 20)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // implement UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegueWithIdentifier("observationSeg", sender: self)
        case 1 :
            self.performSegueWithIdentifier("activitiesSeg", sender: self)
        case 2 :
            self.performSegueWithIdentifier("designIdeaSeg", sender: self)
        case 4 :
            self.performSegueWithIdentifier("profileSeg", sender: self)
        case 5 :
            self.performSegueWithIdentifier("homeToAboutSeg", sender: self)
        default:
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "observationSeg" {
            let destinationVC = segue.destinationViewController as ObservationsController
            if self.prevViewController != nil {
                destinationVC.receivedNoteFromObservation = self.prevViewController!.saveNote()
                destinationVC.receivedMediaFromObservation = self.prevViewController!.noteMedia
                destinationVC.receivedFeedbackFromObservation = self.prevViewController!.feedback
            }
        }

    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for receiced data passed back
    //----------------------------------------------------------------------------------------------------------------------
    
    @IBAction func cancelToHomeViewController(segue:UIStoryboardSegue) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
