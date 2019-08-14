//
//  User.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class User {
    var firstName: String = ""
    var lastName: String = ""
    var userId: String = ""
    var email: String = ""
    var password: String = ""
    var age: Int = 0
    var height: Float = 0
    var weight: Float = 0
    var id: String = ""
    
    func toDirectory() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "userId": userId,
            "email": email,
            "password": password,
            "age": age,
            "height": height,
            "weight": weight,
            "id": id
        ]
    }
}
