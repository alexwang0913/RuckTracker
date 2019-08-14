//
//  AddPlanViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class AddPlanViewController: UIViewController {

    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        workoutLabel.text = GlobalManager.shared.currentWorkout.name
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        let apiURL = GlobalManager.shared.backendURL + "plan/add"
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let params = [
            "workout": GlobalManager.shared.currentWorkout.id,
            "planDate": "\(datePicker.date)",
            "user": userId
            ] as [String : Any]
        
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    let alert = UIAlertController(title: "Success", message: "Success in add plan", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
                        GlobalManager.shared.currentWorkout = Workout()
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                } else {
                    let msg: String? = responseData.object(forKey: "msg") as? String
                    self.showAlert("Failed", msg ?? "")
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to connect to server")
                break
            }
        }
    }

}
