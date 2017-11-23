//
//  ActivitiesTableViewCell.swift
//  FitnessApp
//
//  Created by Bishal Wagle on 11/23/17.
//  Copyright © 2017 FitnessGroup. All rights reserved.
//

import Foundation
import UIKit

class ActivitiesTableViewCell: UITableViewCell {
    var myActivity: Activity = Activity() {
        didSet{
            self.updateView()
        }
    }
    
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var BottomLabel: UILabel!
    
    func updateView(){
        self.TopLabel.text = self.myActivity.startDate.timestampString
        self.BottomLabel.text = self.myActivity.duration
        //        self.TopLabel.backgroundColor = UIColor.red
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.backgroundColor = UIColor.clear
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

