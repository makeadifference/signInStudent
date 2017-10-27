//
//  placeCell.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class placeCell: UICollectionViewCell {
    @IBOutlet weak var studentName: UILabel!
    var isSignIn : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.backgroundColor = UIColor.gray.cgColor
    }
    
    override func prepareForReuse() {
        self.studentName.text = ""
        self.isSignIn = 0 
    }
}
