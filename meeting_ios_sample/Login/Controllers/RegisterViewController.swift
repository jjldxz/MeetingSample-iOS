//
//  RegisterViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/8/31.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var regist_btn: UIButton!
    @IBOutlet weak var errornotice_label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "User Regist"
        
        username_field.delegate = self
        password_field.delegate = self
        
        regist_btn.isEnabled = false
    }
    
    // check text field content
    func checkInputContent(name: String, password: String) -> Bool {
        if (!name.isEmpty && !password.isEmpty) {
            return true
        } else {
            return false
        }
    }

    // UI actions
    @IBAction func userRegistAction(_ sender: Any) {
        MeetingAPIRequest.userRegist(name: self.username_field.text!, password: self.password_field.text!) {[weak self] response in
            if response == nil {
                
            } else {
                let responseObj = response as! Dictionary<String, Any>
                let userId:Int32 = responseObj["user"] as! Int32
                let token:String = responseObj["token"] as! String
                let refreshToken:String = responseObj["refreshToken"] as! String
                MeetingAPIRequest.shareManager.settingUserAuthToken(token: token)
                LoginUserDataModel.manager.user_name = self!.username_field.text!
                LoginUserDataModel.manager.userId = userId
                LoginUserDataModel.manager.authToken = token
                LoginUserDataModel.manager.refreshToken = refreshToken
                self!.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // textfiled delegate action
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.isEqual(self.username_field)) {
            if !self.username_field.text!.isEmpty {
                MeetingAPIRequest.usernameVerify(username: self.username_field.text!) {[weak self] response in
                    if response == nil {
                        
                    } else {
                        let responseObj = response as! Dictionary<String, Any>
                        let valid:Bool = responseObj["valid"] as! Bool
                        if !valid {
                            self!.errornotice_label.isHidden = false
                            self!.regist_btn.isEnabled = self!.checkInputContent(name: self!.username_field.text!, password: self!.password_field.text!)
                        }
                    }
                }
            }
        } else {
            self.regist_btn.isEnabled = self.checkInputContent(name: self.username_field.text!, password: self.password_field.text!)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
