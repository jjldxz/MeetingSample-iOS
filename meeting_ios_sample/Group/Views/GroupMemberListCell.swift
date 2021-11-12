//
//  GroupMemberListCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/27.
//

import UIKit

class GroupMemberListCell: UITableViewCell {

    @IBOutlet weak var move_btn: UIButton!
    @IBOutlet weak var name_label: UILabel!
    typealias moveActionCallback = (_ info: UserInfoStruct?) -> ()
    var userInfo: UserInfoStruct?
    var moveBlock: moveActionCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func moveAction(_ sender: UIButton) {
        if moveBlock != nil {
            moveBlock!(self.userInfo)
        }
    }
    
    func settingUserInfo(_ info: UserInfoStruct) {
        self.userInfo = info
        self.name_label.text = info.name ?? ("user_" + String(info.user_id!))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
