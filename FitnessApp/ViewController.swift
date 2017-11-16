//
//  ViewController.swift
//  FitnessApp
//
//  Created by Thomas M Hall on 10/11/17.
//  Copyright © 2017 Thomas Hall. All rights reserved.
//

import UIKit
import MapKit
import HealthKit

class ViewController: UIViewController {
    private var map: MKMapView!
    @IBOutlet weak var stepInput: UITextField!
    private var healthStore: HKHealthStore?
    
    @IBAction func save(_ sender: UIButton) {
        if let text = stepInput.text, let value = Double(text), HKHealthStore.isHealthDataAvailable() {
            let workout = HKWorkout.init(activityType: HKWorkoutActivityType.walking, start: Date.init(), end: Date.init())
                healthStore?.save(workout, withCompletion: { (success, error) in
                    if (!success) {
                        print("Error occurred workout, value was \(error.debugDescription)")
                    } else {
                        self.healthStore?.add([HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, quantity: HKQuantity.init(unit: HKUnit.count(), doubleValue: value), start: Date.init(), end: Date.init())], to: workout, completion: { (success, error) in
                            if (!success) {
                                print("Error occurred, value was \(error.debugDescription)")
                            } else {
                                print("Added \(value) steps to Healthkit workout.")
                            }
                        })
                    }
                })
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        map = MKMapView()
        
        let left:CGFloat = 10
        let top:CGFloat = 90
        let width:CGFloat = view.frame.size.width-20
        let height:CGFloat = view.frame.size.height-100
        
        map.frame = CGRect(x: left, y: top, width: width, height: height)
        
        map.mapType = MKMapType.standard
        let initialLocation = CLLocationCoordinate2D(latitude: 37.336190, longitude: -121.882208)
        goToPoint(location: initialLocation)

        view.addSubview(map)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthStore = HKHealthStore()
        healthStore!.requestAuthorization(toShare: [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, HKSampleType.workoutType()], read: nil, completion: { (success, error) in
            if (!success) {
                print("Error occurred, value was \(error.debugDescription)")
            }
        })
    }
    
    func goToPoint(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        map.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

