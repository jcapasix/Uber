//
//  DBProvider.swift
//  Uber Rider
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider{
    private static let _instance = DBProvider()
    static var Instance: DBProvider{
        return _instance
    }
    
    var dbRef:DatabaseReference{
        return Database.database().reference()
    }
    var ridersRef: DatabaseReference{
        return dbRef.child(Constants.RIDERS)
    }
    
    //request Ueber
    var requestRef:DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    var requestAcceptedRef:DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    
    
    func saveUser(withID:String, email:String, password:String){
        let data: Dictionary<String, Any> = [Constants.EMAIL:email,
                                             Constants.PASSWORD:password,
                                             Constants.isRider:true]
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
    }
}
