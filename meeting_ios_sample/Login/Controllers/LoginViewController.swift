//
//  LoginViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/8/30.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var login_btn: UIButton!
    @IBOutlet weak var regist_btn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Meeting Login"
        // Do any additional setup after loading the view.
        let back_item = UIBarButtonItem.init(title: "back", style: .plain, target: self, action: #selector(loginBackAction))
        back_item.tintColor = .lightGray
        back_item.width = 40.0
        self.navigationItem.setLeftBarButton(back_item, animated: false)
        
        self.username_field.delegate = self
        self.password_field.delegate = self
        
        self.login_btn.isEnabled = false
    }
    
    // button actions
    @IBAction func registAction(_ sender: Any) {
        self.navigationController?.pushViewController(RegisterViewController.init(), animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        // network request
        MeetingAPIRequest.userLogin(name: self.username_field.text!, password: self.password_field.text!) {[weak self] response in
            if response == nil {
                print("request error")
            } else {
                let responseMap = response! as! Dictionary<String, Any>
                let userId:Int32 = responseMap["user"] as! Int32
                let apiToken:String = responseMap["token"] as! String
                let refreshToken:String = responseMap["refreshToken"] as! String
                MeetingAPIRequest.shareManager.settingUserAuthToken(token: apiToken)
                LoginUserDataModel.manager.userId = userId
                LoginUserDataModel.manager.authToken = apiToken
                LoginUserDataModel.manager.refreshToken = refreshToken
                LoginUserDataModel.manager.user_name = self?.username_field.text
                UserDefaults.standard.set(apiToken, forKey: "api_token")
                UserDefaults.standard.set(userId, forKey: "user_id")
                UserDefaults.standard.set(self?.username_field.text, forKey: "user_name")
                UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
                self?.loginBackAction()
            }
        }
    }

    
    @objc func loginBackAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // check text field content
    func checkInputContent(name: String, password: String) -> Bool {
        if (!name.isEmpty && !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    // textField delegate action
    func textFieldDidEndEditing(_ textField: UITextField) {
        let result:Bool = self.checkInputContent(name: self.username_field.text!, password: self.password_field.text!)
        self.login_btn.isEnabled = result
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // dealloc
    deinit {
        debugPrint("login page did release")
    }
    
}
