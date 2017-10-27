//
//  ClassesTableVC.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire


class ClassesTableVC: UICollectionViewController {

    
    // api数据
    var classSchedule = [[Int]]()
    var classImformation = [[String:Any]]()
    var classinfo = [Int:String]() // id与课程名的对应
    var classroomInfo = [Int:String]() // id与上课地点的对应
    var idArray = [Int]()
    var currTime = [String:Int]() // 当前时间
    var refresher : UIRefreshControl! = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "松开刷新")
        refresh.addTarget(self, action: #selector(updateClassTable), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "课程表"
        getClassSchedule()
        getClassImformation()
        getCurrTime()
        // 固定headerview
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        self.collectionView?.addSubview(refresher)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 8
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! classcell
        // 首列数字
        if indexPath.row == 0 {
            cell.name.text = String(indexPath.section+1)
        } else {
            cell.name.text = ""
        }
        
        if idArray.isEmpty && !classImformation.isEmpty {
            // 获取idArray与上课地点
            for item in classImformation {
                idArray.append(item["id"] as! Int)
            }
        }
        
        // 利用对应关系,标记单元格
        if !classSchedule.isEmpty {
            if indexPath.row != 0{
                if indexPath.section < classSchedule[0].count && (indexPath.row-1)<classSchedule.count {
                    cell.id = classSchedule[indexPath.row-1][indexPath.section]
                }
            }
        }
        // 填充数据
        if !idArray.isEmpty && !classImformation.isEmpty && !classSchedule.isEmpty{
        for num in idArray {
            // 判断不对
            // 为了向后兼容
            if cell.id == num && indexPath.row != 0 && indexPath.section < classSchedule[0].count{
                // 添加地点显示
                cell.name.text = classinfo[num]!+"@"+classroomInfo[num]!
            }
        }
        }
        // 高亮显示当前课程 currWeekDay currLessonNum
        if !currTime.isEmpty {
            if indexPath.row == currTime["currWeekDay"]  && indexPath.section+1 == currTime["currLessonNum"]{
                // 有问题！！！
                cell.backgroundColor = UIColor.hexStringToUIColor(hex: "#6F9CC9")
            }
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! classcell
        // 可编辑区域
        if indexPath.row == 0 {
            cell.isUserInteractionEnabled = false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! classTableHeaderView
        let width = (self.view.frame.width-30)/7
        headerview.mondayLbl.frame.size = CGSize(width: width, height: 25)
        headerview.momthLbl.frame.size  = CGSize(width: 30, height: 25)
        // 获取当前月份：
        headerview.momthLbl.text = Date.month()
        
        headerview.backgroundColor = UIColor.brown
        return headerview 
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    // 获取学生课程表
    func getClassSchedule(){
        if !self.classSchedule.isEmpty {
            // 防止出错！
            print("更新前:\(classSchedule)")
            self.classSchedule.removeAll(keepingCapacity: false)
            print("清空classSchedule")
        }
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getClasseschedule)
        Alamofire.request(url!).responseJSON{ [weak self] response in
            if let json = response.result.value  as? [String:Any]{
                if json["errors"] == nil {
                    self?.classSchedule = json["data"] as! [[Int]]
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    // 有待完善错误信息
                    self?.alert(error: "提示", message: String(describing: errors))
                    
                }
            }
        }
        
    }
    
    // 获取课程信息
    func getClassImformation(){
        if !self.classImformation.isEmpty {
            print("更新前:\(classImformation)")
            self.classImformation.removeAll(keepingCapacity: false)
            print("清空classImformation")
        }
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getAllCourse)
        Alamofire.request(url!).responseJSON{ [weak self] response in
            if Thread.isMainThread {
                print("Main Queue")
            }
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.classImformation = json["data"] as! [[String:Any]]
                    
                    let data = json["data"] as! [[String:Any]]
                    for item in data {
                        let classroom = item["classroom"] as! [String:Any]
                        self?.classinfo.updateValue(item["courseName"] as! String, forKey: item["id"] as! Int)
                        self?.classroomInfo.updateValue(classroom["classroomName"] as! String, forKey: item["id"] as! Int)
                    }
                    // 无课选项
                    self?.classinfo.updateValue("", forKey: 0)
                    // 主线程中更新UI
                    self?.collectionView?.reloadData()
                    
                } else {
                    let errors = json["errors"] as! [String:String]
                    // 进一步完善错误信息
                    self?.alert(error: "提示", message: String(describing: errors))
                }
            }
        }
    }
    
    func updateClassTable(){
        getClassImformation()
        getClassSchedule()
        getCurrTime()
        // 通知签到页面刷新
        NotificationCenter.default.post(name: .courseTableUpdated, object: nil)
        refresher.endRefreshing()
    }
    
    // 当前时间
    func getCurrTime(){
        if !currTime.isEmpty {
            currTime.removeAll(keepingCapacity: false)
        }
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getCurrTime)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any] {
                if json["errors"] == nil {
                    self?.currTime = json["data"] as! [String : Int]
                    // 主线程中更新UI
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    print("获取时间出现错误:\(errors)")
                }
            }
        }
    }
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

extension ClassesTableVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 首列
        if  indexPath.row == 0 {
            return CGSize(width: 30, height: 85)
        }
        let width = (self.view.frame.width-30)/7
        let height :CGFloat = 85
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
        let width = self.view.frame.width
        let height : CGFloat = 30
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
}
