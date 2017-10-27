//
//  SignInVC.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire


class SignInVC: UICollectionViewController {
    var cellwidth : CGFloat = 0
    var cellheigh : CGFloat = 0
    var isSignIn = 0 // 标记签到状态
    var signInArray = [[Int]]() // 当前课堂签到信息
    var studentArray = [[String : Any]]()
    var layoutArray = [[Int]]()
    var idArray = [Int]() // 存储学生id
    /*
    var refresher : UIRefreshControl! = {
        let arefresher = UIRefreshControl()
        arefresher.attributedTitle = NSAttributedString(string: "松开刷新")
        arefresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return arefresher
    }()
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "签到"
        self.cellwidth = (self.view.frame.width-30)/7
        self.cellheigh = cellwidth
        getClassRoomLayout()
        getCourseSignInInfo()
        loadAllStudent()
        getMySignInInfo()
        // 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .courseTableUpdated, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("SignInVC deinited")
    }
    
  
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return layoutArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 一教室的座位数为数据源
        return layoutArray[0].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeCell", for: indexPath) as! placeCell
        
        // 非座位
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: "#d6d4ff")
        
        // 非座位
        if layoutArray[indexPath.section][indexPath.row] == 0 {
            cell.backgroundColor = UIColor.clear
            cell.studentName.text = ""
        }
        // 标记id
        if !signInArray.isEmpty {
        cell.isSignIn = signInArray[indexPath.section][indexPath.row]
        }
        // 这里有问题
        // 填充座位信息
        if cell.isSignIn != 0 && !signInArray.isEmpty {
            print("signin:\(cell.isSignIn) index \(indexPath.section) \(indexPath.row)")
            getStudentName(byId: cell.isSignIn, completionHandler: { result in
                // 主线程中更新UI
                cell.studentName.text = result
            })
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "jiangtai", for: indexPath) as! SignInHeaderView
        if indexPath.section != 0 {
            header.isHidden = true
        }
        return header
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
        // 首先检验我的签到状态 getmysigninfo
        let cell = collectionView.cellForItem(at: indexPath) as! placeCell
        if cell.isSignIn == 0 {
            let seatY = indexPath.row
            let seatX = indexPath.section
            SignIn(seatX: seatX, seatY: seatY)
        } else {
            alert(error: "签到失败", message: "该座位已经有人了")
        }
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
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 获取教室布局
    func getClassRoomLayout(){
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.classLayout)
        Alamofire.request(url!).validate().responseJSON{ [weak self]response in
            if let json = response.result.value as? [String : Any] {
                if json["errors"] == nil {
                    self?.layoutArray = json["data"] as! [[Int]]
                    print("教室布局:\(String(describing: self?.layoutArray))")
                // 座位行列数
                } // 不用处理未登录情况
            }
        }
    }
    
    // 获取当前课程的签到信息
    func getCourseSignInInfo(){
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getSigninInfo)
        Alamofire.request(url!).validate().responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any] {
                if json["errors"] == nil  {
                    self?.signInArray = json["data"] as! [[Int]]
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                   // self?.alert(error: "提示", message: String(describing: errors))
                }
            }
        }
    }
    
    // 我的签到状态
    func getMySignInInfo(){
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.mySigninInfo)
        Alamofire.request(url!).validate().responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any] {
                print(String(describing: json))
                if json["errors"] == nil {
                    print("签到情况:\(json)")
                    self?.isSignIn = json["code"] as! Int
                    if json["msg"] == nil && (json["code"] as! Int) == 1 && json["data"] == nil {
                        let tabItems = self?.tabBarController?.tabBar.items
                        tabItems?[0].badgeValue = "1"
                    }
                    self?.collectionView?.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                
                }
            }
        }
        
    }
    
    // 获取所有学生 , 这种方法对性能影响较小吧
    func loadAllStudent(){
        
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getAllStudent)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value  as? [String : Any]{
                if json["errors"] == nil {
                    self?.studentArray = json["data"] as! [[String : Any]]
                    self?.collectionView?.reloadData()
                } else {
                    if let errer = json["error"] {
                        self?.alert(error: "提示", message: errer as! String)
                    }
                }
            }
            
        }
    }
    
    // 根据id获取学生姓名
    
    
    func getStudentName(byId:Int,completionHandler: @escaping (String)->()) {
        var temp : String! = ""
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getStudentInfo)
        let parameter : Parameters = ["studentId":byId]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any] {
                if json["errors"] == nil {
                    temp = (json["data"] as! [String:Any])["studentName"] as! String
                    completionHandler(temp)
                } else {
                    let errors = json["errors"]
                    temp = ""
                    self?.alert(error: "提示", message: String(describing: errors))
                }
            }
        }
    }
    
    // 签到方法
    
    func SignIn(seatX:Int,seatY:Int){
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.signIn)
        let parameter : Parameters = ["seatX": seatX , "seatY":seatY]
        
        // 一个本地的简单防代签手段
        //  思路，签到时获取当前时间，储存，以后签到都与此进行比较

        /*
        if let prev = UserDefaults.standard.object(forKey: "SignTime") {
            print("进行防代签检测")
            if Date.compareMinutine(prev: prev as! Date) {
                self.alert(error: "签到失败", message: "系统检测到您存在异常的签到行为")
                return 
            }
        } else {
            let now = Date()
            // 第一次签到
            UserDefaults.standard.set(now, forKey: "SignTime")
        }
         
        */
 
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: "签到成功")
                    self?.refresh()
                    // 在主线程中更新UI，否则位置问题
                } else {
                    let errors = json["errors"] as! [String:String]
                    self?.alert(error: "签到失败", message: String(describing: errors))
                }
            }
        }
    }
    
    // 下拉刷新
    func refresh(){
        
        getClassRoomLayout()
        getCourseSignInInfo()
        getMySignInInfo()
        loadAllStudent()
        print("成功更新教室信息")
      //  refresher.endRefreshing()
    }
    
}

extension SignInVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size_zore = CGSize(width: 0, height: 0)
        let size = CGSize(width: self.view.frame.width, height: 25)
        if section == 0 {
            return size
        } else {
            return size_zore
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var count = 1;
        if !layoutArray.isEmpty {
            count = layoutArray[0].count
        }
        let width = (self.view.frame.width-CGFloat(count))/CGFloat(count)
        return CGSize(width: width, height: width)
    }
    
    // 调整单元格间距
/*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        collectionView.reloadData()
        print("cellwitcha\(cellwidth)")
        let totalCellWidth = cellwidth * CGFloat(row)
        let totalSpacingWidth : CGFloat = 0
        
        let leftInset = (self.view.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        print("layout:\(totalCellWidth) --- \(leftInset)")
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
 */
}
