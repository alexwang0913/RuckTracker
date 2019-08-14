//
//  TrackViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/2.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrackViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stopButton: RoundButton!
    @IBOutlet weak var nextButton: RoundButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var nextWorkoutLabel: UILabel!
    
    
    var locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    var locationList: [CLLocation] = []
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var startLocation = CLLocation()
    var timer: Timer?
    var seconds = 0
    var history: WorkoutHistory = WorkoutHistory()
    var startTime: Date = Date()
    var calorieBurn: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initMapView()
        initTrack()
        
        
    }
    
    private func initMapView() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
            
            mapView.removeOverlays(mapView.overlays)
            locationManager.startUpdatingLocation()
    
            mapView.delegate = self
        }
        
    }
    
    private func initTrack() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        distance = Measurement(value: 0, unit: UnitLength.meters)
        seconds = 0
        updateDisplay()
        
        startTime = Date()
        
        finishButton.isHidden = true
    }
    
    func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(GlobalManager.shared.workoutHistory.seconds)
        let formattedPace = FormatDisplay.pace(distance: distance.converted(to: UnitLength.meters).value,
                                               seconds: seconds)
        self.calorieBurn = FormatDisplay.calorie(distance: distance.value, seconds: seconds)
        
        timeLabel.text = "\(formattedTime)"
        paceLabel.text = "\(formattedPace)"
        distanceLabel.text = String(format: "%.2f miles", formattedDistance)
        calorieLabel.text = String(format: "%.2f", calorieBurn)
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    @IBAction func stopButtonClick(_ sender: Any) {
        let alertController = UIAlertController(title: "End run?",
                                                message: "Do you wish to end your run?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.stopRun()
            self.saveRun()

            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let saveViewController = storyBoard.instantiateViewController(withIdentifier: "saveWorkoutView") as! SaveWorkoutViewController
            self.navigationController?.pushViewController(saveViewController, animated: true)
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.stopRun()

            self.navigationController?.popViewController(animated: true)
        })

        present(alertController, animated: true)
    }
    
    func stopRun() {
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
    }
    
    func saveRun() {
        GlobalManager.shared.workoutHistory.distance += self.distance.converted(to: UnitLength.miles).value
//        history.calorieBurn = self.calorieBurn
//        history.seconds = self.seconds
//        history.startTime = self.startTime
//        history.endTime = Date()
        GlobalManager.shared.workoutHistory.locationList += self.locationList
//        history.pace = paceLabel.text ?? "00:00"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        self.tabBarController?.tabBar.isHidden = true
        
//        if GlobalManager.shared.currentWorkoutSetIndex == GlobalManager.shared.workoutSetList.count - 1 {
//            if GlobalManager.shared.workoutRepIndex == GlobalManager.shared.currentWorkout.setCount {
//                finishButton.isHidden = false
//                stopButton.isHidden = true
//                nextButton.isHidden = true
//            }
//        }
//
        var nextWorkoutSet = WorkoutSet()
        
        if GlobalManager.shared.currentWorkoutSetIndex == GlobalManager.shared.workoutSetList.count - 1 {
            if GlobalManager.shared.workoutRepIndex == GlobalManager.shared.currentWorkout.setCount {
                nextWorkoutLabel.text = "--"
                
                nextButton.isHidden = true
                stopButton.isHidden = true
                finishButton.isHidden = false
            } else {
                nextWorkoutSet = GlobalManager.shared.workoutSetList[0]
                nextWorkoutLabel.text = nextWorkoutSet.name
            }
        } else {
            nextWorkoutSet = GlobalManager.shared.workoutSetList[GlobalManager.shared.currentWorkoutSetIndex + 1]
            nextWorkoutLabel.text = nextWorkoutSet.name
        }
        
        let workoutRepIndex = GlobalManager.shared.workoutRepIndex
        let workoutRepCount = GlobalManager.shared.currentWorkout.setCount
        let exerciseIndex = GlobalManager.shared.currentWorkoutSetIndex + 1
        let exerciseCount = GlobalManager.shared.workoutSetList.count
        
        setLabel.text = "\(workoutRepIndex) / \(workoutRepCount)"
        exerciseLabel.text = "\(exerciseIndex) / \(exerciseCount)"
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        stopRun()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func nextButtonClick(_ sender: Any) {
        GlobalManager.shared.currentWorkoutSetIndex += 1
        GlobalManager.shared.workoutHistory.distance += distance.converted(to: .miles).value
        GlobalManager.shared.workoutHistory.locationList += self.locationList
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let workoutSetViewController = storyBoard.instantiateViewController(withIdentifier: "workoutSetView") as! WorkoutSetViewController
        self.navigationController?.pushViewController(workoutSetViewController, animated: true)
    }
    
    
    @IBAction func finishButtonClick(_ sender: Any) {
        self.stopRun()
        self.saveRun()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let saveViewController = storyBoard.instantiateViewController(withIdentifier: "saveWorkoutView") as! SaveWorkoutViewController
        self.navigationController?.pushViewController(saveViewController, animated: true)
    }
}

// MARK: - Location Manager Delegate

extension TrackViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        self.locationManager = manager
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: .meters)
                
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

extension TrackViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 3
        return renderer
    }
}
