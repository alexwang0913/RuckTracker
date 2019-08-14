//
//  WorkoutDetailViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/2.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class WorkoutDetailViewController: UIViewController {
    
    @IBOutlet weak var setTableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    
//    var workoutId: String = ""
    var workout: NSDictionary? = nil
    var setList: [WorkoutSet] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getWorkoutDetail()
        
        setTableView.dataSource = self
        setTableView.delegate = self
        
        let nibName = UINib(nibName: "WorkoutSetTableViewCell", bundle: nil)
        setTableView.register(nibName, forCellReuseIdentifier: "workoutSetCell")
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "edit", style: .done, target: self, action: #selector(gotoEditPage))
    }
    
    private func initData() {
        let name = workout?.object(forKey: "name") as? String
        self.title = name
        descriptionLabel.text = workout?.object(forKey: "description") as? String
        let setCount = workout?.object(forKey: "setCount") as! Int
        setCountLabel.text = "\(setCount)"
        
        let sets = workout?.object(forKey: "setList") as! [Any]
        for item in sets {
            let set = item as! NSDictionary
            let workoutSet = WorkoutSet()
            workoutSet.name = set.object(forKey: "name") as! String
            workoutSet.repCount = set.object(forKey: "count") as! Int
            workoutSet.mode = set.object(forKey: "mode") as! Int
            workoutSet.editMode = 0
            setList.append(workoutSet)
        }
        
//        self.setTableView.beginUpdates()
//        let indexPaths = (0..<(sets.count)).map { IndexPath(row: $0, section: 0) }
//        self.setTableView.insertRows(at: indexPaths, with: .automatic)
//        self.setTableView.endUpdates()
        self.setTableView.reloadData()
        
        GlobalManager.shared.workoutSetList = setList
    }
    
    
    @IBAction func startWorkoutButtonClick(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        GlobalManager.shared.currentWorkoutSetIndex = 0
        
        GlobalTimer.sharedTimer.startTimer()
        GlobalManager.shared.workoutHistory = WorkoutHistory()
        
        if (setList[0].mode == 1) { // Exercise
            let workoutSetViewController = storyBoard.instantiateViewController(withIdentifier: "workoutSetView") as! WorkoutSetViewController
            self.navigationController?.pushViewController(workoutSetViewController, animated: true)
        } else { // Running
            let trackViewController = storyBoard.instantiateViewController(withIdentifier: "trackView") as! TrackViewController
            self.navigationController?.pushViewController(trackViewController, animated: true)
        }
    }
    
    @objc func gotoEditPage() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let editViewController = storyboard?.instantiateViewController(identifier: "workoutEditView") as! WorkoutEditViewController
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
}

// MARK: - API functions
extension WorkoutDetailViewController {
    func getWorkoutDetail() {
        let apiURL = GlobalManager.shared.backendURL + "workout/\(GlobalManager.shared.currentWorkout.id)"
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    self.workout = responseData.object(forKey: "workout") as? NSDictionary
                    self.initData()
                } else {
                    let msg: String? = responseData.object(forKey: "msg") as? String
                    self.showAlert("Failed", msg ?? "")
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to get data from server")
                break
            }
        }
    }
}

// MARK: - UITableView extension
extension WorkoutDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setItem = setList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutSetCell", for: indexPath) as! WorkoutSetTableViewCell
        cell.commonInit(setItem)
        return cell
    }    
}
