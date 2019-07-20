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
    @IBOutlet weak var ageTextField: RoundTextField!
    @IBOutlet weak var weightTextField: RoundTextField!
    @IBOutlet weak var zipCodeTextField: RoundTextField!
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
        let age = Int(ageTextField.text ?? "0") ?? 0
        let weight = Int(weightTextField.text ?? "0") ?? 0
        let zipCode = zipCodeTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        let user = User(firstName: firstName, lastName: lastName, userId: userId, age: age, weight: weight, zipCode: zipCode, email: email, password: password)

        showSpinner(onView: self.view)
        let apiURL = GlobalManager.shared.backendURL + "Users"
        Alamofire.request(apiURL, method: .post, parameters: user.toDirectory(), encoding: JSONEncoding.default).responseJSON { response in
            self.removeSpinner()
            switch response.result {
            case .success:
                self.showAlert("Congratulations!", "Success in register")
                break
            case .failure:
                self.showAlert("Failed", "Failed in register")
                break
            }
        }
    }
    
    
}

var vSpinner: UIView?
extension UIViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
