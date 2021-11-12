//
//  GroupChooseMemberView.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/30.
//

import UIKit

class GroupChooseMemberView: UIView, UITableViewDelegate, UITableViewDataSource, GroupMemberChooseListCellDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var memberList: UITableView!
    var members_data:    Array<UserInfoStruct>?
    var selected_users_list:    Array<UserInfoStruct> = Array.init()
    var groupInfo: MeetingGroupInfo?
    weak var delegate: GroupChooseMemberProtocol?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .white.withAlphaComponent(0.7)
        
        self.memberList.dataSource = self
        self.memberList.delegate = self
        self.memberList.register(UINib.init(nibName: "GroupMemberChooseListCell", bundle: nil), forCellReuseIdentifier: "kGroupMemberChooseListCell")
        self.memberList.backgroundColor = .white
        
        self.backView.layer.cornerRadius = 5.0
        self.backView.layer.borderWidth = 1.0
        self.backView.layer.borderColor = UIColor.gray.cgColor
        self.backView.layer.masksToBounds = true
    }
    
    func settingGroupInfoAndAllMembers(_ info: MeetingGroupInfo, members: Array<UserInfoStruct>) {
        self.groupInfo = info
        self.members_data = members
        self.memberList.reloadData()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.animationHidden { completed in
            
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        if self.selected_users_list.count > 0 {
            self.delegate?.chooseMemberAction(self.selected_users_list, group: groupInfo!)
        }
        self.animationHidden { completed in
            
        }
    }
    
    func animationShow(_ subview: UIView, completed: @escaping (_ completed: Bool) -> Void) {
        self.center = CGPoint.init(x: screenWidth * 0.5, y: screenHeight * 1.5)
        subview.addSubview(self)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.center = CGPoint.init(x: screenWidth * 0.5, y: screenHeight * 0.5)
            self.layoutIfNeeded()
        } completion: { finished in
            completed(finished)
        }
    }
    
    func animationHidden(_ completed: @escaping (_ completed: Bool) -> Void) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.center = CGPoint.init(x: screenWidth * 0.5, y: screenHeight * 1.5)
        } completion: { finished in
            completed(finished)
            self.removeFromSuperview()
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard members_data != nil else {
            return 0
        }
        return members_data!.count
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GroupMemberChooseListCell = tableView.dequeueReusableCell(withIdentifier: "kGroupMemberChooseListCell", for: indexPath) as! GroupMemberChooseListCell
        let info: UserInfoStruct = members_data![indexPath.row]
        cell.userInfo_label.text = info.name ?? "user_" + String(info.user_id!)
        if (selected_users_list.count > 0 && selected_users_list.contains(where: ({$0.user_id == info.user_id}))) {
            cell.selector_btn.isSelected = true
        } else {
            cell.selector_btn.isSelected = false
        }
        cell.delegate = self
        return cell
    }
    
    //MARK: -
    func GroupMemberChooseListDidSelected(_ selected: Bool, cell: GroupMemberChooseListCell) {
        let index = self.memberList.indexPath(for: cell)!
        let info: UserInfoStruct = members_data![index.row]
        if cell.selector_btn.isSelected {
            selected_users_list.append(info)
        } else {
            selected_users_list.removeAll(where: ({$0.user_id == info.user_id}))
        }
    }
}

protocol GroupChooseMemberProtocol:NSObject {
    func chooseMemberAction(_ infos: Array<UserInfoStruct>, group: MeetingGroupInfo)
}

extension GroupChooseMemberView {
    public class func initInstanceFromXib() -> GroupChooseMemberView {
        return Bundle.main.loadNibNamed("GroupChooseMember", owner: self, options: nil)?.last as! GroupChooseMemberView
    }
}
