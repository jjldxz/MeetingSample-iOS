//
//  GroupMemberChooseListCell.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/30.
//

import UIKit

class GroupMemberChooseListCell: UITableViewCell {

    @IBOutlet weak var selector_btn: UIButton!
    @IBOutlet weak var userInfo_label: UILabel!
    
    weak var delegate :GroupMemberChooseListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.GroupMemberChooseListDidSelected(sender.isSelected, cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol GroupMemberChooseListCellDelegate: NSObjectProtocol {
    func GroupMemberChooseListDidSelected(_ selected: Bool, cell: GroupMemberChooseListCell)
}
