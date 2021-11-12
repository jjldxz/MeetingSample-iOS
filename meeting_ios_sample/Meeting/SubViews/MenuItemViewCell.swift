//
//  MenuItemViewCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/6.
//

import UIKit

class MenuItemViewCell: UICollectionViewCell {

    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuTitle_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func settingMenuType(type: CLS_MenuItem, status:Bool) {
        switch type {
        case .audio:
            if status {
                self.menuIcon.image = UIImage.init(named: "meeting_no_mute_icon")
                self.menuTitle_label.text = "mute"
            } else {
                self.menuIcon.image = UIImage.init(named: "meeting_mute_icon")
                self.menuTitle_label.text = "unmute"
            }
            break
        case .video:
            if status {
                self.menuIcon.image = UIImage.init(named: "ia")
                self.menuTitle_label.text = "carmera"
            } else {
                self.menuIcon.image = UIImage.init(named: "meeting_no_record_icon")
                self.menuTitle_label.text = "carmera"
            }
            break
        case .share:
            if status {
                self.menuIcon.image = UIImage.init(named: "meeting_screenshare_icon")
                self.menuTitle_label.text = "share"
            } else {
                self.menuIcon.image = UIImage.init(named: "meeting_no_screenshare_icon")
                self.menuTitle_label.text = "sharing"
            }
            break
        case .members:
            self.menuIcon.image = UIImage.init(named: "ip")
            self.menuTitle_label.text = "members"
            break
        case .more:
            self.menuIcon.image = UIImage.init(named: "bottom_more")
            self.menuTitle_label.text = "more"
            break
        }
    }

}
