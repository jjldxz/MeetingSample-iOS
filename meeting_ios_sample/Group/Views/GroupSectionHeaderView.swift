//
//  GroupSectionHeaderView.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/29.
//

import UIKit

class GroupSectionHeaderView: UITableViewHeaderFooterView, UITextFieldDelegate {

    var titleLabel = UITextField.init()
    var add_btn = UIButton.init(type: .custom)
    var remove_btn = UIButton.init(type: .custom)
    
    var groupData: MeetingGroupInfo?
    weak var delegate: GroupSectionAddMemberProtocol?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        titleLabel.textColor = .black
        titleLabel.delegate = self
        titleLabel.returnKeyType = .done
        
        add_btn.setTitle("add", for: .normal)
        add_btn.setTitleColor(.blue, for: .normal)
        add_btn.addTarget(self, action: #selector(addMemberAction), for: .touchUpInside)
        
        remove_btn.setTitle("remove", for: .normal)
        remove_btn.setTitleColor(.red, for: .normal)
        remove_btn.addTarget(self, action: #selector(removeGroupAction), for: .touchUpInside)
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.add_btn)
        self.contentView.addSubview(self.remove_btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.bounds = CGRect.init(x: 0, y: 0, width: 180, height: 20)
        titleLabel.center = CGPoint.init(x: 16 + 90, y: self.height * 0.5)
        
        add_btn.bounds = CGRect.init(x: 0, y: 0, width: 60, height: 30)
        add_btn.center = CGPoint.init(x: self.width - 46.0, y: self.height * 0.5)
        
        remove_btn.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 30)
        remove_btn.center = CGPoint.init(x: add_btn.left - 60, y: self.height * 0.5)
    }
    
    func settingGroupData(_ data: MeetingGroupInfo?) {
        if data == nil {
            self.titleLabel.text = "main room"
            add_btn.isHidden = true
            remove_btn.isHidden = true
        } else {
            add_btn.isHidden = false
            remove_btn.isHidden = false
            self.groupData = data!
            self.titleLabel.text = data!.name ?? "group_" + String(data!.id!)
        }
        
    }
    
    @objc func addMemberAction() {
        guard self.groupData != nil else {
            return
        }
        self.delegate?.groupAddNewMemberAction(self.groupData!)
    }
    
    @objc func removeGroupAction() {
        guard self.groupData != nil else {
            return
        }
        self.delegate?.groupRemoveCurrentGroup(self.groupData!)
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.groupChangedGroupName(textField.text, info: self.groupData!)
    }
    
}

protocol GroupSectionAddMemberProtocol: NSObject {
    func groupAddNewMemberAction(_ info: MeetingGroupInfo)
    func groupRemoveCurrentGroup(_ info: MeetingGroupInfo)
    func groupChangedGroupName(_ name: String?, info: MeetingGroupInfo)
}
