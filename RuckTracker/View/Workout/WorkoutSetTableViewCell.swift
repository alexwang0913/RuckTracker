//
//  WorkoutSetTableViewCell.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/1.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

class WorkoutSetTableViewCell: UITableViewCell {

    @IBOutlet weak var setName: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var workoutTypeLabel: UILabel!
    
    var data = WorkoutSet()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func commonInit(_ setItem: WorkoutSet) {
        self.data = setItem
        setName.text = data.name
        countLabel.text = "\(data.repCount)"
        if setItem.editMode == 0 {
            minusButton.isHidden = true
            plusButton.isHidden = true
        }
        
        workoutTypeLabel.text = setItem.mode == 1 ? "Exercise" : "Running"        
    }
    
    @IBAction func addCount(_ sender: Any) {
        data.repCount += 1
        countLabel.text = "\(data.repCount)"
    }
    
    
    @IBAction func removeCount(_ sender: Any) {
        if (data.repCount > 0) {
            data.repCount -= 1
            countLabel.text = "\(data.repCount)"
        }
    }
}
