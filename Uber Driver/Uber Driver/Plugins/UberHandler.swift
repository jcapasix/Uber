//
//  UberHandler.swift
//  Uber Driver
//
//  Created by jcapasix on 17/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberControllerDelegate{
    func acceptUber(lat:Double, long:Double)
    func riderCanceledUber()
    func uberCanceled()
    func updateRidersLocation(lat: Double, long: Double)
}

class UberHandler{
    private static let _instance = UberHandler()
    
    var delegate: UberControllerDelegate?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance: UberHandler{
        return _instance
    }
    
    func observerMessageForDriver(){
        
        //RIDER REQUEST AN UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded){(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let latitude = data[Constants.LATITUDE] as? Double{
                    if let longitude = data[Constants.LONGITUDE] as? Double{
                        
                        if let name = data[Constants.NAME] as? String{
                            self.rider = name
                            print("Rider REQUEST UBER: \(name)")
                            self.delegate?.acceptUber(lat: latitude, long: longitude)
                        }
                    }
                }
                
            }
        }
        
        //RIDER CANCELED UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        print("Rider CANCELED UBER: \(name)")
                        self.rider = "";
                        self.delegate?.riderCanceledUber()
                    }
                }
            }
        }

        //DRIVER ACCEPTS UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.driver_id = snapshot.key
                    }
                }
            }
        }

        //DRIVER CANCELED UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.delegate?.uberCanceled()
                    }
                }
            }
        }
        
        
        //RIDER UPDATIONG LOCATION
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged){(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        if let latitude = data[Constants.LATITUDE] as? Double{
                            if let longitude = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.updateRidersLocation(lat: latitude, long: longitude)
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
    }
    
    
    
    func uberAccepted(lat: Double, long:Double){
        let data: Dictionary<String, Any> = [Constants.NAME: driver,
                                             Constants.LATITUDE: lat,
                                             Constants.LONGITUDE:long]
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelUberForDriver(){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    
    func updateDriverLocation(lat:Double, long:Double){
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE:lat,
                                                                                   Constants.LONGITUDE:long])
    }
    
}



