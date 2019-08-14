//
//  GlobalTimer.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/12/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation

class GlobalTimer: NSObject {
    
    static let sharedTimer: GlobalTimer = GlobalTimer()
    var internalTimer: Timer?
//    var seconds: Int = 0
    
    func startTimer(){
//        guard self.internalTimer != nil else {
//            fatalError("Timer already intialized, how did we get here with a singleton?!")
//        }
        self.internalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        guard self.internalTimer != nil else {
            fatalError("No timer active, start the timer before you stop it.")
        }
        self.internalTimer?.invalidate()
    }
    
    @objc func fireTimerAction(sender: AnyObject?){
//        self.seconds += 1
        GlobalManager.shared.workoutHistory.seconds += 1
    }
    
}
