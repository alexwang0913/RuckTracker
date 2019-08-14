//
//  PlanViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 8/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class PlanViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var plans: [NSDictionary] = []
    let cellId = "planCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Planning"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add", style: .done, target: self, action: #selector(gotoAddPage))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func gotoAddPage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "addPlanView") as! AddPlanViewController
        self.navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPlanList()
    }
    
    func getPlanList() {
        let apiURL = GlobalManager.shared.backendURL + "plan/list"
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let params = [ "userId": userId]
        
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.value as! NSDictionary
                
                if (statusCode == 200) {
                    self.plans = responseData.object(forKey: "plans") as! [NSDictionary]
                    self.tableView.reloadData()
                } else {
                    let msg = responseData.object(forKey: "msg") as? String ?? ""
                    self.showAlert("Failed", msg)
                }
                break
            case .failure:
                self.showAlert("Failed", "Failed to connect to server")
                break
            }
        }
    }
}

extension PlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = (plans[section] as NSDictionary).value(forKey: "_id") as? String
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((plans[section] as NSDictionary).value(forKey: "workouts") as! [String] ).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let name = ((plans[indexPath.section] as NSDictionary).value(forKey: "workouts") as! [String])[indexPath.row]
        
        cell.textLabel?.text = name
        cell.textLabel?.text = "\(name)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "planDetailView") as! PlanDetailViewController
        let planId = ((plans[indexPath.section] as NSDictionary).value(forKey: "ids") as! [String])[indexPath.row]
        detailViewController.planId = planId
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
