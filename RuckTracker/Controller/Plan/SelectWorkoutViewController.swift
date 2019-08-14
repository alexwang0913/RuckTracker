//
//  SelectWorkoutViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class SelectWorkoutViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "workoutCell"
    
    var workouts: [Workout] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        getWorkoutList()
    }
    
    func getWorkoutList() {
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let apiURL = GlobalManager.shared.backendURL + "workout/list/\(userId)"
        
        Alamofire.request(apiURL,method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                if (statusCode == 200) {
                    let workouts = responseData.object(forKey: "workouts") as! [Any]
                    for item in workouts {
                        let workout = item as! NSDictionary
                        let name = workout.object(forKey: "name") as! String
                        let id = workout.object(forKey: "_id") as! String
                        let isShared = workout.object(forKey: "isShared") as! Bool
                        
                        let workoutModel = Workout()
                        workoutModel.name = name
                        workoutModel.id = id
                        workoutModel.isShared = isShared
                        self.workouts.append(workoutModel)
                    }
                    
                    self.tableView.reloadData()                    
                } else {
                    let msg: String? = responseData.object(forKey: "msg") as? String
                    self.showAlert("Failed", msg ?? "")
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to get workouts list")
                break
            }
        }
    }

}

extension SelectWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let workout = workouts[indexPath.row]
        
        cell.textLabel?.text = workout.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workout = workouts[indexPath.row]
        GlobalManager.shared.currentWorkout = workout
        navigationController?.popViewController(animated: true)
    }
}
