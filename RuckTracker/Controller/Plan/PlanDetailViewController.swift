//
//  PlanDetailViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/8/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class PlanDetailViewController: UIViewController {
    
    @IBOutlet weak var planDateLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    
    var planId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        getPlanDetail()
    }
    
    func getPlanDetail() {
        let apiURL = GlobalManager.shared.backendURL + "plan/\(planId)"
        
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.value as? NSDictionary
                
                if (statusCode == 200) {
                    let plan = responseData?.object(forKey: "plan") as! NSDictionary
                    
                    self.planDateLabel.text = plan.object(forKey: "planDate") as! String
                    self.workoutLabel.text = (plan.object(forKey: "workout") as? NSDictionary)?.object(forKey: "name") as? String
                    self.createdAtLabel.text = plan.object(forKey: "createdAt") as? String
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to connect server")
                break
            }
        }
    }

}
