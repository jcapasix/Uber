//
//  Utils.swift
//  Uber Rider
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import Foundation
import UIKit

final class Utils{
    static let sharedInstance = Utils()
    private init(){}
    
    func showAlert(title:String, message:String, view:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        view.present(alert, animated: true, completion: nil)
    }
    
}
