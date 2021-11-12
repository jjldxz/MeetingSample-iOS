//
//  ReserveMeetingViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/2.
//

import UIKit

class ReserveMeetingViewController: UIViewController, UITextFieldDelegate, BHXDatePikerViewDelegate {

    @IBOutlet weak var meeing_title_field: UITextField!
    @IBOutlet weak var begin_time_btn: UIButton!
    @IBOutlet weak var end_time_btn: UIButton!
    @IBOutlet weak var mute_type_switch: UISwitch!
    @IBOutlet weak var password_switch: UISwitch!
    @IBOutlet weak var password_view: UIView!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var reserve_btn: UIButton!
    
    var datePicker:BHXPikerView = BHXPikerView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), type:.dateAndTime)
    
    private var beginAtTime:Date?
    private var endAtTime:Date?
    private var muteType:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Reserve Meeting"
        self.datePicker.delegate = self
        self.meeing_title_field.delegate = self
        self.password_field.delegate = self
        // Do any additional setup after loading the view.
        self.reserve_btn.layer.cornerRadius = 5
        self.reserve_btn.layer.masksToBounds = true
        
        self.beginAtTime = Date()
        self.begin_time_btn.setTitle(self.calculateDate(date: self.beginAtTime!), for: .normal)
        self.endAtTime = self.beginAtTime!.addingTimeInterval(1800.0)
        self.end_time_btn.setTitle(self.calculateDate(date: self.endAtTime!), for: .normal)
    }
    
    func calculateDate(date: Date) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let start_date:String = dateFormate.string(from: date)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation:"UTC")!
        let weekday:Int = calendar.component(.weekday, from: date)
        var weekday_string:String = ""
        switch weekday {
        case 1:
            weekday_string = "Sun."
            break
        case 2:
            weekday_string = "Mon."
            break
        case 3:
            weekday_string = "Tues."
            break
        case 4:
            weekday_string = "Wed."
            break
        case 5:
            weekday_string = "Thur."
            break
        case 6:
            weekday_string = "Fri."
            break
        case 7:
            weekday_string = "Sat."
            break
        default:
            break
        }
        let separatedStartDate:Array<String> = start_date.components(separatedBy: " ")
        let startTime:String = separatedStartDate.first! + " " + weekday_string + " " + separatedStartDate.last!
        return startTime
    }

    /// UI Actions
    @IBAction func beginTimeSettingAction(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
        let currentTimeInterval = Date().timeIntervalSince1970
        let startTimeInterval = self.beginAtTime!.timeIntervalSince1970
        if startTimeInterval < currentTimeInterval {
            self.datePicker.dateP.minimumDate = Date()
            self.datePicker.dateP.maximumDate = nil
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.datePicker.setNowTime(dateFormate.string(from: Date()))
        } else {
            self.datePicker.dateP.minimumDate = self.beginAtTime
            self.datePicker.dateP.maximumDate = nil
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.datePicker.setNowTime(dateFormate.string(from: self.beginAtTime!))
        }
        self.view.addSubview(self.datePicker)
    }
    
    @IBAction func endTimeSettingAction(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
        let minEndTime = self.beginAtTime!.addingTimeInterval(1800.0)
        let maxEndTime = self.beginAtTime!.addingTimeInterval(7200.0)
        self.datePicker.dateP.minimumDate = minEndTime
        self.datePicker.dateP.maximumDate = maxEndTime
        let endTimeInterval = self.endAtTime!.timeIntervalSince1970
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if (endTimeInterval >= minEndTime.timeIntervalSince1970 && endTimeInterval <= maxEndTime.timeIntervalSince1970) {
            self.datePicker.setNowTime(dateFormate.string(from: self.endAtTime!))
        } else {
            self.endAtTime = minEndTime
            self.datePicker.setNowTime(dateFormate.string(from: self.endAtTime!))
        }
        self.view.addSubview(self.datePicker)
    }
    
    @IBAction func muteTypeSwitchAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        self.muteType = sender.isOn ? 1 : 0
    }
    
    @IBAction func passwordSwitchAction(_ sender: UISwitch) {
        self.view.endEditing(true)
        self.password_view.isHidden = !sender.isOn
        self.password_field.text = nil
    }
    
    @IBAction func reserveSubmitAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormate.timeZone = TimeZone(abbreviation:"UTC")!
        let startTimeString:String = dateFormate.string(from: self.beginAtTime!)
        let endTimeString:String = dateFormate.string(from: self.endAtTime!)
        MeetingAPIRequest.meetingCreate(name: self.meeing_title_field.text!, beginAt: startTimeString, endAt: endTimeString, muteType: self.muteType, password: self.password_field.text ?? nil) {[weak self] response in
            if response != nil {
                self!.navigationController?.popViewController(animated: true)
            } else {
                print("meeting create error")
            }
        }
    }
    
    /// check time
    func checkTimeAndReserveMeetingContent() -> Bool {
        let currentTimeInterval = Date().timeIntervalSince1970
        let startTimeInterval = self.beginAtTime!.timeIntervalSince1970
        if (startTimeInterval < currentTimeInterval - 60.0) {
            return false
        } else {
            return true
        }
    }
    
    /// text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(self.meeing_title_field) {
            if (textField.text == nil || textField.text!.isEmpty) {
                textField.text = "Personal Meeting"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /// BHXPikerViewDelegate
    func time(_ view: BHXPikerView!, determine date: Date!) {
        self.datePicker.removeFromSuperview()
        if self.begin_time_btn.isSelected {
            self.begin_time_btn.isSelected = false
            self.beginAtTime = date
            self.begin_time_btn.setTitle(self.calculateDate(date: date), for: .normal)
            let startTimeInterval = date.timeIntervalSince1970
            let endTimeInterval = self.endAtTime?.timeIntervalSince1970
            if (endTimeInterval! < startTimeInterval || (endTimeInterval! - startTimeInterval) < 1800.0) {
                self.endAtTime = self.beginAtTime!.addingTimeInterval(1800.0)
                self.end_time_btn.setTitle(self.calculateDate(date: self.endAtTime!), for: .normal)
            }
            self.reserve_btn.isEnabled = self.checkTimeAndReserveMeetingContent()
        } else {
            self.end_time_btn.isSelected = false
            self.endAtTime = date
            self.end_time_btn.setTitle(self.calculateDate(date: self.endAtTime!), for: .normal)
            self.reserve_btn.isEnabled = self.checkTimeAndReserveMeetingContent()
        }
    }
}
