//
//  RoundTextField.swift
//  RuckTracker
//
//  Created by Guangyuan Xu on 2019/7/19.
//  Copyright © 2019 Guang. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextField: UITextField {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
