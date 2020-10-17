//
//  FavoriteCell.swift
//  GithubSearch
//
//  Created by Tarokh on 8/11/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
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
        
    }

}
