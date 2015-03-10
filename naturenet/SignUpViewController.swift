//
//  SignUpViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/19/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, APIControllerProtocol, UITextFieldDelegate {
    var consentString: String!
    var apiService = APIService()
    var signInAccount: Account?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        apiService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when any textField rececives input, dismiss alertMessage
    func textFieldDidBeginEditing(textField: UITextField) {
        self.alertLabel.text = ""
        self.alertLabel.hidden = true
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    @IBAction func backgroundTouch(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func signupSendPressed(sender: UIBarButtonItem) {
        if countElements(usernameTextField.text) == 0 || countElements(passTextField.text) == 0
                || countElements(emailTextField.text) == 0 || countElements(nameTextField.text) == 0 {
            showAlertLabel("You must fill all fields!")
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            self.startLoading()
            var name = nameTextField.text
            var username = usernameTextField.text
            var password = passTextField.text
            var email = emailTextField.text
            var url = APIAdapter.api.getCreateAccountLink(username)
            var params = ["name": name, "password": password, "email": email, "consent": consentString] as Dictionary<String, Any>
//            self.signInAccount = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Account), managedObjectConect: SwiftCoreDataHelper.nsManagedObjectContext) as Account
            apiService.post(NSStringFromClass(Account), sourceData: self.signInAccount?, params: params, url: url)
        }
    }
    
    // implement this method for APIControllerProtocol delegate
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        println("got result from sign up")
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as Int
            if (status == 400) {
                println("got result status 400")
                var statusText = response["status_txt"] as String
                self.stopLoading()
                self.showAlertLabel(statusText)
            }
            
            if status == 200 {
                var data = response["data"] as NSDictionary!
                if from == "POST_" + NSStringFromClass(Account) {
                    self.signInAccount = Account.saveToCoreData(data)
                    let predicate = NSPredicate(format: "name= %@", "aces")
                    if let site = NNModel.fetechEntitySingle(NSStringFromClass(Site), predicate: predicate!) as? Site {
                        Session.signIn(self.signInAccount!, site: site)
                        self.stopLoading()
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        Site.doPullByNameFromServer(self.apiService, name: "aces")
                    }
                }
                if from == "POST_" + NSStringFromClass(Site) {
                    var site = Site.saveToCoreData(data)
                    Session.signIn(self.signInAccount!, site: site)
                    self.stopLoading()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        })

    }
    
    // password textfield delegate, examine length not exceed 4
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        let prospectiveText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == passTextField {
            if countElements(string) > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                let resultingStringLengthIsLegal = countElements(prospectiveText) <= 4
                result = replacementStringIsLegal && resultingStringLengthIsLegal
            }
        }
        return result
    }

    func showAlertLabel(message: String) {
        self.alertLabel.text = message
        self.alertLabel.hidden = false
    }
    
    func createWarningAlert(message: String) {
        var alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func startLoading() {
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

    }
    
    func stopLoading() {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
