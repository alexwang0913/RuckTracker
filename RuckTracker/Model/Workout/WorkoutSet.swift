//
//  WorkoutSet.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/9/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class WorkoutSet {
    var name: String = ""
    var repCount: Int = 0
    var mode: Int = 1 //1: Exercise 0: Running
    var editMode: Int = 1 // 1: Edit mode, 0: view mode
    
    func toDictionary() -> NSDictionary {
        return [
            "name": name,
            "count": repCount,
            "mode": mode
        ]
    }
}
