//
//  HistoryDetailViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/6.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

class HistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var percentLabel: UILabel!
    
    var historyId: String = ""
    var locationList: [CLLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        getHistoryDetail()
        mapView.delegate = self
    }
    
    func getHistoryDetail() {
        let apiURL = GlobalManager.shared.backendURL + "workout-history/\(historyId)"
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    let history = responseData.object(forKey: "history") as! NSDictionary
                    
                    let distance = history.object(forKey: "distance") as! Double
                    let seconds = history.object(forKey: "seconds") as! Int
                    let calorieBurn = history.object(forKey: "calorieBurn") as! Double
                    let pace = history.object(forKey: "pace") as! String
                    let routes = history.object(forKey: "routes") as! String
                    let progress = history.object(forKey: "progress") as! Double
                    let workoutName = (history.object(forKey: "workoutId") as! NSDictionary).object(forKey: "name") as! String
                    self.title = workoutName
                    
                    self.distanceLabel.text = String(format: "%.2f miles", distance)
                    self.timeLabel.text = FormatDisplay.time(seconds)
                    self.calorieLabel.text = String(format: "%.2f", calorieBurn)
                    self.paceLabel.text = pace
                    self.percentLabel.text = String(format: "%.2f percent", progress)
                    
                    if let data = routes.data(using: .utf8),
                        let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[Double]] {
                        let locationArray  = jsonArray.map{CLLocation(latitude:$0[0], longitude:$0[1]) }
                        print(locationArray)
                        self.locationList = locationArray
                    }
                    self.loadMap()
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
    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            self.locationList.count > 0
            else {
                return nil
        }
        
        let latitudes = self.locationList.map { location -> Double in
            return location.coordinate.latitude
        }
        
        let longitudes = self.locationList.map { location -> Double in
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
        let locations = self.locationList
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
            self.locationList.count > 0,
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

extension HistoryDetailViewController: MKMapViewDelegate {
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
