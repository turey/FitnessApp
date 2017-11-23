//
//  MapViewController.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
//import


class MapViewController: UIViewController {
    
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var Pedometer: UILabel!
    
    
    
    @IBAction func StatStopButtonPressed(_ sender: UIButton) {
        self.toggleButton()
    }
    
    private var startState = true
    private var pedometerAvailable = false
    private var isLockedOnUser: Bool = false
    private var manager = CLLocationManager()
    private var pedometerManger = CMPedometer()
    private var PermissionTimer: Timer!
    private var TimerLabelUpdateTimer: Timer! // timer to update timer label. duration string is generated in current activity object
    private var PermissionAC : UIAlertController!
    
    
    
    
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MapViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        
        
        
        createPermissionAC()
        PermissionTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MapViewController.checkLocationPermissionStatus), userInfo: nil, repeats: true)
        
        StartButton.layer.cornerRadius = StartButton.frame.width/2
        TimerLabel.layer.cornerRadius = 5
        Pedometer.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: .main) { [weak self] (notification) in
            self?.checkLocationPermissionStatus()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupPedometer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        
        if(location.horizontalAccuracy > 15){
            return
        }
        
        if(!isLockedOnUser){
            isLockedOnUser = true;
            zoomToUser(location: location)
        }
        
        DispatchQueue.global().async {
            self.activity_processLocation(location: location)
        }
        
    }
}


// pedometer functions
extension MapViewController{
    func setupPedometer(){
        if CMPedometer.isStepCountingAvailable(){
            self.pedometerAvailable = true;
        }
    }
    //    func recrodStepsForCurrentActivity()
    
}




// mapview functions
extension MapViewController{
    private func zoomToUser(location: CLLocation){
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        MapView.setRegion(region, animated: true)
        MapView.showsUserLocation = true
    }
    
    @objc private func checkLocationPermissionStatus(){
        
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .authorizedAlways, .authorizedWhenInUse:
                if(PermissionAC.isFirstResponder){
                    PermissionAC.dismiss(animated: true, completion: nil)
                }
                manager.startUpdatingLocation()
                PermissionTimer.invalidate()
                break;
            case .denied, .restricted:
                if(self.PermissionAC.isFirstResponder){
                    return
                }else{
                    self.present(self.PermissionAC, animated: true, completion: {
                    })
                }
                break
            case .notDetermined:
                break
            }
        }
    }
}


// Outlet functions
extension MapViewController{
    @objc func timerLabelUpdate(){
        if let duration = User.currentUser.currentActivity?.duration{
            self.TimerLabel.text = duration
        }
        if(CMPedometer.isStepCountingAvailable()){
            self.pedometerManger.queryPedometerData(from: User.currentUser.currentActivity.startDate, to: Date(), withHandler: { (data, error) in
                if(error == nil){
                    if let data = data{
                        self.Pedometer.text = String(describing: data.numberOfSteps)
                    }
                }
            })
        }
    }
    
    @objc func LabelTimerStart(){
        if(self.TimerLabelUpdateTimer == nil){
            self.TimerLabelUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapViewController.timerLabelUpdate), userInfo: nil, repeats: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.TimerLabel.alpha = 1
                if(CMPedometer.isStepCountingAvailable()){
                    self.Pedometer.alpha = 1
                }
            })
        }
    }
    
    func LabelTimerStop(){
        if(self.TimerLabelUpdateTimer != nil){
            self.TimerLabelUpdateTimer.invalidate()
            self.TimerLabelUpdateTimer = nil
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+2, execute: {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.TimerLabel.alpha = 0
                        self.Pedometer.alpha = 0
                    })
                }
            })
        }
    }
    
    func toggleButton(){
        if(startState){
            startState = false
            
            User.currentUser.currentActivity = Activity.createActivity()
            if let location = self.manager.location{
                self.activity_processLocation(location: location)
            }else{
                self.manager.requestLocation()
            }
            
            self.LabelTimerStart()
        }else{
            if let activity = User.currentUser.currentActivity{
                activity.endActivity(pedometerManager: self.pedometerManger)
                if(activity.difference < 10){
                    let alertController = UIAlertController(title: "Didn't Save", message: "Activity too short", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (alert) in }))
                    self.present(alertController, animated: true, completion: {
                        
                    })
                }else{
                    User.currentUser.activities.append(activity)
                }
            }
            User.save(user: User.currentUser, completion: { (user) in
                
            })
            self.LabelTimerStop()
            User.currentUser.currentActivity = nil;
            startState = true
        }
        self.toggleButtonUI()
    }
    
    func toggleButtonUI(){
        if(startState){
            self.StartButton.backgroundColor = UIColor.green
            self.StartButton.setTitle("Start", for: .normal)
        }else{
            self.StartButton.backgroundColor = UIColor.red
            self.StartButton.setTitle("Stop", for: .normal)
        }
        
    }
    
    func activity_processLocation(location: CLLocation){
        if(User.currentUser.currentActivity == nil){
            return
        }else{
            User.currentUser.currentActivity.processLocation(location: location)
        }
    }
    
}

//helper functions
extension MapViewController{
    func openPhoneSettings(){
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {return}
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
    
    func createPermissionAC(){
        PermissionAC = UIAlertController(title: "Location Services", message: "Please Enable Location Services in Settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) in
            self.openPhoneSettings();
        })
        PermissionAC.addAction(settingsAction)
    }
    
}



