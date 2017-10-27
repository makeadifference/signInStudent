//
//  UserCell.swift
//  student
//
//  Created by drf on 2017/10/7.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var phoneNumLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        userimage.layer.cornerRadius = 30
        userimage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
