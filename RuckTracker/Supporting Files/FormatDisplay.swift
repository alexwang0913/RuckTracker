//
//  FormatDisplay.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/16.
//  Copyright © 2019 Guang. All rights reserved.
//

import Foundation
import HealthKit

struct FormatDisplay {
    static func distance(_ distance: Double) -> Double {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return FormatDisplay.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> Double {
//        let miles = Measurement(value: distance.value, unit: UnitLength.miles)
        let miles = distance.converted(to: UnitLength.miles)
        
        return miles.value
//        let formatter = MeasurementFormatter()
//        return formatter.string(from: distance)
    }
    
    static func time(_ seconds: Int) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad
//        return formatter.string(from: TimeInterval(seconds))!
        let hour = Int(seconds / 3600)
        let min = Int((seconds - hour * 3600) / 60)
        let sec = seconds - hour * 3600 - min * 60
        
        if (hour > 0) {
            return "\(hour) hour \(min) mins \(sec) seconds"
        } else if (min > 0) {
            return "\(min) mins \(sec) seconds"
        } else {
            return "\(sec) seconds"
        }
    }
    
    static func pace(distance: Double, seconds: Int) -> String {
//        let formatter = MeasurementFormatter()
//        formatter.unitOptions = [.providedUnit] // 1
//        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
//        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
//        return formatter.string(from: speed.converted(to: outputUnit))
        
//        let min = Int(seconds / 60)
//        let sec = seconds - min * 60
//        let miles = distance.converted(to: UnitLength.miles).value
        let total = distance != 0 ? Int(Double(seconds) / Double(distance)) : 0
        let min = Int(total / 60)
        let sec = total - min * 60
        
        let pace = "\(min):\(sec)"
        return pace
    }
    
    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    static func calorie(distance: Double, seconds: Int) -> Double {
        //Calories burned per minute = (0.035 * body weight in kg) + ((Velocity in m/s ^ 2) / Height in m)) * (0.029) * (body weight in kg)
        if UserDefaults.standard.object(forKey: "Weight") == nil || UserDefaults.standard.object(forKey: "Height") == nil {
            return 0
        }
        let weight = UserDefaults.standard.object(forKey: "Weight") as! Double
        let height = UserDefaults.standard.object(forKey: "Height") as! Double
        
        let velocity: Double = distance / Double(seconds)
        let calorie: Double = (0.035 * weight) + (((velocity * velocity) / (height / 100)) * 0.029 * weight)
        
        return calorie
//        let caloriesPerHour: Double = 450
//        let hours = duration / 3600
//        let totalCalories = caloriesPerHour * Double(hours)
//        let formattedCalories = String(format: "%.2f", totalCalories)
//
//        return formattedCalories
    }
}
