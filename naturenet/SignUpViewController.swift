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
    
    @IBAction func usernameTextFieldDidChange(sender: UITextField) {
        toggleEnableForSendButton()
    }
    
    @IBAction func passTextFieldDidChange(sender: UITextField) {
        toggleEnableForSendButton()
    }
    
    @IBAction func nameTextFieldDidChange(sender: UITextField) {
        toggleEnableForSendButton()
    }
    
    @IBAction func emailTextFieldDidChange(sender: UITextField) {
        toggleEnableForSendButton()
    }
    
    // when any textField rececives input, dismiss alertMessage
    func textFieldDidBeginEditing(textField: UITextField) {
        self.alertLabel.text = ""
        self.alertLabel.hidden = true
//        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    @IBAction func backgroundTouch(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func signupSendPressed(sender: UIBarButtonItem) {
        if usernameTextField.text!.characters.count == 0 || passTextField.text!.characters.count == 0
                || emailTextField.text!.characters.count == 0 || nameTextField.text!.characters.count == 0 {
            showAlertLabel("You must fill all fields!")
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            self.startLoading()
            let name = nameTextField.text
            let username = usernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let password = passTextField.text
            let email = emailTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if !SignInViewController.hasWhiteSpace(username) && !SignInViewController.hasWhiteSpace(email) {
                let url = APIAdapter.api.getCreateAccountLink(username)
                let params = ["name": name, "password": password, "email": email, "consent": consentString] as Dictionary<String, Any>
                apiService.post(NSStringFromClass(Account), sourceData: self.signInAccount, params: params, url: url)
            } else {
                let errorMessage = "Username or email should not contain spaces"
                self.showAlertLabel(errorMessage)
                self.stopLoading()
            }
        }
    }
    
    // password textfield delegate, examine length not exceed 4
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        let prospectiveText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == passTextField {
            if string.characters.count > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                let resultingStringLengthIsLegal = prospectiveText.characters.count <= 4
                result = replacementStringIsLegal && resultingStringLengthIsLegal
            }
        }
        return result
    }
    
    // implement this method for APIControllerProtocol delegate
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        // println("got result from sign up")
        dispatch_async(dispatch_get_main_queue(), {
            let status = response["status_code"] as! Int
            if (status == 400) {
                // println("got result status 400")
                let statusText = response["status_txt"] as! String
                self.stopLoading()
                self.showAlertLabel(statusText)
            }
            
            if status == 600 {
                let statusText = "Internet seems not working, please check your Internt!"
                self.stopLoading()
                self.showAlertLabel(statusText)
            }
            
            if status == 200 {
                let data = response["data"] as! NSDictionary!
                if from == "POST_" + NSStringFromClass(Account) {
                    self.signInAccount = Account.saveToCoreData(data)
                    let predicate = NSPredicate(format: "name= %@", "aces")
                    if let site = NNModel.fetechEntitySingle(NSStringFromClass(Site), predicate: predicate) as? Site {
                        Session.signIn(self.signInAccount!, site: site)
                        self.stopLoading()
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    } else {
                        Site.doPullByNameFromServer(self.apiService, name: "aces")
                    }
                }
                if from == "POST_" + NSStringFromClass(Site) {
                    let site = Site.saveToCoreData(data)
                    Session.signIn(self.signInAccount!, site: site)
                    self.stopLoading()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        })

    }
    
    // check all the textfields have been filled
    func checkInputFieldsValid() -> Bool {
        var isValid = false
        if !usernameTextField.text!.isEmpty && !passTextField.text!.isEmpty
            && !nameTextField.text!.isEmpty && !emailTextField.text!.isEmpty {
            isValid = true
        }
        
        return isValid
    }

    func toggleEnableForSendButton() {
        if checkInputFieldsValid() {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func showAlertLabel(message: String) {
        self.alertLabel.text = message
        self.alertLabel.hidden = false
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

}
