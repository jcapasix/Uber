//
//  UDDriverVC.swift
//  Uber Driver
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import UIKit
import MapKit

class UDDriverVC: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UberControllerDelegate{

    @IBOutlet weak var myMap: MKMapView!
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedUber = false
    private var driverCancelUber = false
    
    @IBOutlet weak var acceptUberBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.delegate = self
        UberHandler.Instance.observerMessageForDriver()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(self.myMap.annotations)
            
            if riderLocation != nil{
                if acceptedUber{
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Riders Location"
                    myMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Drivers Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    //MARK: - UberControllerDelegate
    
    func acceptUber(lat: Double, long: Double) {
        if !acceptedUber{
            uberRequest(title: "Uber Request", message: "You have a request for an uber at this location Lat: \(lat), Log: \(long)", requestAlive: true)
        }
    }
    
    func riderCanceledUber() {
        if !driverCancelUber{
            UberHandler.Instance.cancelUberForDriver()
            self.acceptedUber = false
            self.acceptUberBtn.isHidden = true
            uberRequest(title: "Uber Canceled", message: "The Rider has Canceled The Uber", requestAlive: false)
        }
        
        driverCancelUber = false
    }
    func uberCanceled() {
        acceptedUber = false
        acceptUberBtn.isHidden = true
        //invalidate timer
        timer.invalidate()
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }

    // MARK: - My Methods
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    

    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber{
            
            driverCancelUber = true
            acceptUberBtn.isHidden = true
            UberHandler.Instance.cancelUberForDriver()
            //invalidate timer
            timer.invalidate()
            
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut(){
            if acceptedUber{
                acceptUberBtn.isHidden = true
                UberHandler.Instance.cancelUberForDriver()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }
        else{
            self.uberRequest(title: "Could Not Logout", message: "We could not logout at the moment, please tru again later.", requestAlive: false)
        }
    }
    
    private func uberRequest(title:String, message:String, requestAlive:Bool){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive{
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction:UIAlertAction) in
                self.acceptedUber = true
                self.acceptUberBtn.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(UDDriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                
                UberHandler.Instance.uberAccepted(lat: Double((self.userLocation?.latitude)!), long: Double((self.userLocation?.longitude)!))
            })
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler:nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        }
        else{
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func updateDriversLocation(){
        UberHandler.Instance.updateDriverLocation(lat: (userLocation?.latitude)!, long: (userLocation?.longitude)!)
        print("update drivers location...")
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
