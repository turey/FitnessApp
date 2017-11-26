//
//  Database.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import Foundation
import Foundation
import CoreLocation
import CoreMotion



class LocationData: NSObject, NSCoding{
    var time : Int32!
    var longitude: Double!
    var latitude: Double!
    
    convenience init(longitude: Double, latitude: Double){
        self.init()
        self.longitude = longitude
        self.latitude = latitude
    }
    convenience required init(coder decoder: NSCoder) {
        self.init()
        self.time = decoder.decodeInt32(forKey: "id")
        self.longitude = decoder.decodeDouble(forKey: "longitude")
        self.latitude = decoder.decodeDouble(forKey: "latitude")
    }
    
    func encode(with coder: NSCoder){
        if self.time != nil{
            coder.encode(Int32(self.time), forKey: "id")
        }
        
        if self.longitude != nil{
            coder.encode(Double(self.longitude), forKey: "longitude")
        }
        
        if self.latitude != nil{
            coder.encode(Double(self.latitude), forKey: "latitude")
        }
    }
    
    static func createLocation(longitude: Double, latitude: Double)->LocationData{
        var location = LocationData(longitude: longitude, latitude: latitude)
        location.time = Int32(Date().timeIntervalSince1970)
        return location
    }
    
}


class Activity: NSObject, NSCoding{
    var Id: String!
    var StepsWalked: Int32!
    var Path  = [LocationData]()
    var StartTime: Int32!
    var EndTime: Int32!
    
    var startDate : Date {
        get{
            return Date(timeIntervalSince1970: Double(self.StartTime))
        }
    }
    
    var endDate: Date{
        get{
            return Date(timeIntervalSince1970: Double(self.EndTime))
        }
    }
    
    
    
    var difference : Int{
        get{
            var difference: Int!
            if(self.EndTime == nil){
                difference = Int(Date().timeIntervalSince(self.startDate))
            }else if(self.EndTime != nil && self.StartTime != nil){
                difference = Int(endDate.timeIntervalSince(self.startDate))
            }
            return difference
        }
    }
    
    var duration: String {
        get{
            return difference.timerString()
        }
    }
    
    
    
    private var lastLocation: CLLocation!
    
    
    override init() {
        super.init()
        
    }
    
    convenience required init(coder decoder: NSCoder) {
        self.init()
        self.Id = decoder.decodeObject(forKey: "activity-id") as! String
        self.StepsWalked = decoder.decodeInt32(forKey: "steps-walked")
        self.Path = decoder.decodeObject(forKey: "path-data") as! [LocationData]
        self.StartTime = decoder.decodeInt32(forKey: "start-time")
        self.EndTime = decoder.decodeInt32(forKey: "end-time")
        
    }
    
    func encode(with coder: NSCoder){
        if self.StepsWalked != nil{
            coder.encode(Int32(self.StepsWalked), forKey: "steps-walked")
        }
        
        if self.Path != nil{
            coder.encode(self.Path, forKey: "path-data")
        }
        
        if self.StartTime != nil{
            coder.encode(Int32(self.StartTime), forKey: "start-time")
        }
        
        if self.EndTime != nil{
            coder.encode(Int32(self.EndTime), forKey: "end-time")
        }
        
        if self.Id != nil{
            coder.encode(String(self.Id), forKey: "activity-id")
        }
    }
    
    
    
    static func createActivity()->Activity{
        var activity = Activity()
        let date = Date()
        activity.Id = UUID().uuidString
        activity.StartTime = Int32(date.timeIntervalSince1970)
        return activity
    }
    
    func processLocation(location: CLLocation){
        if(self.lastLocation == nil){
            self.lastLocation = location
            self.Path.append((LocationData.createLocation(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)))
            return
        }
        
        if(self.lastLocation.distance(from: location) > 10){
            self.Path.append(LocationData.createLocation(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
            return
        }
    }
    
    func endActivity(pedometerManager: CMPedometer){
        self.EndTime = Int32(Date().timeIntervalSince1970)
        if(CMPedometer.isStepCountingAvailable()){
            pedometerManager.queryPedometerData(from: self.startDate, to: self.endDate, withHandler: { (data, error) in
                if(error == nil){
                    if let data = data{
                        self.StepsWalked = Int32(data.numberOfSteps)
                    }else{
                        self.StepsWalked = 0
                    }
                }else{
                    self.StepsWalked = 0
                }
            })
        }
    }
}

class User: NSObject, NSCoding{
    var UserID: String!
    var activities =  [Activity]()
    var currentActivity : Activity!
    var goal: Int = 8000
    var goalProgress: Int = 0
    static var currentUser : User!
    
    convenience required init(coder decoder: NSCoder) {
        self.init()
        self.activities = decoder.decodeObject(forKey: "user-activities") as! [Activity]
        self.goal = decoder.decodeInteger(forKey: "user-goal")
        self.goalProgress = decoder.decodeInteger(forKey: "user-goal-progress")
        self.UserID = decoder.decodeObject(forKey: "user-id") as! String
    }
    
    func encode(with coder: NSCoder){
        coder.encode(self.activities, forKey: "user-activities")
        coder.encode(self.goal, forKey: "user-goal")
        coder.encode(self.goalProgress, forKey: "user-goal-progress")
        if self.UserID != nil{
            coder.encode(self.UserID, forKey: "user-id")
        }
    }
}

extension User{
    static func createUser(userId: String, completion: @escaping (User?)->()){
        let user = User()
        user.UserID = userId
        User.save(user: user) { (user) in
            completion(user)
        }
    }
    
    static func save(user: User, completion: @escaping (User?)->()){
        let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(encodedUser, forKey: user.UserID)
        User.currentUser = user
        completion(user)
    }
    
    static func getUser(userId: String, completion: @escaping (User?)->()){
        let encodedData = UserDefaults.standard.data(forKey: userId)
        if let encodedData = encodedData{
            let decodedUser = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? User
            if let user = decodedUser{
                User.currentUser = user
            }
            completion(decodedUser)
        }else{
            completion(nil)
        }
    }
}


extension Int{
    func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    func timerString()->String{
        let (h,m,s) = self.secondsToHoursMinutesSeconds()
        let hStr = h < 10 ? "0\(h)" : "\(h)"
        let mStr = m < 10 ? "0\(m)" : "\(m)"
        let sStr = s < 10 ? "0\(s)" : "\(s)"
        return hStr+":"+mStr+":"+sStr
    }
}

extension Int32{
    func secondsToHoursMinutesSeconds () -> (Int32, Int32, Int32) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    func timerString()->String{
        return Int(self).timerString()
    }
}

extension Date {
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@ ago", comment: "")
        return String(format: formatString, timeString)
    }
}
