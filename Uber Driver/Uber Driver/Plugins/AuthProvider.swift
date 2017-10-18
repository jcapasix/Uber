//
//  AuthProvider.swift
//  Uber Driver
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import Foundation
import FirebaseAuth
import SVProgressHUD

typealias LoginHandler = (_ msg: String?) -> Void;


struct LoginErrorCode {
    static let WRONG_PASSWORD = "Wrong Password, Please Enter The Correct Password"
    static let INVALID_EMAIL = "Invalid Email Addres, Please Provide a Real Email Address"
    static let USER_NOT_FOUND = "User Not Found, Please Register"
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use, Please Use Another Email"
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long"
    static let PROBLEM_CONNECTING = "Problem Connecting To Database, Please Try Later"
}

class AuthProvider{
    
    private static let _instance = AuthProvider()
    
    static var Instance:AuthProvider {
        return _instance
    }
    
    func logIn(withEmail:String, password:String, loginHandler:LoginHandler?){
        //SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
         
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else{
                loginHandler?(nil)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func SignUp(withEmail:String, password:String, loginHandler:LoginHandler?){
        //SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else{
                if user?.uid != nil{
                    DBProvider.Instance.saveUser(withID: (user?.uid)!, email:withEmail , password: password)
                    self.logIn(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func logOut() -> Bool{
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut();
                return true;
            }catch{
                return false;
            }
        }
        return true
    }
    
    
    private func handleErrors(err: NSError, loginHandler:LoginHandler?){
        
        if let errCode = AuthErrorCode(rawValue: err.code){
            
            switch errCode{
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
                
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
                
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
                
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
                
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
                
            }
            
        }
    }
}
