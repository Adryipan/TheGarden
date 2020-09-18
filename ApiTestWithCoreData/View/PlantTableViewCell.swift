//
//  PlantTableViewCell.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 15/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class PlantTableViewCell: UITableViewCell {

    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var scienceNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
