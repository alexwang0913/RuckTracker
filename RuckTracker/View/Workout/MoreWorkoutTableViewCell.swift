//
//  MoreWorkoutTableViewCell.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/8/2.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

class MoreWorkoutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    
    var data: Workout = Workout()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(_ moreWorkoutItem: Workout) {
        self.data = moreWorkoutItem
        titleLabel.text = data.name
        
        creatorLabel.sizeToFit()
        creatorLabel.text = data.creator
        
        createDateLabel.sizeToFit()
        createDateLabel.text = data.createDate
    }
}
