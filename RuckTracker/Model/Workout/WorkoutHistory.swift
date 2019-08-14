//
//  WorkoutHistory.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/12/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation
import MapKit

class WorkoutHistory {
    var distance: Double = 0
    var calorieBurn: Double = 0
    var seconds: Int = 0
    var startTime: Date = Date()
    var endTime: Date = Date()
    var locationList: [CLLocation] = []
    var pace: String = "00 : 00"
    var progress: Double = 0
    
    func toDictionary() -> [String: Any] {
        var locationDoubleList: [[Double]] = []
        for location in locationList {
            locationDoubleList.append([location.coordinate.latitude, location.coordinate.longitude])
        }
        
        let strLocationList = locationDoubleList.description
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let workoutId = GlobalManager.shared.currentWorkout.id
        
        return [
            "userId": userId,
            "workoutId": workoutId,
            "distance": "\(distance)",
            "calorieBurn": "\(calorieBurn)",
            "seconds": "\(seconds)",
            "startTime": "\(startTime)",
            "endTime": "\(endTime)",
            "pace": pace,
            "routes": strLocationList,
            "progress": progress
        ]
    }
}
