//
//  SortTableViewCell.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 18/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class SortTableViewCell: UITableViewCell {
    
    lazy var bgView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        return view
    }()
    
    lazy var customImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 60, y: 10, width: self.frame.width - 80, height: 30))
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        addSubview(bgView)
        addSubview(customImageView)
        addSubview(nameLabel)
    }

}
