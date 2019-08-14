//
//  ForgotPasswordViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/31.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtnClick(_ sender: Any) {
        let apiURL = GlobalManager.shared.backendURL + "auth/forgot-password"
        let email = emailTextField.text ?? ""
        showSpinner(onView: self.view)
        Alamofire.request(apiURL, method: .post, parameters: ["email": email], encoding: JSONEncoding.default).responseJSON { response in
            self.removeSpinner()
            print(response)
            let statusCode = response.response?.statusCode
            if (statusCode == 200) {
                self.showAlert("Success", "Password reset message sent to your email.\n Please check your inbox.")
            } else {
                let responseData = response.result.value as! NSDictionary
                let msg: String? = responseData.object(forKey: "msg") as? String
                self.showAlert("Failed", msg ?? "")
            }
        }
    }
}
