//
//  ChangeVC.swift
//  student
//
//  Created by drf on 2017/10/1.
//  Copyright © 2017年 drf. All rights reserved.
//

import UIKit
import Alamofire

class ChangeVC: UIViewController {
    @IBOutlet weak var item1Lbl: UILabel!
    @IBOutlet weak var item1Text: UITextField!
    @IBOutlet weak var item2Lbl: UILabel!
    @IBOutlet weak var item2Text: UITextField!
    @IBOutlet weak var item3Lbl: UILabel!
    @IBOutlet weak var item3Text: UITextField!
    @IBOutlet weak var changeBtn: UIButton!
    var type : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setContent(type: type)
        // 自定义返回按钮
        let backBtn = UIBarButtonItem(title: "<返回", style: .plain, target: self, action: #selector(back))
        self.navigationItem.backBarButtonItem = backBtn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func ChangeData(_ sender: Any) {
        if type == "更换手机号码" {
            print("更换手机号码")
            changePhoneNum()
        } else {
            print("更换密码")
            changePasswd()
        }
    }
    // 可能需要使用segue正向传值
    func setContent(type : String){
        if type == "更换手机号码"{
            self.navigationItem.title = "更改手机号码"
            self.item1Lbl.text = "新手机号码："
            self.item1Text.placeholder = "请输入新手机号码"
            self.item2Lbl.text = "密码："
            self.item2Text.placeholder = "请输入密码"
            item2Text.delegate = self
            // 不需要重新布局
            self.item3Text.alpha = 0
            self.item3Lbl.alpha = 0
            //self.item3Lbl.isHidden = true
            //self.item3Text.isHidden = true
            self.changeBtn.setTitle("修改手机号码", for: .normal)
        } else {
            self.navigationItem.title = "修改密码"
            self.item1Lbl.text = "新密码："
            self.item1Text.placeholder = "请输入新密码"
            self.item2Lbl.text = "重复密码："
            self.item2Text.placeholder = "请重新输入密码"
            self.item3Lbl.text = "旧密码："
            item3Text.delegate = self
            self.item3Text.placeholder = "请输入旧密码"
            self.changeBtn.setTitle("修改密码", for: .normal)
            
        }
    }
    
    func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // 更改手机号码
    func changePhoneNum(){
        //检验数据有效性
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "新手机号码不能为空")
            return
        }
        
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "请输入密码")
            return
        }
        
        if !validatePhoneNumber(num: item1Text.text!){
            alert(error: "提示", message: "无效的手机号码")
            return
        }
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.changePhoneNum)
        let parameter : Parameters = ["phoneNumber": self.item1Text.text!, "password" : self.item2Text.text!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String : Any] {
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: json["msg"] as! String)
                } else {
                    let errors = json["errors"] as! [String : String]
                    if let passwdError = errors["password"] {
                        self?.alert(error: "提示", message: passwdError)
                    }
                    if let phoneNumberError = errors["phoneNumber"] {
                        self?.alert(error: "提示", message: phoneNumberError)
                    }
                }
            }
        }
    }
    
    // 更改密码
    func changePasswd(){
        // 检验数据有效性
        if (item1Text.text?.isEmpty)! {
            alert(error: "提示", message: "新密码不能为空")
            return
        }
        if (item2Text.text?.isEmpty)! {
            alert(error: "提示", message: "请输入确认密码")
            return
        }
        if (item3Text.text?.isEmpty)! {
            alert(error: "提示", message: "请输入当前密码")
            return
        }
        if item1Text.text! != item2Text.text! {
            alert(error: "提示", message: "新密码不一致")
            return
        }
        
        let url = URL(string: Constants.Weteam.BaseURL+Constants.Method.changePasswd)
        let parameter : Parameters = ["newPassword": item1Text.text!, "oldPassword": item2Text.text!]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{[weak self] response   in
            if let json = response.result.value as? [String : Any] {
                if json["errors"] == nil {
                    // 返回loginVC，清除Userdefault cookie
                    UserDefaults.standard.removeObject(forKey: "savedCookies")
                    
                    let alertView = UIAlertController(title: "提示", message: "修改密码成功,请重新登录", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel){ (action) in 
                        let loginVC = self?.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        self?.navigationController?.present(loginVC, animated: true, completion: nil)
                    }
                    alertView.addAction(ok)
                    self?.present(alertView, animated: true, completion: nil)

                } else {
                    let errors = json["errors"] as! [String : String]
                    if let oldPasswdError = errors["oldPassword"] {
                        self?.alert(error: "提示", message: oldPasswdError)
                    }
                    if let newPasswdError = errors["newPassword"] {
                        self?.alert(error: "提示", message: newPasswdError)
                    }
                    // 未知错误
                    self?.alert(error: "提示", message: String(describing: errors))
                    
                }
            }
        }
    
    }
    
    // 检验电话号码是否有效
    func validatePhoneNumber(num : String) -> Bool {
        let regex = "0?(13|14|15|18)[0-9]{9}"
        let range = num.range(of: regex,options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

 

}

extension ChangeVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
