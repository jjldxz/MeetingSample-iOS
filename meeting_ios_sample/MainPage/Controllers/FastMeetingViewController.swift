//
//  FastMeetingViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/6.
//

import UIKit

class FastMeetingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var duration_btn: UIButton!
    @IBOutlet weak var join_btn: UIButton!
    @IBOutlet weak var duration_picker: UIPickerView!
    @IBOutlet weak var pickerTitleView: UIView!
    
    var durationList:Array<String> = ["30 mins", "45 mins", "60 mins", "90 mins", "120 mins"]
    var duration_seconds:TimeInterval = 7200.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Fast Meeting"
        // Do any additional setup after loading the view.
        self.duration_picker.selectRow(durationList.count - 1, inComponent: 0, animated: true)
    }
    
    /// UI Actions
    @IBAction func pickerCancelSelectAction(_ sender: UIButton) {
        self.duration_picker.isHidden = true
        self.pickerTitleView.isHidden = true
    }
    
    @IBAction func pickerSubmitSelectAction(_ sender: UIButton) {
        let index:Int = self.duration_picker.selectedRow(inComponent: 0)
        let selectedText:String = self.durationList[index]
        self.duration_btn.setTitle(selectedText.appending(" >"), for: .normal)
        switch index {
        case 0:
            duration_seconds = 1800.0
            break
        case 1:
            duration_seconds = 2700.0
            break
        case 2:
            duration_seconds = 3600.0
            break
        case 3:
            duration_seconds = 5400.0
            break
        case 4:
            duration_seconds = 7200.0
        default:
            break
        }
    }
    
    @IBAction func openCameraAction(_ sender: UISwitch) {
        
    }
    
    @IBAction func durationSelectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.duration_picker.isHidden = false
            self.pickerTitleView.isHidden = false
        } else {
            self.duration_picker.isHidden = true
            self.pickerTitleView.isHidden = true
        }
    }
    @IBAction func joinFastMeetingAction(_ sender: UIButton) {
        let startDate:Date = Date()
        let endDate:Date = startDate.addingTimeInterval(duration_seconds)
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation:"UTC")!
        let startAtTime:String = dateFormatter.string(from: startDate)
        let endAtTime:String = dateFormatter.string(from: endDate)
        let meetingTitle:String = (LoginUserDataModel.manager.user_name ?? String(LoginUserDataModel.manager.userId!)).appending("'s Fast Meeting")
        MeetingAPIRequest.meetingCreate(name: meetingTitle, beginAt: startAtTime, endAt: endAtTime, muteType: 0, password: nil) {[weak self] response in
            if (response != nil) {
                var meeting_info:meetingInfoStruct = JSON(withJSONObject: response, modelType: meetingInfoStruct.self)!
                meeting_info.ownerId = Int(LoginUserDataModel.manager.userId!)
                meeting_info.ownerName = LoginUserDataModel.manager.user_name
                meeting_info.name = meetingTitle
                meeting_info.status = 0
                meeting_info.beginAt = ((response as! Dictionary<String, Any>)["created"] as! String)
                meeting_info.muteType = 0
                meeting_info.endAt = endAtTime
                let meeting_setting:MeetingJoinInfo = MeetingJoinInfo.init(meeting_code: meeting_info.number, meeting_nickname: meetingTitle, meeting_muteType: meeting_info.muteType, meeting_type: .fromFast, is_admin: true, carmera_status: true, audio_status: true, speaker_status: true)
                let meetingVC = MeetingViewController.init()
                meetingVC.settingMeetingInfoMessage(info: meeting_info, setting_info: meeting_setting)
                meetingVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.popToRootViewController(animated: true)
                self!.navigationController?.present(meetingVC, animated: true, completion: nil)
            } else {
                print("fast meeting create error")
            }
        }
    }
    
    
    /// UIPickerViewDataSource, UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.durationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attr_title:NSMutableAttributedString = NSMutableAttributedString.init(string: self.durationList[row], attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.darkGray])
        return (attr_title.copy() as! NSAttributedString)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}
