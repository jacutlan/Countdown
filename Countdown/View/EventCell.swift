//
//  EventCell.swift
//  Countdown
//
//  Created by Josh Cutlan on 12/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit
import SwipeCellKit

class EventCell: SwipeTableViewCell {
    

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayCountLabel: UILabel!    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
