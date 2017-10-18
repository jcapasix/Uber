//
//  URSignInVC.swift
//  Uber Rider
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import UIKit

class URSignInVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let RIDER_SEGUE = "showRider"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LogIn(_ sender: Any) {
        if (!(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!){
            AuthProvider.Instance.logIn(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil{
                    Utils.sharedInstance.showAlert(title: "Problem With Authentication", message: message!, view:self)
                }
                else{
                    UberHandler.Instance.rider = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    print("LOGIN COMPLETE")
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
                
            })
        }
        else{
            Utils.sharedInstance.showAlert(title: "Email And Password Are Required", message:"Please enter email and password in the text fields", view:self)
        }
    }
    
    @IBAction func SignUp(_ sender: Any) {
        if (!(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!){
            AuthProvider.Instance.SignUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil{
                    Utils.sharedInstance.showAlert(title: "Problem With Creating A New User", message: message!, view:self)
                }
                else{
                    
                    UberHandler.Instance.rider = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    print("CREATING USER COMPLETE")
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }
        else{
            Utils.sharedInstance.showAlert(title: "Email And Password Are Required", message:"Please enter email and password in the text fields", view:self)
            //self.alertTheUser(title: "Email And Password Are Required", message:"Please enter email and password in the text fields")
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
