//
//  UberHandler.swift
//  Uber Rider
//
//  Created by jcapasix on 17/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//



import Foundation
import FirebaseDatabase

protocol UberControllerDelegate {
    func canCallUber(delegateCalled:Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName:String)
    func updateDriversLocation(lat:Double, long:Double)
}

class UberHandler{
    private static let _instance = UberHandler()
    
    var delegate: UberControllerDelegate?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    static var Instance: UberHandler{
        return _instance
    }
    
    func observeMessagesForRider(){
        
        //RIDER REQUESTED UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded){
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider_id = snapshot.key
                        print("Rider REQUEST UBER: \(name)")
                        self.delegate?.canCallUber(delegateCalled: true)
                    }
                }
            }
        }
        
        //RIDER CANCEL UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved){
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider_id = snapshot.key
                        print("Rider CANCEL UBER: \(name)")
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        
        //DRIVER ACCEPTED UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) {
            (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == ""{
                        self.driver = name
                        print("Driver ACCEPTED UBER: \(name)")
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        }
        
        //DRIVER CANCEL UBER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) {
            (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.driver = ""
                        print("Driver CANCEL UBER: \(name)")
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        
        //DRIVER UPDATIONG LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged){(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    
                    if name == self.driver{
                        if let latitude = data[Constants.LATITUDE] as? Double{
                            if let longitude = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.updateDriversLocation(lat: latitude, long: longitude)
                                
                            }
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    func requestUber(latitude:Double, longitude:Double){
        let data:Dictionary<String, Any> = [Constants.NAME: rider,
                                            Constants.LATITUDE:latitude,
                                            Constants.LONGITUDE:longitude]
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
        
    func cancelUber(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
        
    }
    
    func updateRiderLocation(lat:Double, long:Double){
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE:lat,
                                                                                   Constants.LONGITUDE:long])

    }
    
}
