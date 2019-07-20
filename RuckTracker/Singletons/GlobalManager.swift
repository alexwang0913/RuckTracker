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
    
    init() {
        backendURL = "http://localhost:3000/api/"
    }
}
