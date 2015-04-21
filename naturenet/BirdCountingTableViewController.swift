//
//  BirdCountingTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/8/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdCountingTableViewController: UITableViewController, UICollectionViewDelegate {
    // UI
    @IBOutlet weak var birdsCollectionView: UICollectionView!
    
    // tableview data
    var items = ["Black-billed Magpie", "Pine Siskin", "Stellers Jay", "Red-breasted", "Mallard", "American Goldfinch"]
    var images = ["nnObservations", "nnActivities", "nnDesign", "nnAces", "nnProfile", "nnAbout"]
    
    //----------------------------------------------------------------------------------------------------------------------
    // collectionView
    //----------------------------------------------------------------------------------------------------------------------
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("birdcell", forIndexPath: indexPath) as! BirdCountingCollectionViewCell
        // cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.whiteColor() : UIColor.lightGrayColor()
        cell.imageView.image = UIImage(named: "bird")
        cell.label.text = items[indexPath.row]
        return cell
    }
    
    // programmatically set the cell's size
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            var photoPath =  self.images[indexPath.row]
            var mImage = UIImage(named: self.images[indexPath.row])
            let viewSize = collectionView.bounds
            let cellWidth = viewSize.width/3 - 10
            let cellHeight = viewSize.height/2 - 10
            
            return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // implement UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("birdCountingDetail", sender: self.birdsCollectionView.cellForItemAtIndexPath(indexPath))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            self.performSegueWithIdentifier("birdcountingToObservations", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "birdCountingDetail" {
            let destViewController = segue.destinationViewController as! BirdCountingDetailTableViewController
            let cell = sender as! BirdCountingCollectionViewCell
            let indexPath = birdsCollectionView.indexPathForCell(cell)
            destViewController.navigationItem.title = items[indexPath!.row]
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        }
        
    }
    
    @IBAction func saveBirdObservation() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
