//
//  AddWorkoutViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/31.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class AddWorkoutViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var setsTableView: UITableView!
    @IBOutlet weak var setCountTextField: UITextField!
    
    
    var setList: [WorkoutSet] = []
    
    var addSetTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add workout"
        
        initStyle()
        
        setsTableView.dataSource = self
        setsTableView.delegate = self
        
        let nibName = UINib(nibName: "WorkoutSetTableViewCell", bundle: nil)
        setsTableView.register(nibName, forCellReuseIdentifier: "workoutSetCell")
    }
    
    
    
    private func initStyle() {
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = CGColor(srgbRed: 204.0/255.0, green: 204/255, blue: 204/255, alpha: 1)
        descriptionTextView.layer.borderWidth = 1.0;
        descriptionTextView.layer.cornerRadius = 5.0;
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Description"
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func addIndividualWorkoutClick(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let addSetViewController = storyBoard.instantiateViewController(withIdentifier: "addIndividualWorkout") as! AddSetDialogViewController
        addSetViewController.modalPresentationStyle = .overFullScreen
        addSetViewController.updateSetTableViewHandler = updateWorkoutSetTable
        
        self.present(addSetViewController, animated:true, completion:nil)
    }
    
    func addSetTextField(textField: UITextField!) {
        addSetTextField = textField
        addSetTextField?.placeholder = "Input workout set"
    }
    
    @IBAction func saveWorkout(_ sender: Any) {
        
        let apiURL = GlobalManager.shared.backendURL + "workout/add"

        let name = nameTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let setCount = Int(setCountTextField.text ?? "0")

        var setListStringArray: Array<Any> = []
        for setItem in setList {
            setListStringArray.append(setItem.toDictionary())
        }

        let setListString = GlobalManager.shared.convertArraytoJSONString(arrayObject: setListStringArray) ?? ""

        let params = [
            "name": name,
            "description": description,
            "setList": setListString,
            "userId": userId,
            "setCount": setCount
            ] as [String : Any]

        showSpinner(onView: self.view)
        Alamofire.request(apiURL, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.removeSpinner()

            let statusCode = response.response?.statusCode
            if (statusCode == 200) {
                self.navigationController?.popViewController(animated: true)
            } else {
                let responseData = response.result.value as! NSDictionary
                let msg: String? = responseData.object(forKey: "msg") as? String
                self.showAlert("Failed", msg ?? "")
            }
        }
    }
    
    func updateWorkoutSetTable() {
        self.setList = WorkoutSharedController.workoutSets
        setsTableView.reloadData()
    }
    
    func addWorkoutSetButtonClick(viewController: AddSetDialogViewController) {
        print("clicked")
    }
}

extension AddWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setItem = setList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutSetCell", for: indexPath) as! WorkoutSetTableViewCell
        cell.commonInit(setItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            setList.remove(at: indexPath.row)
            WorkoutSharedController.workoutSets.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
