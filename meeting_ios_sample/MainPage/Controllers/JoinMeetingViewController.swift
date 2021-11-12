//
//  JoinMeetingViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/3.
//

import UIKit

class JoinMeetingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var meeting_number_field: UITextField!
    @IBOutlet weak var user_name_field: UITextField!
    @IBOutlet weak var mic_switch: UISwitch!
    @IBOutlet weak var speaker_switch: UISwitch!
    @IBOutlet weak var camera_switch: UISwitch!
    @IBOutlet weak var join_meeting_btn: UIButton!
    
    var cameraEnable:Bool = true;
    var microphoneEnable:Bool = true;
    var speakerEnable:Bool = true;
    var joinMeetingInfo:meetingInfoStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Join Meeting"
        // Do any additional setup after loading the view.
        self.meeting_number_field.delegate = self
        self.user_name_field.delegate = self
        
        self.user_name_field.text = LoginUserDataModel.manager.user_name!
        
        self.join_meeting_btn.layer.cornerRadius = 5.0
        self.join_meeting_btn.layer.masksToBounds = true
        
        let tapAction:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(touchViewBackAction))
        self.view.addGestureRecognizer(tapAction)
    }
    
    @objc func touchViewBackAction() {
        self.view.endEditing(true)
    }

    /// UI Actions
    @IBAction func joinMeetingAction(_ sender: UIButton) {
        let number:Int = Int(self.meeting_number_field.text!)!
        MeetingAPIRequest.meetingInfo(number: Int32(number)) {[weak self] response in
            if response != nil {
                let meeting_info:meetingInfoStruct = JSON(withJSONObject: response, modelType: meetingInfoStruct.self)!
                self!.joinMeetingInfo = meeting_info
                if (meeting_info.password != nil && meeting_info.password!.isEmpty == false) {
                    let alert = UIAlertController.init(title: "Password", message: "please input meeting password", preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.placeholder = "password"
                        textField.delegate = self!
                    }
                    alert.addAction(UIAlertAction.init(title: "submit", style: .default, handler: { action in
                        let textFeild:UITextField = (alert.textFields?.first)!
                        let password:String? = textFeild.text
                        if (password != nil && password!.isEmpty == false) {
                            if self?.joinMeetingInfo?.password == password {
                                alert.dismiss(animated: true) {
                                    let is_admin:Bool = LoginUserDataModel.manager.userId! == self!.joinMeetingInfo!.ownerId!
                                    let meeting_settings:MeetingJoinInfo = MeetingJoinInfo.init(meeting_code: self!.joinMeetingInfo!.number!, meeting_nickname: self!.user_name_field.text, meeting_muteType: 0, meeting_type: .fromList, is_admin: is_admin, carmera_status: self!.cameraEnable, audio_status: self!.microphoneEnable, speaker_status: self!.speakerEnable)
                                    let meetingVC = MeetingViewController.init()
                                    meetingVC.modalPresentationStyle = .fullScreen
                                    meetingVC.settingMeetingInfoMessage(info: self!.joinMeetingInfo!, setting_info: meeting_settings)
                                    self?.navigationController?.popToRootViewController(animated: true)
                                    self?.navigationController?.present(meetingVC, animated: true, completion: nil)
                                }
                            } else {
                                print("password error")
                                alert.dismiss(animated: true, completion: nil)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self!.present(alert, animated: true, completion: nil)
                } else {
                    let is_admin:Bool = LoginUserDataModel.manager.userId! == self!.joinMeetingInfo!.ownerId!
                    let meeting_settings:MeetingJoinInfo = MeetingJoinInfo.init(meeting_code: self!.joinMeetingInfo!.number!, meeting_nickname: self!.user_name_field.text, meeting_muteType: 0, meeting_type: .fromList, is_admin: is_admin, carmera_status: self!.cameraEnable, audio_status: self!.microphoneEnable, speaker_status: self!.speakerEnable)
                    let meetingVC = MeetingViewController.init()
                    meetingVC.modalPresentationStyle = .fullScreen
                    meetingVC.settingMeetingInfoMessage(info: self!.joinMeetingInfo!, setting_info: meeting_settings)
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.navigationController?.present(meetingVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func microphoneSwitchAction(_ sender: UISwitch) {
        self.microphoneEnable = sender.isOn
    }
    
    @IBAction func speakerSwitchAction(_ sender: UISwitch) {
        self.speakerEnable = sender.isOn
    }
    
    @IBAction func cameraSwitchAction(_ sender: UISwitch) {
        self.cameraEnable = sender.isOn
    }
    
    // textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.isEqual(self.meeting_number_field)) {
            self.join_meeting_btn.isEnabled = (textField.text?.count == 9 ? true : false)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.isEqual(self.meeting_number_field)) {
            self.join_meeting_btn.isEnabled = (textField.text?.count == 9 ? true : false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
