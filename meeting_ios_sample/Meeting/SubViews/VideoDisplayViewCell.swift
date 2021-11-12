//
//  VideoDisplayViewCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/6.
//

import UIKit

class VideoDisplayViewCell: UICollectionViewCell {

    @IBOutlet weak var audioStatusIcon: UIImageView!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var noSignal_view: UIView!
    
    @IBOutlet weak var videoView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func settingVideoInfoData(_ data:UserInfoStruct) {
        audioStatusIcon.image = (data.audio ?? false) ? UIImage.init(named: "meeting_no_mute_icon") : UIImage.init(named: "meeting_mute_icon")
        noSignal_view.isHidden = (data.video ?? false)
        username_label.text = data.name
    }
}
