//
//  ProfileDetailViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    var user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "edit", style: .done, target: self, action: #selector(gotoEditPage))
    }
    
    func getProfile() {
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let apiURL = GlobalManager.shared.backendURL + "users/\(userId)"
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    let user = responseData.object(forKey: "user") as! NSDictionary
                    let firstName = user.object(forKey: "firstName") as! String
                    let lastName = user.object(forKey: "lastName") as! String
                    let userId = user.object(forKey: "userId") as! String
                    let age = user.object(forKey: "age") == nil ? 0 : user.object(forKey: "age") as! Int
                    let height = user.object(forKey: "height") == nil ? 0 : user.object(forKey: "height") as! Float
                    let weight = user.object(forKey: "weight") == nil ? 0 : user.object(forKey: "weight") as! Float
                    
                    self.firstNameLabel.text = firstName
                    self.lastNameLabel.text = lastName
                    self.userIdLabel.text = userId
                    self.ageLabel.text = "\(age)"
                    self.heightLabel.text = "\(height) cm"
                    self.weightLabel.text = "\(weight) kg"
                    
                    self.user.firstName = firstName
                    self.user.lastName = lastName
                    self.user.userId = userId
                    self.user.age = age
                    self.user.height = height
                    self.user.weight = weight
                    
                    self.user.id = user.object(forKey: "_id") as! String
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
    

    @objc func gotoEditPage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let editViewController = storyBoard.instantiateViewController(withIdentifier: "profileEditView") as! ProfileEditViewController
        editViewController.user = user
        self.navigationController?.pushViewController(editViewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        getProfile()
    }
}
