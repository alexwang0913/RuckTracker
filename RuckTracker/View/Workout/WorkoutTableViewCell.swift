//
//  WorkoutTableViewCell.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/1.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit
import Alamofire

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unshareButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var data: Workout = Workout()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(_ workout: Workout) {
        self.data = workout
        nameLabel.text = data.name
        initShareButton()
    }
    
    private func initShareButton() {
        if data.isShared {
            unshareButton.isHidden = false
            shareButton.isHidden = true
        } else {
            shareButton.isHidden = false
            unshareButton.isHidden = true
        }
    }
    
    
    @IBAction func shareButtonClick(_ sender: Any) {
        shareWorkout()
    }
    
    @IBAction func unShareButtonClick(_ sender: Any) {
        shareWorkout()
    }
    
    private func shareWorkout() {
        let apiURL = GlobalManager.shared.backendURL + "workout/share"
        let params = [
            "id": data.id,
            "shareStatus": !data.isShared
            ] as [String : Any]
        Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON {response in
            switch response.result {
            case .success:
                self.data.isShared = self.data.isShared == true ? false : true
                self.initShareButton()                
                break
            case .failure:
                print("failed")
                break
            }
        }
    }
}
