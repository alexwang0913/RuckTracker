//
//  SettingsViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/7.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
    }
    
    
    @IBAction func signoutButtonClick(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "UserID")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let logoViewController = storyBoard.instantiateViewController(withIdentifier: "logoNavigationView") as! LogoNavigationViewController
        logoViewController.modalPresentationStyle = .overFullScreen
        self.present(logoViewController, animated:true, completion:nil)
    }
    
}
