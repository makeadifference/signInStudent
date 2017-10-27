//
//  Constants.swift
//  student
//
//  Created by drf on 2017/10/3.
//  Copyright © 2017年 drf. All rights reserved.
//  API常量,便于维护
// Alamofire.request("https://httpbin.org/post", method: .post)
// Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters)
/*
 public enum HTTPMethod: String {
 case options = "OPTIONS"
 case get     = "GET"
 case head    = "HEAD"
 case post    = "POST"
 case put     = "PUT"
 case patch   = "PATCH"
 case delete  = "DELETE"
 case trace   = "TRACE"
 case connect = "CONNECT"
 }
 */
struct Constants {
    // MARK: API 基址
    struct Weteam {
        static let BaseURL = "http://123.207.117.67/studentsignin/"
    }
    // http://123.207.117.67/studentsignin/student/getCourseInfo
    
    // MARK: 方法
    struct Method {
        static let getAllStudent = "admin/student/getAll"
        static let getVcode = "getVCode" // 验证码
        static let getCurrTime = "getCurrTime" // 当前上课时间
        static let Login = "student/login" // 登录
        static let changePasswd = "student/changePassword" // 更改密码
        static let changePhoneNum = "student/changePhoneNumber" // 更改电话
        static let getClasseschedule = "student/getClassSchedule" // 课程表
        static let getClassInfo = "student/getCourseInfo" // 当前上课信息
        static let classLayout = "student/getClassroomLayout" // 教室布局
        static let getSigninInfo = "student/getClassroomSignInfo" // 当前课堂签到信息
        static let getStudentInfo = "student/getStudentInfo" // 学生信息
        static let signIn = "student/signIn" // 签到
        static let mySigninInfo = "student/getCurrLessonSignInfo" // 学生签到状态
        static let mySigninInfoWeekly = "student/getWeekSignInfo" // 本周签到状态
        static let getCourseInfo = "student/getCourseInfo" // 获取课程信息
        static let getUserInfo = "student/getMyInfo"  // 获取我的信息
        static let getAllCourse = "admin/course/getAll" // 获取所有课程
    }
    
    
}

