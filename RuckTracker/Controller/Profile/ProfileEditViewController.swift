//
//  ProfileEditViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class ProfileEditViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    var user: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        userIdTextField.text = user.userId
        ageTextField.text = "\(user.age)"
        heightTextField.text = "\(user.height)"
        weightTextField.text = "\(user.weight)"
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        user.firstName = firstNameTextField.text ?? ""
        user.lastName = lastNameTextField.text ?? ""
        user.userId = userIdTextField.text ?? ""
        user.age = Int(ageTextField.text!) ?? 0
        user.height = Float(heightTextField.text!) ?? 0
        user.weight = Float(weightTextField.text!) ?? 0
        
        let apiURL = GlobalManager.shared.backendURL + "users/update"
        let params = user.toDirectory()
        
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                if (statusCode == 200) {
                    self.showAlert("Success", "Success in update profile")
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
