//
//  GoogleCell.swift
//  SampleTableView
//
//  Created by Darshan on 19/05/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit

class GoogleCell: UITableViewCell {
    @IBOutlet weak var placeNameLbl: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
