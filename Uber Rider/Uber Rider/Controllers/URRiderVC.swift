//
//  URRiderVC.swift
//  Uber Rider
//
//  Created by jcapasix on 16/9/17.
//  Copyright © 2017 Jordan Capa. All rights reserved.
//

import UIKit
import MapKit



class URRiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberControllerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    @IBOutlet weak var callUberBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeMessagesForRider()
        UberHandler.Instance.delegate = self
        // Do any additional setup after loading the view.
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
            
            if driverLocation != nil{
                if !canCallUber{
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Drivers Location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Rider Location"
            myMap.addAnnotation(annotation)
        }
    }
    
    // MARK: - UberControllerDelegate
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled{
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        }
        else{
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest{
            if requestAccepted{
                Utils.sharedInstance.showAlert(title: "Uber Accepted", message: "\(driverName) Accepted Your Uber Request", view: self)
            }
            else{
                UberHandler.Instance.cancelUber();
                timer.invalidate()
                Utils.sharedInstance.showAlert(title: "Uber Canceled", message: "\(driverName) Canceled Uber Request", view: self)
            }
        }
        riderCanceledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    // MARK: - My Methods

    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut(){
            if !canCallUber{
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
        }
        else{
            Utils.sharedInstance.showAlert(title: "Could Not Logout", message: "We could not logout at the moment, please tru again later.", view: self)
        }
    }
    
    @IBAction func callUber(_ sender: Any) {
        if userLocation != nil {
            if canCallUber{
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(URRiderVC.updateRidersLocation), userInfo: nil, repeats: true)
                
                UberHandler.Instance.requestUber(latitude: (userLocation?.latitude)!, longitude: (userLocation?.longitude)!)
            }
            else{
                riderCanceledRequest =  true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            
        }
    }
    
    @objc func updateRidersLocation(){
        UberHandler.Instance.updateRiderLocation(lat: (userLocation?.latitude)!, long: (userLocation?.longitude)!)
        print("update Riders location...")
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
