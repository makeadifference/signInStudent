//
//  Date+compare.swift
//  student
//
//  Created by drf on 2017/10/27.
//  Copyright © 2017年 drf. All rights reserved.
//

import Foundation

extension Date {
    static func how_far(){
        let now = Date()
        let from = Date()
        // 时间信息封装类
        let components : Set<Calendar.Component> = [.second, .minute,.hour,.day, . weekOfMonth]
        let differences = Calendar.current.dateComponents(components, from: from, to: now)
        
        if differences.second! <= 0 {
            print("现在")
        }
        if differences.second! > 0 && differences.minute! <= 0 {
            print("秒")
        }
        if differences.minute! > 0 && differences.hour! <= 0 {
            print("分钟")
        }
        if differences.hour! > 0 && differences.day! <= 0 {
            print("小时")
        }
        if differences.day! > 0 && differences.weekOfMonth! <= 0 {
            print("天")
        }
        if differences.weekOfMonth! > 0 {
            print("星期")
        }
    }
    
    static func compareMinutine(prev :Date) -> Bool{
        let now = Date()
        let components : Set<Calendar.Component> = [.minute]
        let differences = Calendar.current.dateComponents(components, from: prev, to: now)
        print("比较结果为:\(differences.minute!)")
        if differences.minute! < 10 {
            return true
        } else {
        // 更新时间
        let newTime = Date()
        UserDefaults.standard.set(newTime, forKey: "SignTime")
        }
        
        return false
    }
}
