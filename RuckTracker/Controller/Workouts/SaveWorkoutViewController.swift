//
//  SaveWorkoutViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/5.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class SaveWorkoutViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calorieBurnLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    
    //var track: Track = Track()
//    var history: WorkoutHistory = WorkoutHistoryhistory()
    var history: WorkoutHistory = WorkoutHistory()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.history = GlobalManager.shared.workoutHistory
        history.pace = FormatDisplay.pace(distance: history.distance, seconds: history.seconds)
        history.calorieBurn = FormatDisplay.calorie(distance: history.distance, seconds: history.seconds)
        
        let totalExercise = GlobalManager.shared.currentWorkout.setCount * GlobalManager.shared.workoutSetList.count
        let currentProgress = (GlobalManager.shared.workoutRepIndex - 1) * GlobalManager.shared.workoutSetList.count +  GlobalManager.shared.currentWorkoutSetIndex + 1
        history.progress = Double(100 * (Double(currentProgress) / Double(totalExercise)))
        
        distanceLabel.text = String(format: "%.2f miles", history.distance)
        timeLabel.text = FormatDisplay.time(history.seconds)
        calorieBurnLabel.text = String(format: "%.2f", history.calorieBurn)
        paceLabel.text = history.pace
        progressLabel.text = String(format: "%.1f percent", history.progress)
        
        mapView.delegate = self
        loadMap()
        
        
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        let apiURL = GlobalManager.shared.backendURL + "workout-history/add"
        let params = GlobalManager.shared.workoutHistory.toDictionary()
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON {response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                if (statusCode == 200) {
                    let alert = UIAlertController(title: "Success", message: "Success in save workout history", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                } else {
                    let msg: String? = responseData.object(forKey: "msg") as? String
                    self.showAlert("Failed", msg ?? "")
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to connect server")
                break
            }
        }
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            self.history.locationList.count > 0
            else {
                return nil
        }
        
        let latitudes = self.history.locationList.map { location -> Double in
            return location.coordinate.latitude
        }
        
        let longitudes = self.history.locationList.map { location -> Double in
            return location.coordinate.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> [MulticolorPolyline] {
        
        // 1
//        let locations = run.locations?.array as! [Location]
        let locations = history.locationList
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        // 2
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
            let end = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
            coordinates.append((start, end))
            
            //3
            let distance = end.distance(from: start)
            let time = second.timestamp.timeIntervalSince(first.timestamp as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }
        
        //4
        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        //5
        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(speed: speed,
                                         midSpeed: midSpeed,
                                         slowestSpeed: minSpeed,
                                         fastestSpeed: maxSpeed)
            segments.append(segment)
        }
        return segments
    }
    
    private func loadMap() {
        guard
            self.history.locationList.count > 0,
            let region = mapRegion()
            else {
                let alert = UIAlertController(title: "Error",
                                              message: "Sorry, this run has no locations saved",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polyLine())
    }
    
    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
        enum BaseColors {
            static let r_red: CGFloat = 1
            static let r_green: CGFloat = 20 / 255
            static let r_blue: CGFloat = 44 / 255
            
            static let y_red: CGFloat = 1
            static let y_green: CGFloat = 215 / 255
            static let y_blue: CGFloat = 0
            
            static let g_red: CGFloat = 0
            static let g_green: CGFloat = 146 / 255
            static let g_blue: CGFloat = 78 / 255
        }
        
        let red, green, blue: CGFloat
        
        if speed < midSpeed {
            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
            red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
            green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
            blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
        } else {
            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
            red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
            green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
            blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
}

extension SaveWorkoutViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
}
