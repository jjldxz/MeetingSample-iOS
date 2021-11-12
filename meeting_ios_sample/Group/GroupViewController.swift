//
//  GroupViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/26.
//

import UIKit
import HandyJSON

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GroupSectionAddMemberProtocol, GroupChooseMemberProtocol {
        
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var member_list: UITableView!
    @IBOutlet weak var member_menu: UICollectionView!
    
    var group_data: Dictionary<Int, MeetingGroupInfo>?
    var allMembersInfo: Array<UserInfoStruct>?
    var menu_list: Array<Any>?
    var room_id: Int32?
    var isEdit: Bool = false
    var meeting_info :MeetingJoinInfo?
    var group_status: Bool = false
    var list_keys: Array<MeetingGroupInfo>?
    weak var delegate: GroupVCOperationProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.member_list.delegate = self
        self.member_list.dataSource = self
        self.member_list.register(UINib.init(nibName: "GroupMemberListCell", bundle: nil), forCellReuseIdentifier: "kGroupMemberListCell")
        self.member_list.register(GroupSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "kGroupSectionHeaderView")
        
        self.member_menu.delegate = self
        self.member_menu.dataSource = self
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.member_menu.setCollectionViewLayout(layout, animated: true)
        self.member_menu.register(UINib.init(nibName: "GroupMenuListViewCell", bundle: nil), forCellWithReuseIdentifier: "kGroupMenuListViewCell")
        // Do any additional setup after loading the view.
        guard self.meeting_info != nil else {
            return
        }
        self.settingMeeting(self.meeting_info!, groupStatus: self.group_status)
        self.member_list.reloadData()
        self.title_label.text = "Member List ( " + String(self.allMembersInfo!.count) + " )"
    }
    
    open func upgradeGroupInfo(_ groupInfo: Dictionary<Int, MeetingGroupInfo>?, all_members: Array<UserInfoStruct>) {
        if groupInfo != nil {
            self.group_data = groupInfo!
            list_keys = Array.init(groupInfo!.values)
        } else {
            list_keys = nil
            self.group_data = nil
        }
        self.allMembersInfo = all_members
        if self.member_list != nil {
            self.member_list.reloadData()
        }
    }
    
    open func upgradeMeetingMembers(_ user: UserInfoStruct, status: String) {
        switch status {
        case "join":
            if self.allMembersInfo!.contains(where: ({$0.user_id == user.user_id})) == false {
                self.allMembersInfo!.append(user)
                self.title_label.text = "Member List ( " + String(self.allMembersInfo!.count) + " )"
            } else {
                self.upgradeMeetingMembers(user, status: "update")
            }
            break
        case "leave":
            self.allMembersInfo?.removeAll(where: ({$0.user_id == user.user_id}))
            self.title_label.text = "Member List ( " + String(self.allMembersInfo!.count) + " )"
            break
        case "update":
            let index = self.allMembersInfo!.firstIndex(where: ({$0.user_id == user.user_id}))!
            self.allMembersInfo![index] = user
            break
        default:
            break
        }
    }
    
    open func settingMeeting(_ info: MeetingJoinInfo, groupStatus: Bool) {
        self.meeting_info = info
        self.room_id = info.meeting_code
        self.group_status = groupStatus
        if info.is_admin! {
            guard group_data != nil else {
                self.member_menu?.isHidden = false
                menu_list = ["new"]
                self.member_menu?.reloadData()
                return
            }
            self.member_menu?.isHidden = false
            menu_list = ["edit", "stop", "broadcast"]
            return
        } else {
            guard group_data != nil else {
                self.member_menu?.isHidden = true
                menu_list = nil
                self.member_menu?.reloadData()
                return
            }
            if SampleMeetingManager.defaultManager().user_info?.groupId != 0 {
                menu_list = ["leave", "call"]
            } else {
                menu_list = []
            }
            self.member_menu?.isHidden = false
            self.member_menu?.reloadData()
            return
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGroups(_ count: Int) {
        guard count > 0 else {
            return
        }
        var index = 1
        group_data = Dictionary.init()
        list_keys = Array.init()
        while index <= count {
            let group_info = MeetingGroupInfo.init(id: index, name: "group_" + String(index), users: Array.init())
            group_data![index] = group_info
            list_keys?.append(group_info)
            index += 1
        }
        self.member_list.reloadData()
    }
    
    //MARK: - tableViewDelegate, tableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        guard list_keys != nil else {
            return 1
        }
        return list_keys!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard list_keys != nil else {
            return self.allMembersInfo!.count
        }
        let group_info:MeetingGroupInfo = list_keys![section]
        return group_info.users!.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let groupSectionView: GroupSectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "kGroupSectionHeaderView") as! GroupSectionHeaderView
        groupSectionView.delegate = self
        guard list_keys != nil else {
            groupSectionView.settingGroupData(nil)
            return groupSectionView
        }
        let group_info:MeetingGroupInfo = list_keys![section]
        groupSectionView.settingGroupData(group_info)
        return groupSectionView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:GroupMemberListCell = tableView.dequeueReusableCell(withIdentifier: "kGroupMemberListCell", for: indexPath) as! GroupMemberListCell
        if group_data != nil {
            let group_info:MeetingGroupInfo = list_keys![indexPath.section]
            cell.move_btn.isHidden = !self.isEdit
            guard Int32(group_info.users!.count) > indexPath.row else {
                return cell
            }
            let userId = (group_info.users![indexPath.row])
            let users:Array<UserInfoStruct> = (self.allMembersInfo?.filter(({$0.user_id! == userId})))!
            cell.settingUserInfo(users.first!)
        } else {
            let user_info = allMembersInfo![indexPath.row]
            cell.move_btn.isHidden = true
            cell.settingUserInfo(user_info)
        }
        cell.moveBlock = { [weak self] info in
            let alert = UIAlertController.init(title: "Member Move", message: "move member to target group", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "please input move to group number"
                textField.keyboardType = .asciiCapableNumberPad
            }
            alert.addAction(UIAlertAction.init(title: "submit", style: .default, handler: { action in
                let groupNumberText:String = alert.textFields!.first!.text!
                let number: Int32 = Int32(groupNumberText) ?? 0
                guard (number == 0 || self!.group_data![Int(number)] != nil) else {
                    return
                }
                self?.delegate?.groupVCMoveUserToGroup(Int(number), fromGroupId: cell.userInfo!.groupId!, users: [cell.userInfo!.user_id!])
            }))
            alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    //MARK:- collectionViewDelegate, collectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu_list == nil ? 0 : menu_list!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GroupMenuListViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "kGroupMenuListViewCell", for: indexPath) as! GroupMenuListViewCell
        let title_string: String = menu_list![indexPath.row] as! String
        cell.settingTitle(title_string)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.width / CGFloat(self.menu_list?.count ?? 1), height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.menu_list != nil else {
            return
        }
        guard indexPath.row < self.menu_list!.count else {
            return
        }
        
        let title: String = self.menu_list![indexPath.row] as! String
        switch title {
        case "new":
            if (self.group_data != nil && self.group_data!.count > 0) {
                var values:Array<Dictionary<String, Any>> = Array.init()
                for obj in self.group_data!.values {
                    values.append(obj.convertToDict()!)
                }
                debugPrint(values as Any)
                self.menu_list = ["edit", "stop", "broadcast"]
                self.member_menu.reloadData()
                self.delegate?.groupStart((self.group_data)!)
            } else {
                debugPrint("group breakout infois empty")
                let alert = UIAlertController.init(title: "Create Group", message: "please input breakout count", preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.keyboardType = .asciiCapableNumberPad
                    textField.placeholder = "input count will less " + String(self.allMembersInfo!.count)
                }
                alert.addAction(UIAlertAction.init(title: "Submit", style: .default, handler: { action in
                    let field = alert.textFields!.first
                    let number = ((field!.text ?? "0") as NSString).intValue
                    self.view.endEditing(true)
                    if number <= self.allMembersInfo!.count {
                        self.menu_list = ["create"]
                        self.member_menu.reloadData()
                        self.createGroups(Int(number))
                    } else {
                        debugPrint("group count have to less member count")
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            break
        case "create":
            if (self.group_data != nil && self.group_data!.count > 0) {
                var values:Array<Dictionary<String, Any>> = Array.init()
                for obj in self.group_data!.values {
                    values.append(obj.convertToDict()!)
                }
                debugPrint(values as Any)
                self.menu_list = ["edit", "stop", "broadcast"]
                self.member_menu.reloadData()
                self.delegate?.groupStart((self.group_data)!)
            }
            break
        case "edit":
            self.isEdit = true
            self.member_list.reloadData()
            break
        case "stop":
            self.upgradeGroupInfo(nil, all_members: self.allMembersInfo!)
            self.menu_list = ["new"]
            self.member_menu.reloadData()
            self.member_list.reloadData()
            self.delegate?.groupStop()
            break
        case "leave":
            self.dismiss(animated: true) { [weak self] in
                self!.delegate?.groupDidDismiss()
            }
            break
        case "broadcast":
            let alert = UIAlertController.init(title: "Broadcast", message: "send broadcast message", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "input broadcast message"
            }
            alert.addAction(UIAlertAction.init(title: "Send", style: .default, handler: { action in
                let field = alert.textFields!.first
                guard field?.text?.isEmpty == false else {
                    return
                }
                self.delegate?.groupHostSendBroadcastMessage(field?.text)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
            break
        case "call":
            let alert = UIAlertController.init(title: "Call Host", message: "if your submit, host and co-host will receive a call message", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Submit", style: .default, handler: { action in
                self.delegate?.groupMemberCallHost(SampleMeetingManager.defaultManager().user_info!.groupId!)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    // MARK: - GroupSectionAddMemberProtocol
    func groupAddNewMemberAction(_ info: MeetingGroupInfo) {

        let add_member_view: GroupChooseMemberView = GroupChooseMemberView.initInstanceFromXib()
        add_member_view.bounds = CGRect.init(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight)
        add_member_view.center = CGPoint.init(x: screenWidth * 0.5, y: screenHeight * 1.5)
        add_member_view.delegate = self
        add_member_view.settingGroupInfoAndAllMembers(info, members: self.allMembersInfo!)
        self.view.addSubview(add_member_view)
        add_member_view.animationShow(self.view) { completed in
            
        }
    }
    
    func groupChangedGroupName(_ name: String?, info: MeetingGroupInfo) {
        var group_info = self.group_data![info.id!]!
        group_info.name = name
        self.group_data![info.id!] = group_info
    }
    
    func groupRemoveCurrentGroup(_ info: MeetingGroupInfo) {
        self.delegate?.groupVCMoveUserToGroup(0, fromGroupId: (info.id)!, users: (info.users)!)
    }

    // MARK: - GroupChooseMemberProtocol
    func chooseMemberAction(_ infos: Array<UserInfoStruct>, group: MeetingGroupInfo) {
        guard infos.count > 0 else {
            return
        }
        var usersId = Array<Int32>.init()
        for obj in infos {
            usersId.append(obj.user_id!)
        }
        if self.isEdit {
            self.delegate?.groupVCMoveUserToGroup(group.id!, fromGroupId: group.id!, users: usersId)
        } else {
            self.group_data![group.id!]?.users?.append(contentsOf: usersId)
            self.upgradeGroupInfo(self.group_data, all_members: self.allMembersInfo!)
            self.member_list.reloadData()
        }
    }
}


protocol GroupVCOperationProtocol: NSObjectProtocol {
    func groupVCMoveUserToGroup(_ targetGroupId: Int, fromGroupId: Int, users: Array<Int32>)
    func groupStart(_ groupsInfo: Dictionary<Int, MeetingGroupInfo>)
    func groupStop()
    func groupMemberCallHost(_ groupId: Int)
    func groupHostSendBroadcastMessage(_ message: String?)
    func groupDidDismiss()
}
