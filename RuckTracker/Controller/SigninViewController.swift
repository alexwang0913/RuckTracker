//
//  SigninViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/16.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn
import FirebaseAuth

class SigninViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextField: RoundTextField!
    @IBOutlet weak var passwordTextField: RoundTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    

    @IBAction func signInButtonClick(_ sender: Any) {
        let apiURL = GlobalManager.shared.backendURL + "auth/login"
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        showSpinner(onView: self.view)
        Alamofire.request(apiURL, method: .post, parameters: ["email": email, "password": password], encoding: JSONEncoding.default).responseJSON { response in
            self.removeSpinner()
            switch response.result {
            case .success:
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let tabViewController = storyBoard.instantiateViewController(withIdentifier: "tabView") as! TabViewController
                tabViewController.modalPresentationStyle = .overFullScreen
                self.present(tabViewController, animated:true, completion:nil)
                break
            case .failure:
                self.showAlert("Warning", "Incorrect email or password.")
                break
            }
        }
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        print(credential)
    }

    @IBAction func googleSignInButtonClick(_ sender: Any) {
//        GIDSignIn.sharedInstance().signIn()
        
    }
}
