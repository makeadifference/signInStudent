//
//  EditVC.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class EditVC: UITableViewController {
    let items : [String] = ["修改手机号", "修改密码","退出登录"]
    var studentName : String!
    var phoneNum = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "修改个人信息"
        getUserInfo()
        // 移除空白单元格+footView
        let foot_frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: 40)
        let lable_frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        let lable = UILabel(frame: lable_frame)
        lable.text = "暂时就这么多功能💤"
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 10)
        let foot_view = UIView(frame: foot_frame)
        foot_view.addSubview(lable)
        self.tableView.tableFooterView = foot_view
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("EditVC deinited")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return items.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserCell
            if (studentName != nil) {
            cell.userNameLbl.text = studentName
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = self.items[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 40
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.section != 0 {
        if indexPath.row == 0 {
            let changePNVC = storyboard.instantiateViewController(withIdentifier: "ChangeVC") as! ChangeVC
            changePNVC.type = "更换手机号码"
            self.navigationController?.pushViewController(changePNVC, animated: true)
        } else if indexPath.row == 1{
            let changePassWdVC = storyboard.instantiateViewController(withIdentifier: "ChangeVC") as! ChangeVC
            changePassWdVC.type = "更改密码"
            self.navigationController?.pushViewController(changePassWdVC, animated: true)
        } else {
            logout()
            }
        }
    }
    
    // 获取用户信息
    func getUserInfo(){
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.getUserInfo)
        Alamofire.request(url!).responseJSON{[weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.studentName = (json["data"] as! [String:Any])["studentName"] as! String
                    self?.tableView.reloadData()
                } else {
                    let errors = json["errors"] as! [String:String]
                    print("\(errors)")
                }
            }
        }
        
        
    }
    
    // 退出登录
    func logout(){
        // 转到登录界面
        UserDefaults.standard.removeObject(forKey: "phoneNum")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }

}
