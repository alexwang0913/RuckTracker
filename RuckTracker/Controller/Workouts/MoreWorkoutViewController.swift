//
//  MoreWorkoutViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/2.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class MoreWorkoutViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var moreWorkoutList: [Workout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Look for more workouts"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: "MoreWorkoutTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "moreWorkoutTableViewCell")
        
        getMoreWorkouts()
    }
    
    @objc func gotoWorkoutDetailPage(_ index: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
//        detailViewController.workoutId = id
        GlobalManager.shared.currentWorkout = self.moreWorkoutList[index]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - API functions
extension MoreWorkoutViewController {
    func getMoreWorkouts() {
        let myId = UserDefaults.standard.object(forKey: "UserID") as! String
        let apiURL = GlobalManager.shared.backendURL + "workout/more"
        let params = ["myId": myId]
        
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON {response in
            switch response.result {
            case .success:
                
                let responseData = response.result.value as! NSDictionary
                
                if response.response?.statusCode == 200 {
                    let workouts = responseData.object(forKey: "workouts") as! [Any]
                    for item in workouts {
                        let workout = item as! NSDictionary
                        let title = workout.object(forKey: "title") as! String
                        let creator = workout.object(forKey: "creator") as! String
                        let createDate = workout.object(forKey: "createDate") as! String
                        let id = workout.object(forKey: "id") as! String
                        let setCount = workout.object(forKey: "setCount") as! Int
                        
                        let workoutModel = Workout()
                        workoutModel.name = title
                        workoutModel.id = id
                        workoutModel.setCount = setCount
                        workoutModel.creator = creator
                        workoutModel.createDate = createDate
                        self.moreWorkoutList.append(workoutModel)
                    }
                    
                    self.tableView.beginUpdates()
                    let indexPaths = (0..<(workouts.count)).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to get data from server")
                break
            }
        }
    }
}

// MARK: - UITableview extension
extension MoreWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreWorkoutList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moreWorkoutItem = moreWorkoutList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreWorkoutTableViewCell", for: indexPath) as! MoreWorkoutTableViewCell
        cell.commonInit(moreWorkoutItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let workoutId = self.moreWorkoutList[indexPath.row].id
        let index = indexPath.row
        self.gotoWorkoutDetailPage(index)
    }
}
