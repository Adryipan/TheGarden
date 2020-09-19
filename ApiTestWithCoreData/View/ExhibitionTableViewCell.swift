//
//  ExhibitionTableViewCell.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 19/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class ExhibitionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exhibitionImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
