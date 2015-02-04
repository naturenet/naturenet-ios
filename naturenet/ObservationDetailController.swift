//
//  ObservationDetailController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ObservationDetailController: UIViewController, UITableViewDelegate {

    // UI Outlets
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    // data
    var receivedCellData: ObservationCell?
    var noteMedia: Media?
    var note: Note?
    
    // tableview data
    var titles = ["Description", "Activity", "Location"]
    var details = ["Description", "Activity", "Location"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
        imageLoadingIndicator.startAnimating()
//        setUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "profilecell")
        let cell = tableView.dequeueReusableCellWithIdentifier("editObsCell", forIndexPath: indexPath) as EditObsTableViewCell
        cell.editCellTitle!.text = titles[indexPath.row]
        cell.editCellDetail!.text = details[indexPath.row]
        return cell
    }

    
    func loadData() {
        var mediaUID = receivedCellData!.uid as Int
        self.noteMedia = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Media), uid: mediaUID) as Media?
        self.note = noteMedia?.getNote()
        details[0] = note!.content
        loadFullImage(noteMedia!.url)
        println(" note info is: \(self.noteMedia!.getNote().toString()) media info: \(noteMedia!.toString()) ")
    }
    
    func setUI() {
        if let desc = self.note?.content {
//            descriptionView.text = desc
        }
    
    }
    
    func loadFullImage(url: String) {
        var nsurl: NSURL = NSURL(string: url)!
        let urlRequest = NSURLRequest(URL: nsurl)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
                
            } else {
                let image = UIImage(data: data)
                self.noteImageView.image = image
                self.imageLoadingIndicator.stopAnimating()
                self.imageLoadingIndicator.removeFromSuperview()
            }
        })
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
