//
//  SignUpViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/19/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, APIControllerProtocol {
    var consentString: String!
    var apiService = APIService()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("passed consent is: \(consentString)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        apiService.delegate = self
    }
    
    @IBAction func backgroundTouch(sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func signupSendPressed(sender: UIBarButtonItem) {
        println("signup pressed")
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        if countElements(usernameTextField.text) == 0 || countElements(passTextField.text) == 0
                || countElements(emailTextField.text) == 0 || countElements(nameTextField.text) == 0 {
            createWarningAlert("You must fill all fields!")
        } else {
            var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
            var account = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Account), managedObjectConect: nsManagedContext) as Account
            account.name = nameTextField.text
            account.username = usernameTextField.text
            account.password = passTextField.text
            account.email = emailTextField.text
            account.commit()
            SwiftCoreDataHelper.saveManagedObjectContext(nsManagedContext)
            var url = APIAdapter.api.getCreateAccountLink(account.username)
            var params = ["name": account.name, "password": account.password, "email": account.email, "consent": consentString] as Dictionary<String, Any>
            apiService.post(NSStringFromClass(Account), params: params, url: url)
        }
    }
    
    // implement this method for APIControllerProtocol delegate
    func didReceiveResults(from: String, response: NSDictionary) {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as Int
            if (status == 400) {
                var errorMessage = "User Doesn't Exisit"
                var statusText = response["status_txt"] as String
                self.createWarningAlert(statusText)
                return
            }
            
            
            if from == "POST_" + NSStringFromClass(Account) {
                var data = response["data"] as NSDictionary!
                
            }
        })

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        let prospectiveText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == passTextField {
            if countElements(string) > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet
                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                
                let resultingStringLengthIsLegal = countElements(prospectiveText) <= 4
                
                result = replacementStringIsLegal &&
                resultingStringLengthIsLegal
            }
        }
        return result
    }

    func createWarningAlert(message: String) {
        var alert = UIAlertController(title: "Opps", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
