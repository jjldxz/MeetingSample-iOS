//
//  MemberViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/10/8.
//

import UIKit

class MemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, MemberListItemDelegate {

    @IBOutlet weak var member_list: UITableView!
    @IBOutlet weak var menu_list: UICollectionView!
    @IBOutlet weak var title_label: UILabel!
    
    var members:Array<UserInfoStruct> = Array.init()
    var menus:Array<String> = Array.init()
    weak var delegate: MemberListViewControllerDelegate?
    var is_host: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.member_list.delegate = self
        self.member_list.dataSource = self
        self.member_list.register(UINib.init(nibName: "MemberListViewCell", bundle: nil), forCellReuseIdentifier: "kMemberListViewCell")
        
        self.menu_list.delegate = self
        self.menu_list.dataSource = self
        self.menu_list.register(UINib.init(nibName: "MemberListMenuCell", bundle: nil), forCellWithReuseIdentifier: "kMemberListMenuCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard (self.member_list != nil) else {
            return
        }
        self.member_list.reloadData()
    }
    
    func settingDatas(_ members_info:Array<UserInfoStruct>, isHost: Bool) {
        self.is_host = isHost
        if isHost {
            menus = ["all mute", "all unmute"]
        } else {
            menus = Array.init()
        }
        self.menu_list?.reloadData()
        
        guard members_info.count > 0 else {
            return
        }
        self.members.removeAll()
        self.members.append(contentsOf: members_info)
        guard (self.member_list != nil) else {
            return
        }
        self.member_list.reloadData()
    }
    
    func upgradeUserInfo(_ user_id: Int32, update_power: String, value: Any) {
        let infos = self.members.filter(({$0.user_id == user_id}))
        guard (infos.count > 0) else {
            return
        }
        var user_info = infos.first
        let index = self.members.firstIndex(of: user_info!)
        switch update_power {
        case "audio":
            user_info?.audio = (value as! Bool)
            break
        case "video":
            user_info?.video = (value as! Bool)
            break
        case "hand":
            user_info?.hand = (value as! Bool)
            break
        case "role":
            user_info?.role = (value as! String)
            break
        case "name":
            user_info?.name = (value as! String)
            break
        default:
            break
        }
        self.members[index!] = user_info!
        guard (self.member_list != nil) else {
            return
        }
        self.member_list.reloadData()
    }
    
    func memberLeave(_ userId: Int32) {
        let infos = self.members.filter(({$0.user_id == userId}))
        guard (infos.count > 0) else {
            return
        }
        let user_info = infos.first
        let index = self.members.firstIndex(of: user_info!)!
        self.members.remove(at: index)
        guard (self.member_list != nil) else {
            return
        }
        self.member_list.reloadData()
    }

    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showRenameAlert(_ userInfo: UserInfoStruct) {
        let alert = UIAlertController.init(title: "Rename", message: "input a new nickname", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "input rename content"
        }
        alert.addAction(UIAlertAction.init(title: "submit", style: .default, handler: { action in
            let field = alert.textFields?.first
            guard (field != nil && field!.text != nil && !field!.text!.isEmpty) else {
                return
            }
            self.delegate?.memberListOperationData("name", value: field!.text!, user_id: userInfo.user_id!)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberListViewCell = tableView.dequeueReusableCell(withIdentifier: "kMemberListViewCell", for: indexPath) as! MemberListViewCell
        cell.delegate = self
        cell.setData(members[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.is_host != nil else {
            return
        }
        if self.is_host! {
            let user_info = members[indexPath.row]
            if user_info.user_id != SampleMeetingManager.defaultManager().user_info?.user_id {
                let alert = UIAlertController.init(title: "Operation Menu", message: "change member role or rename", preferredStyle: .alert)
                switch user_info.role! {
                case "co-host":
                    alert.addAction(UIAlertAction.init(title: "remove 'co-host'", style: .default, handler: { action in
                        self.delegate?.memberListOperationData("role", value: false, user_id: user_info.user_id!)
                    }))
                    break
                case "attendee":
                    alert.addAction(UIAlertAction.init(title: "give 'co-host'", style: .default, handler: { action in
                        self.delegate?.memberListOperationData("role", value: true, user_id: user_info.user_id!)
                    }))
                    break
                default: break
                }
                alert.addAction(UIAlertAction.init(title: "re-name", style: .default, handler: { action in
                    alert.dismiss(animated: true) {
                        self.showRenameAlert(user_info)
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "close", style: .default, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                return
            }
        } else {
            return
        }
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MemberListMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "kMemberListMenuCell", for: indexPath) as! MemberListMenuCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menu_type = menus[indexPath.row]
        switch menu_type {
        case "all mute":
            let alert = UIAlertController.init(title: "ALL MUTE", message: "you will mute all member's audio stream, make sure", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "mute with member change", style: .default, handler: { action in
                self.delegate?.memberListAllMemberMute(true, enableChange: true)
            }))
            alert.addAction(UIAlertAction.init(title: "mute without member change", style: .default, handler: { action in
                self.delegate?.memberListAllMemberMute(true, enableChange: false)
            }))
            alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            break
        case "all umnute":
            let alert = UIAlertController.init(title: "ALL UNMUTE", message: "you will unmute all member's audio stream, make sure", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "unmute", style: .default, handler: { action in
                self.delegate?.memberListAllMemberMute(false, enableChange: true)
            }))
            alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
            break
        default: break
        }
    }
    
    // MARK: - MemberListViewCellDelegate
    func operationUserStatus(_ power_name: String, value: Bool, cell: MemberListViewCell) {
        let index = self.member_list.indexPath(for: cell)!
        let user_info: UserInfoStruct = self.members[index.row]
        self.delegate?.memberListOperationData(power_name, value: value, user_id: user_info.user_id!)
    }

}

protocol MemberListViewControllerDelegate: NSObjectProtocol {
    func memberListOperationData(_ power: String, value: Any, user_id: Int32)
    func memberListAllMemberMute(_ status: Bool, enableChange: Bool)
}
