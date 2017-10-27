//
//  Date+month.swift
//  student
//
//  Created by drf on 2017/10/25.
//  Copyright © 2017年 drf. All rights reserved.
//

import Foundation
extension Date {
    static func month()->String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: now)
        return month
    }
}
