//
//  MemberListViewCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/27.
//

import UIKit

class MemberListViewCell: UITableViewCell {
    
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var user_role: UILabel!
    @IBOutlet weak var audio_btn: UIButton!
    @IBOutlet weak var video_btn: UIButton!
    @IBOutlet weak var hand_btn: UIButton!
    @IBOutlet weak var remove_btn: UIButton!
    
    weak var delegate: MemberListItemDelegate?
    var info:UserInfoStruct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.audio_btn.imageView?.contentMode = .scaleAspectFit
        self.video_btn.imageView?.contentMode = .scaleAspectFit
    }

    @IBAction func audioChangeAction(_ sender: UIButton) {
        if (SampleMeetingManager.defaultManager().user_info?.user_id!)! == self.info?.user_id {
            self.delegate?.operationUserStatus("audio", value: sender.isSelected, cell: self)
        } else {
            if SampleMeetingManager.defaultManager().user_info?.role != "attendee" {
                self.delegate?.operationUserStatus("audio", value: sender.isSelected, cell: self)
            }
        }
    }
    
    @IBAction func videoChangeAction(_ sender: UIButton) {
        if (SampleMeetingManager.defaultManager().user_info?.user_id!)! == self.info?.user_id {
            self.delegate?.operationUserStatus("video", value: sender.isSelected, cell: self)
        } else {
            return
        }
    }
    
    @IBAction func handAckAction(_ sender: UIButton) {
        if (SampleMeetingManager.defaultManager().user_info?.user_id!)! == self.info?.user_id {
            self.delegate?.operationUserStatus("hand", value: true, cell: self)
        } else {
            if SampleMeetingManager.defaultManager().user_info?.role != "attendee" {
                self.delegate?.operationUserStatus("hand", value: true, cell: self)
            }
        }
        
    }
    
    @IBAction func removeUserAction(_ sender: UIButton) {
        if SampleMeetingManager.defaultManager().user_info?.role != "attendee" {
            self.delegate?.operationUserStatus("kick_out", value: true, cell: self)
        }
    }
    
    func setData(_ userInfo: UserInfoStruct) {
        self.info = userInfo
        let loginUserId: Int32 = (SampleMeetingManager.defaultManager().user_info?.user_id!)!
        if userInfo.user_id == loginUserId {
            if userInfo.role != "attendee" {
                self.remove_btn.isHidden = true
                self.hand_btn.isEnabled = true
            } else {
                self.remove_btn.isHidden = true
                self.hand_btn.isEnabled = false
            }
        } else {
            if userInfo.role != "attendee" {
                self.remove_btn.isHidden = false
                self.hand_btn.isEnabled = true
            } else {
                self.remove_btn.isHidden = true
                self.hand_btn.isEnabled = false
            }
        }
        self.hand_btn.isHidden = userInfo.hand != nil ? !userInfo.hand! : true
        self.audio_btn.isSelected = userInfo.audio != nil ? !userInfo.audio! : true
        self.video_btn.isSelected = userInfo.video != nil ? !userInfo.video! : true
        
        self.user_name.text = userInfo.name
        self.user_role.text = userInfo.role! + " (group:" + String(userInfo.groupId!) + ")"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol MemberListItemDelegate: NSObjectProtocol {
    func operationUserStatus(_ power_name: String, value: Bool, cell: MemberListViewCell)
}
