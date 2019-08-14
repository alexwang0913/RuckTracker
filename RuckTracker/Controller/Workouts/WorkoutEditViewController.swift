//
//  WorkoutEditViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/8/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class WorkoutEditViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var workoutId: String = ""
    var setList: [WorkoutSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getWorkoutDetail()
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = CGColor(srgbRed: 204.0/255.0, green: 204/255, blue: 204/255, alpha: 1)
        descriptionTextView.layer.borderWidth = 1.0;
        descriptionTextView.layer.cornerRadius = 5.0;
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: "WorkoutSetTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "workoutSetCell")
    }
    
    func getWorkoutDetail() {
        let apiURL = GlobalManager.shared.backendURL + "workout/\(self.workoutId)"
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    let workout = responseData.object(forKey: "workout") as? NSDictionary
                    
                    self.nameTextField.text = workout?.object(forKey: "name") as! String
                    self.descriptionTextView.text = workout?.object(forKey: "description") as! String
                    
                    let sets = workout?.object(forKey: "setList") as! [NSDictionary]
                    for item in sets {
                        
                        //self.setList.append(SetTableItem(item.object(forKey: "name") as! String, item.object(forKey: "count") as! Int, 1))
                    }
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Description"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
}

// MARK: - UITableview extension
extension WorkoutEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setItem = setList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutSetCell", for: indexPath) as! WorkoutSetTableViewCell
        cell.commonInit(setItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            setList.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

