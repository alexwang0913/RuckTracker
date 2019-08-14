//
//  GlobalManager.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class GlobalManager {

    static let shared = GlobalManager()
    let backendURL: String
    var currentWorkout: Workout = Workout()
    var workoutSetList: [WorkoutSet] = []
    var currentWorkoutSetIndex: Int = 0
    var workoutRepIndex: Int = 1
    var workoutHistory: WorkoutHistory = WorkoutHistory()
    
    init() {
        backendURL = "http://localhost:3000/api/"
    }
    
    func convertArraytoJSONString(arrayObject: [Any]) -> String? {
        
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
            if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                return jsonString as String
            }
            
        } catch let error as NSError {
            print("Array convertIntoJSON - \(error.description)")
        }
        return nil
    }
}
