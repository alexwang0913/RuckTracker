//
//  MoreWorkoutTableItem.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/2.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class MoreWorkoutTableItem {
    var title: String
    var creator: String
    var createDate: String
    var id: String
    
    init(_ title: String, _ creator: String, _ createDate: String, _ id: String) {
        self.title = title
        self.creator = creator
        self.createDate = createDate
        self.id = id
    }
}
