//
//  User.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class User {
    var firstName: String
    var lastName: String
    var userId: String
    var age: Int
    var weight: Int
    var zipCode: String
    var email: String
    var password: String
    
    init(firstName: String, lastName: String, userId: String, age: Int, weight: Int, zipCode: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userId = userId
        self.age = age
        self.weight = weight
        self.zipCode = zipCode
        self.email = email
        self.password = password
    }
    
    func toDirectory() -> [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "userId": userId,
            "age": age,
            "weight": weight,
            "zipCode": zipCode,
            "email": email,
            "password": password
        ]
    }
    
    func toJSONString() -> String {
        let dictionary: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "userId": userId,
            "age": age,
            "weight": weight,
            "zipCode": zipCode,
            "email": email
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString ?? ""
    }
}
