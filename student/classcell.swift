//
//  classcell.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit

class classcell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    var id : Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
        self.backgroundColor = UIColor.hexStringToUIColor(hex:"#F5E0BF")
    }
    
    override func prepareForReuse() {
        self.backgroundColor = UIColor.hexStringToUIColor(hex:"#F5E0BF")
    }
    
}
