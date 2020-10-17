//
//  TrendingCell.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit

class TrendingCell: UITableViewCell {
    
    // define some @IBOutlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // define some functions
    func configCell(item: Items) {
        nameLabel.text = item.full_name
        descriptionLabel.text = item.description
    }

}
