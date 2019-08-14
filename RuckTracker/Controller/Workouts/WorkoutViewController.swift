//
//  WorkoutViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/31.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class WorkoutViewController: UIViewController {

    @IBOutlet weak var workoutTableView: UITableView!
    
    var workoutList: [Workout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Workout"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-add"), style: .done, target: self, action:#selector(gotoAddWorkoutPage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "more", style: .done, target: self, action: #selector(gotoMorewotkoutPage))
        
        workoutTableView.dataSource = self
        workoutTableView.delegate = self
        
        let nibName = UINib(nibName: "WorkoutTableViewCell", bundle: nil)
        workoutTableView.register(nibName, forCellReuseIdentifier: "workoutCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.workoutList = []
        self.workoutTableView.reloadData()
        getWorkoutList()
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    

    @objc func gotoAddWorkoutPage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "AddWorkoutViewController") as! AddWorkoutViewController
        self.navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    @objc func gotoWorkoutDetailPage(_ index: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        GlobalManager.shared.currentWorkout = workoutList[index]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    @objc func gotoMorewotkoutPage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let moreViewController = storyBoard.instantiateViewController(withIdentifier: "MoreWorkoutViewController") as! MoreWorkoutViewController
        self.navigationController?.pushViewController(moreViewController, animated: true)
    }
}

// MARK: - UITableView extension
extension WorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let workoutItem = workoutList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutTableViewCell
        cell.commonInit(workoutItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeWorkout(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let workoutId = self.workoutList[indexPath.row].id
        let index = indexPath.row
        self.gotoWorkoutDetailPage(index)
    }
}

// MARK: - API functions
extension WorkoutViewController {
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
                        let setCount = workout.object(forKey: "setCount") as! Int
                        
                        let workoutModel = Workout()
                        workoutModel.name = name
                        workoutModel.id = id
                        workoutModel.isShared = isShared
                        workoutModel.setCount = setCount
                        self.workoutList.append(workoutModel)
                    }
                    
                    self.workoutTableView.beginUpdates()
                    let indexPaths = (0..<(workouts.count)).map { IndexPath(row: $0, section: 0) }
                    self.workoutTableView.insertRows(at: indexPaths, with: .automatic)
                    self.workoutTableView.endUpdates()
                    
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
    func removeWorkout(_ indexPath: IndexPath){
        let workoutId = workoutList[indexPath.row].id
        
        let apiURL = GlobalManager.shared.backendURL + "workout/\(workoutId)"
        
        Alamofire.request(apiURL, method: .delete, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                if (statusCode == 200) {
                    self.workoutList.remove(at: indexPath.row)
                    
                    self.workoutTableView.beginUpdates()
                    self.workoutTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.workoutTableView.endUpdates()
                }
                break
            case .failure:
                break
            }
        }
    }
}
