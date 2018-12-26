//
//  EventCell.swift
//  Countdown
//
//  Created by Josh Cutlan on 12/12/18.
//  Copyright © 2018 Josh Cutlan. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayCountLabel: UILabel!    
    @IBOutlet weak var upArrowImageView: UIImageView!
    @IBOutlet weak var downArrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        upArrowImageView.isHidden = true
        upArrowImageView.isHidden = true
        //backgroundColor = .clear
        //contentView.backgroundColor = .clear
        //layer.backgroundColor = UIColor.clear.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
