//
//  SignupViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/17.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class SignupViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userIdTextField: RoundTextField!
    @IBOutlet weak var emailTextField: RoundTextField!
    @IBOutlet weak var passwordTextField: RoundTextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    @IBAction func signUpButtonClick(_ sender: Any) {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let userId = userIdTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        let user = User()
        user.firstName = firstName
        user.lastName = lastName
        user.userId = userId
        user.email = email
        user.password = password

        showSpinner(onView: self.view)
        let apiURL = GlobalManager.shared.backendURL + "auth/sign-up"
        Alamofire.request(apiURL, method: .post, parameters: user.toDirectory(), encoding: JSONEncoding.default).responseJSON { response in
            self.removeSpinner()
            let statusCode = response.response?.statusCode
            
            if (statusCode == 200) {
                self.showAlert("Congratulations!", "Success in register")
            } else {
                let responseData = response.result.value as! NSDictionary
                let msg: String? = responseData.object(forKey: "msg") as? String
                self.showAlert("Failed", msg ?? "")
            }
        }
    }
    
    
}

