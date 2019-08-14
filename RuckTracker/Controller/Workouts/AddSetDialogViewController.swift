//
//  AddSetDialogViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/9/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

class AddSetDialogViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var repCountTextField: UITextField!
    @IBOutlet weak var modeSwitch: UISwitch!
    
    var updateSetTableViewHandler: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.cornerRadius = 10
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addButtonClick(_ sender: Any) {
        let workoutSet = WorkoutSet()
        workoutSet.name = nameTextField.text!
        workoutSet.repCount = Int(repCountTextField.text!)!
        workoutSet.mode = modeSwitch.isOn ? 1 : 0

        WorkoutSharedController.workoutSets.append(workoutSet)
        self.dismiss(animated: false, completion: updateSetTableViewHandler as! () -> Void)
    }
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
