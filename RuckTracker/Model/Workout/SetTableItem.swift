//
//  SetTableItem.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/1.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class SetTableItem {
    var name: String
    var count: Int
    var mode: Int // 1: edit 0: view
    
    init(_ name: String, _ count: Int, _ mode: Int) {
        self.name = name
        self.count = count
        self.mode = mode
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "count": count
        ]
    }
}
