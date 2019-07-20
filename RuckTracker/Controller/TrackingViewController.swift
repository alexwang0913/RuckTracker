//
//  FirstViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/16.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrackingViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    var isTracking: Bool = false
    var startLocation = CLLocation()
    var last: CLLocation?
    var locationList: [CLLocation] = []
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var timer: Timer?
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
            locationManager.startUpdatingLocation()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    @IBAction func onClickTrackingButton(_ sender: Any) {
        if (isTracking == false) {
            let location = locationManager.location?.coordinate
            startLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
            trackingButton.setTitle("Stop Tracking", for: .normal)
            
            mapView.removeOverlays(mapView.overlays)
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.eachSecond()
            }
            distance = Measurement(value: 0, unit: UnitLength.meters)
            seconds = 0
            updateDisplay()
        } else {
            trackingButton.setTitle("Start Tracking", for: .normal)
            timer?.invalidate()
            timer = nil
        }
        isTracking = !isTracking
    }
    
    func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        labelDistance.text = "Distance: \(formattedDistance)"
        labelTime.text = "Time: \(formattedTime)"
        labelSpeed.text = "Pace:  \(formattedPace)"
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
}

// MARK: - Location Manager Delegate

extension TrackingViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}

// MARK: - Map View Delegate

extension TrackingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
}
