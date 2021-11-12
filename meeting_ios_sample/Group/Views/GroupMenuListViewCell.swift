//
//  GroupMenuListViewCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/27.
//

import UIKit

class GroupMenuListViewCell: UICollectionViewCell {

    
    @IBOutlet weak var menu_title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func settingTitle(_ title: String) {
        self.menu_title.text = title
    }

}
