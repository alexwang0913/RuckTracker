//
//  HistoryViewController.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/6.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let cellId = "historyCell"
    
    var historyList: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        getHistory()
        
        self.title = "History"
    }
    
    func getHistory() {
        let userId = UserDefaults.standard.object(forKey: "UserID") as! String
        let apiURL = GlobalManager.shared.backendURL + "workout-history/list/\(userId)"
        Alamofire.request(apiURL, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON {response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                let responseData = response.result.value as! NSDictionary
                
                if (statusCode == 200) {
                    self.historyList = responseData.object(forKey: "history") as! [NSDictionary]
                    self.tableView.reloadData()
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
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = (historyList[section] as NSDictionary).value(forKey: "_id") as? String
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((historyList[section] as NSDictionary).value(forKey: "workouts") as! [String] ).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let name = ((historyList[indexPath.section] as NSDictionary).value(forKey: "workouts") as! [String])[indexPath.row]
        
        cell.textLabel?.text = name
        cell.textLabel?.text = "\(name)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "HistoryDetailViewController") as! HistoryDetailViewController
        let historyId = ((historyList[indexPath.section] as NSDictionary).value(forKey: "ids") as! [String])[indexPath.row]
        detailViewController.historyId = historyId
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

