//
//  LoginViewController.swift
//  On The Map
//
//  Created by Richard smith on 3/30/16.
//  Copyright © 2016 Richard smith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailLoginTextfield: UITextField!
    @IBOutlet weak var passwordLoginTextfield: UITextField!
    
    @IBOutlet weak var loginWithEmailButton: UIButton!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLoginTextfield.delegate = self
        passwordLoginTextfield.delegate = self
        
        activityIndicator.hidesWhenStopped = true        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // TextFields
    
    
    @IBAction func passwordBeganEditing(sender: AnyObject) {
        if passwordLoginTextfield.text == "Password" {
        passwordLoginTextfield.text = ""
        passwordLoginTextfield.secureTextEntry = true
        }
    }
    
    
    @IBAction func passwordEndEditing(sender: AnyObject) {
        if passwordLoginTextfield.text == "" {
            passwordLoginTextfield.secureTextEntry = false
            passwordLoginTextfield.text = "Password"
        }

    }
   
    @IBAction func emailBeganEditing(sender: AnyObject) {
        if emailLoginTextfield.text == "Email" {
        emailLoginTextfield.text = ""
        }
    }
    
    @IBAction func emailEndEditing(sender: AnyObject) {
        if emailLoginTextfield.text == "" {
        emailLoginTextfield.text = "Email"
        }
    }
    
    
    //Login Functions 
    func getSessionID() {
        
       let emailLogin = emailLoginTextfield.text!
       let passwordLogin = passwordLoginTextfield.text!
        
        /*  Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailLogin)\", \"password\": \"\(passwordLogin)\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        /*  Make the request */
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.errorTextLabel.text = "Login Failed"
                    
                        if self.activityIndicator.isAnimating() {
                            self.activityIndicator.stopAnimating()
                            
                        }
                print("Your request returned a status code other than 2xx!")
                print(emailLogin)
                print(passwordLogin)
                        print(hardCodedLocation())
                }
                return
                
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // Take the five extra chars from the data
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            // Parse new data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                
            } catch {
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            let sessionInfo = parsedResult!["session"]!
            let accountInfo = parsedResult!["account"]!
            
            Udacity.Session.ID = sessionInfo!["id"]! as! String
            Udacity.Session.Expiration = sessionInfo!["expiration"]! as! String
            Udacity.Account.Key = accountInfo!["key"]! as! String
            Udacity.Account.Registered = accountInfo!["registered"]! as! Int
            
            self.completeLogin()
                    }
        
        task.resume()
        }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(emailLoginTextfield)
        resignIfFirstResponder(passwordLoginTextfield)
    }
    private func setUIEnabled(enabled: Bool) {
        emailLoginTextfield.enabled = enabled
        passwordLoginTextfield.enabled = enabled
        loginWithEmailButton.enabled = enabled
        errorTextLabel.text = ""
        errorTextLabel.enabled = enabled
        activityIndicator.hidesWhenStopped = true
    }
    
    func completeLogin() {
        
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
    
    }
        


    //Login Buttons

    @IBAction func loginWithEmailButton(sender: AnyObject) {
    
        userDidTapView(self)
        setUIEnabled(false)
        
        activityIndicator.activityIndicatorViewStyle = .White
        activityIndicator.startAnimating()
        
          if emailLoginTextfield.text!.isEmpty || passwordLoginTextfield.text!.isEmpty {
               errorTextLabel.text = "Username or Password Empty."
            } else {
               
               getSessionID()
             }
        
    }



    @IBAction func signUpButton(sender: AnyObject) {
    
    UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
    }
    
}
