//
//  MeetingViewController.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/6.
//

import UIKit
import ReplayKit

class MeetingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MeetingManagerDelegate, WhiteBroadVCDelegate, MeetingChatViewDelegate, GroupVCOperationProtocol, MemberListViewControllerDelegate, ScreenShareViewControllerDelegate {
    
    @IBOutlet weak var speaker_btn: UIButton!
    @IBOutlet weak var camera_btn: UIButton!
    @IBOutlet weak var meetingTitle_btn: UIButton!
    @IBOutlet weak var duration_label: UILabel!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var videoList_view: UICollectionView!
    @IBOutlet weak var menuList_view: UICollectionView!
    
    var manager = SampleMeetingManager.defaultManager()
    var whiteboardVC:WhiteBroadViewController = WhiteBroadViewController.init()
    var chatVC:MeetingChatViewController = MeetingChatViewController.init()
    var groupVC:GroupViewController = GroupViewController.init()
    var memberVC:MemberViewController = MemberViewController.init()
    var screenShareVC:ScreenShareViewController = ScreenShareViewController.init()
    
    var meetingMembers:Array<UserInfoStruct> = Array<UserInfoStruct>.init()
    var meetingGroupUsers:Array<UserInfoStruct> = Array<UserInfoStruct>.init()
    let meetingMenuList:Array<CLS_MenuItem> = [.audio, .video, .share, .members, .more]
    var user_info: UserInfoStruct?
    var meetingInfo:meetingInfoStruct?
    var meetingSettingInfo:MeetingJoinInfo?
    var meetingTimer: Timer?
    var duration = 0
    let broadcastView = RPSystemBroadcastPickerView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.whiteboardVC.delegate = self
        self.whiteboardVC.modalPresentationStyle = .fullScreen
        let chat_navi = RootNavigationController.init(rootViewController: self.chatVC)
        self.chatVC.delegate = self
        chat_navi.modalPresentationStyle = .fullScreen
        self.groupVC.modalPresentationStyle = .fullScreen
        self.groupVC.delegate = self
        self.memberVC.modalPresentationStyle = .fullScreen
        self.memberVC.delegate = self
        self.screenShareVC.modalPresentationStyle = .fullScreen
        self.screenShareVC.delegate = self
        self.broadcastView.preferredExtension = "com.OpenPlatformTeam.meetingSample.MeetingSampleShare"
        
        let videoLayout = UICollectionViewFlowLayout.init()
        videoLayout.scrollDirection = .vertical
        videoLayout.minimumLineSpacing = 1.0
        videoLayout.minimumInteritemSpacing = 1.0
        // Do any additional setup after loading the view.
        self.videoList_view.setCollectionViewLayout(videoLayout, animated: true)
        self.videoList_view.register(UINib.init(nibName: "VideoDisplayViewCell", bundle: nil), forCellWithReuseIdentifier: "kVideoDisplayViewCell")
        self.videoList_view.delegate = self
        self.videoList_view.dataSource = self
        
        let menuLayout = UICollectionViewFlowLayout.init()
        menuLayout.scrollDirection = .horizontal
        menuLayout.minimumLineSpacing = 0.0
        menuLayout.minimumInteritemSpacing = 0.5
        self.menuList_view.setCollectionViewLayout(menuLayout, animated: true)
        self.menuList_view.register(UINib.init(nibName: "MenuItemViewCell", bundle: nil), forCellWithReuseIdentifier: "kMenuItemViewCell")
        self.menuList_view.delegate = self
        self.menuList_view.dataSource = self
        
        self.meetingTitle_btn.setTitle(self.meetingInfo?.name, for: .normal)
        self.startTimer()
        
        for info in self.meetingMembers {
            self.videoList_view.register(UINib.init(nibName: "VideoDisplayViewCell", bundle: nil), forCellWithReuseIdentifier: "kVideoDisplayViewCell_" + String(info.user_id!))
        }
        self.videoList_view.reloadData()
        
    }
    
    func settingMeetingInfoMessage(info: meetingInfoStruct, setting_info: MeetingJoinInfo) {
        self.meetingInfo = info
        self.meetingSettingInfo = setting_info
        
        self.user_info = UserInfoStruct.init(name: LoginUserDataModel.manager.user_name, audio: setting_info.audio_status, video: setting_info.carmera_status, role: setting_info.is_admin! ? "host" : "attendee", groupId: 0, hand: false, share: "none", user_id: LoginUserDataModel.manager.userId)
        self.manager.joinMeeting(with: self.user_info!, meeting_info: info, meeting_setting: setting_info) { [weak self] success, error_message in
            if success == false {
                debugPrint(error_message as Any)
                self?.manager.leaveRoom()
                self?.meetingTimer?.invalidate()
                self?.dismiss(animated: true, completion: nil)
            } else {
                if ((self?.manager.isBreakout) != nil && self!.manager.isBreakout == true) {
                    self?.manager.readMeetingGroupInfo(with: { group_status in
                        if group_status {
                            debugPrint("current room had been break out")
                        }
                    })
                }
                self?.manager.readMeetingWhiteboardHistory()
            }
        }
        self.manager.delegate = self
        self.chatVC.settingManager(self.manager)
        self.chatVC.settingCurrentUserInfoMap(self.user_info!.convertToDict()!)
    }
    
    func showNoticeAlert(_ type: String, value: String, optionResult: @escaping(_ result: Bool, _ type: String) -> Void) {
        let alert = UIAlertController.init(title: "Notice", message: "your received manager [" + type + "] change to " + value + ", make sure to change!", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "do", style: .default, handler: { action in
            optionResult(true, type)
        }))
        alert.addAction(UIAlertAction.init(title: "undo", style: .cancel, handler: { action in
            optionResult(false, type)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - UI Actions
    @IBAction func speakerChangedAction(_ sender: UIButton) {
        self.manager.changedLocalSoundMode(sender.isSelected)
    }
    
    @IBAction func cameraChangedAction(_ sender: UIButton) {
        self.manager.switchLocalCamera()
    }
    
    @IBAction func meetingTitleTouchAction(_ sender: UIButton) {
        let alert_sheet = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
        self.present(alert_sheet, animated: true, completion: nil)
    }
    
    @IBAction func leaveMeetingAction(_ sender: UIButton) {
        let alert_sheet = UIAlertController.init(title: "leave meeting", message: "select your choise", preferredStyle: .actionSheet)
        alert_sheet.addAction(UIAlertAction.init(title: "Leave", style: .default, handler: { [weak self] action in
            self?.manager.leaveRoom()
            self?.meetingTimer?.invalidate()
            self?.dismiss(animated: true, completion: nil)
        }))
        if self.meetingSettingInfo!.is_admin! {
            alert_sheet.addAction(UIAlertAction.init(title: "Close", style: .default, handler: { action in
                MeetingAPIRequest.meetingStop(number: self.meetingInfo!.number!) { [weak self] response in
                    if response != nil {
                        self?.manager.closeRoom()
                        self?.meetingTimer?.invalidate()
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        debugPrint("meeting stop error")
                    }
                }
            }))
        }
        alert_sheet.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { action in
            alert_sheet.dismiss(animated: true, completion: nil)
        }))
        self.present(alert_sheet, animated: true, completion: nil)
    }
    
    // MARK: - 私有方法
    fileprivate func readLocalUserStatus(_ type: CLS_MenuItem) -> Bool? {
        switch type {
        case .audio:
            return self.manager.user_info?.audio
        case .video:
            return self.manager.user_info?.video
        default:
            return false
        }
    }
    
    fileprivate func upgradeMemberAttr(_ user: UserInfoStruct) {
        let result = self.meetingMembers.filter(({$0.user_id == user.user_id}))
        guard result.count > 0 else {
            self.meetingMembers.append(user)
            return
        }
        let index = self.meetingMembers.firstIndex(where: ({$0.user_id == user.user_id}))!
        self.meetingMembers[index] = user
        if (self.manager.isBreakout && self.meetingGroupUsers.count > 0) {
            let group_result = self.meetingGroupUsers.filter(({$0.user_id == user.user_id}))
            guard group_result.count > 0 else {
                return
            }
            let group_index = self.meetingGroupUsers.firstIndex(where: ({$0.user_id == user.user_id}))!
            self.meetingGroupUsers[group_index] = user
            self.groupVC.upgradeGroupInfo(self.manager.group, all_members: self.meetingMembers)
            self.manager.handleGroupRTCStream()
        }
    }
    
    fileprivate func searchSameGroupMembers(_ groupId: Int) -> Array<UserInfoStruct> {
        let result = self.meetingMembers.filter(({$0.groupId == groupId}))
        guard result.count > 0 else {
            return [self.user_info!]
        }
        return result
    }
    
    fileprivate func searchUser(with ext_id: Int32) -> UserInfoStruct? {
        let searchResult:[UserInfoStruct] = self.meetingMembers.filter {$0.user_id == ext_id}
        if searchResult.count > 0 {
            return searchResult.first
        } else {
             return nil
        }
    }
    
    fileprivate func userLeave(with userId: Int32) {
        let searchResult:[UserInfoStruct] = self.meetingMembers.filter {$0.user_id == userId}
        if searchResult.count > 0 {
            let info = searchResult.first!
            let index = self.meetingMembers.firstIndex(of: info)
            if index != nil {
                self.meetingMembers.remove(at: index!)
            }
            if info.share != "none" {
                switch info.share {
                case "whiteboard":
                    if self.whiteboardVC.presentingViewController != nil {
                        self.whiteboardVC.dismiss(animated: true, completion: nil)
                    }
                    break
                case "desktop":
                    if self.screenShareVC.isShow {
                        self.screenShareVC.isShow = false
                        self.screenShareVC.dismiss(animated: true, completion: nil)
                    }
                    break
                default: break
                }
            }
        }
    }
    
    fileprivate func startTimer() {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormate.timeZone = TimeZone(abbreviation:"UTC")!
        let begin_date:Date = dateFormate.date(from: (self.meetingInfo?.beginAt)!)!
        let begin_timeInt = begin_date.timeIntervalSince1970
        let current_timeInt = Date.init().timeIntervalSince1970
        let seconds = current_timeInt - begin_timeInt
        self.duration_label.text = String(format: "%.2d:%.2d:%.2d", Int(seconds / 3600), (Int(seconds) % 3600) / 60, Int(seconds) % 60)
        self.duration = Int(seconds)
        self.meetingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] timer in
            self!.duration += 1
            self!.duration_label.text = String(format: "%.2d:%.2d:%.2d", Int(self!.duration / 3600), Int((self!.duration % 3600) / 60), self!.duration % 60)
        })
        
    }
    
    func dismissAllDisplaySubVC() {
        if self.memberVC.presentingViewController != nil {
            self.memberVC.dismiss(animated: true, completion: nil)
        }
        
        if self.groupVC.presentingViewController != nil {
            self.groupVC.dismiss(animated: true, completion: nil)
        }
        
        if self.whiteboardVC.presentingViewController != nil {
            self.whiteboardVC.dismiss(animated: true, completion: nil)
        }
        
        if self.chatVC.navigationController?.presentingViewController != nil {
            self.chatVC.navigationController!.dismiss(animated: true, completion: nil)
        }
        
        if self.screenShareVC.isShow {
            self.screenShareVC.isShow = false
            self.screenShareVC.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func registerNotification() {
        MeetingScreenShareNotifyModel.registerBeginNotification(self)
        MeetingScreenShareNotifyModel.registStopNotification(self)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: SHARE_BEGIN_NOTICE), object: nil, queue: .main) { notify in
            MeetingAPIRequest.meetingShareStart(number: self.meetingInfo!.number!) { [weak self] response in
                guard response != nil else {
                    return
                }
                self?.manager.changedLocalPower(with: "share", value: "desktop")
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: SHARE_STOP_NOTICE), object: nil, queue: .main) { notify in
            debugPrint("screen share stop")
            self.manager.changedLocalPower(with: "share", value: "none")
        }
    }
    
    @objc fileprivate func delayPresentVC(_ vc: UIViewController) {
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(self.videoList_view) {
            if self.manager.isBreakout {
                return self.meetingGroupUsers.count
            } else {
                return meetingMembers.count
            }
        } else {
            return meetingMenuList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(self.videoList_view) {
            let user_info = self.manager.isBreakout ? self.meetingGroupUsers[indexPath.row] : self.meetingMembers[indexPath.row]
            let reuserId:String! = "kVideoDisplayViewCell_" + String(user_info.user_id!)
            let videoCell:VideoDisplayViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserId, for: indexPath) as! VideoDisplayViewCell
            videoCell.settingVideoInfoData(user_info)
            return videoCell
        } else {
            let menuCell:MenuItemViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "kMenuItemViewCell", for: indexPath) as! MenuItemViewCell
            let menuType:CLS_MenuItem = self.meetingMenuList[indexPath.row]
            switch menuType {
            case .audio:
                menuCell.settingMenuType(type: .audio, status: (self.user_info?.audio)!)
            case .video:
                menuCell.settingMenuType(type: .video, status: (self.user_info?.video)!)
            case .share:
                menuCell.settingMenuType(type: .share, status: self.user_info?.share == "none")
            case .members:
                menuCell.settingMenuType(type: .members, status: true)
            case .more:
                menuCell.settingMenuType(type: .more, status: true)
            }
            return menuCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.videoList_view) {
            let user_info = self.manager.isBreakout ? self.meetingGroupUsers[indexPath.row] : self.meetingMembers[indexPath.row]
            let video_cell: VideoDisplayViewCell = cell as! VideoDisplayViewCell
            if user_info.user_id == self.manager.user_info?.user_id {
                self.manager.manager?.cls_PreviewLocalVideo(withUI: video_cell.videoView, isFullDisplay: false)
            } else {
                self.manager.manager?.cls_ShowRemoteUser(withId: NSNumber(value: Int(user_info.user_id!)), displayUI: video_cell.videoView, isFullDisplay: false)
            }
        } else {
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.isEqual(self.videoList_view) {
            if self.manager.isBreakout {
                if meetingGroupUsers.count > 1 {
                    return CGSize.init(width: (collectionView.frame.width - 3) * 0.5, height: (collectionView.frame.width - 3.0) * 0.5 * 16.0 / 9.0)
                } else {
                    return CGSize.init(width: collectionView.frame.width, height: collectionView.frame.height)
                }
            } else {
                if meetingMembers.count > 1 {
                    return CGSize.init(width: (collectionView.frame.width - 3) * 0.5, height: (collectionView.frame.width - 3.0) * 0.5 * 16.0 / 9.0)
                } else {
                    return CGSize.init(width: collectionView.frame.width, height: collectionView.frame.height)
                }
            }
        } else {
            return CGSize.init(width: collectionView.frame.width * 0.2, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.menuList_view) {
            switch indexPath.row {
            case CLS_MenuItem.audio.rawValue:
                if self.manager.meetingAttrsModel != nil {
                    if (self.manager.meetingAttrsModel?.audio != nil && self.manager.meetingAttrsModel?.enableAudioChange != nil) {
                        
                    } else {
                        self.manager.changedLocalAudio(with: !(readLocalUserStatus(.audio) ?? false))
                    }
                } else {
                    self.manager.changedLocalAudio(with: !(readLocalUserStatus(.audio) ?? false))
                }
                break
            case CLS_MenuItem.video.rawValue:
                self.manager.changedLocalVideo(with: !(readLocalUserStatus(.video) ?? false))
                break
            case CLS_MenuItem.share.rawValue:
                if self.manager.user_info?.share == "none" {
                    if self.manager.isSharing {
                        let alert = UIAlertController.init(title: "Sharing", message: "sharing channal is using, you can't share at this time", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController.init(title: "Sharing", message: "choose your share type", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction.init(title: "whiteboard", style: .default, handler: { [weak self] action in
                            self?.manager.changedLocalPower(with: "share", value: "whiteboard")
                            self?.whiteboardVC.isSelfShare = true
                            self?.present(self!.whiteboardVC, animated: true, completion: nil);
                        }))
                        alert.addAction(UIAlertAction.init(title: "screen", style: .default, handler: { action in
                            for view in self.broadcastView.subviews {
                                if view.isKind(of: UIButton.self) {
                                    (view as! UIButton).sendActions(for: .allEvents)
                                }
                            }
                            self.registerNotification()
                        }))
                        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController.init(title: "Stop Sharing", message: "stop your share status", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "stop " + (self.manager.user_info?.share)!, style: .default, handler: { action in
                        MeetingAPIRequest.meetingShareStop(number: (self.meetingInfo?.number)!) { [weak self] response in
                            guard response != nil else {
                                return
                            }
                            MeetingScreenShareNotifyModel.postCloseNotification()
                            self?.manager.changedLocalPower(with: "share", value: "none")
                        }
                    }))
                    alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                break
            case CLS_MenuItem.members.rawValue:
                self.memberVC.settingDatas(self.meetingMembers, isHost: !(self.manager.user_info?.role == "attendee"))
                self.present(self.memberVC, animated: true, completion: nil)
                break
            case CLS_MenuItem.more.rawValue:
                let alert = UIAlertController.init(title: "More", message: "more meeting functions", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction.init(title: "Poll", style: .default, handler: { [weak self] action in
                    let vote_list = VoteListViewController()
                    let navi = RootNavigationController.init(rootViewController: vote_list)
                    navi.modalPresentationStyle = .fullScreen
                    self?.present(navi, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction.init(title: "Group", style: .default, handler: { [weak self] action in
                    self?.groupVC.settingMeeting(self!.meetingSettingInfo!, groupStatus: false)
                    if (self!.manager.group != nil && self!.manager.group!.count > 0) {
                        var group_list_map = Dictionary<Int, MeetingGroupInfo>.init()
                        var i: Int = 0
                        for obj: MeetingGroupInfo in self!.manager.group!.values {
                            group_list_map[i] = obj
                            i += 1
                        }
                        self!.groupVC.upgradeGroupInfo(group_list_map, all_members: self!.meetingMembers)
                    } else {
                        self?.groupVC.upgradeGroupInfo(nil, all_members: self!.meetingMembers)
                    }
                    self?.present(self!.groupVC, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction.init(title: "Chat", style: .default, handler: { [weak self] action in
                    self?.chatVC.settingCurrentUserInfoMap((self!.manager.user_info!.convertToDict()!))
                    alert.dismiss(animated: true) {
                        if self!.chatVC.navigationController != nil {
                            self?.present(self!.chatVC.navigationController!, animated: true, completion: nil)
                        } else {
                            let chat_navi = RootNavigationController.init(rootViewController: self!.chatVC)
                            chat_navi.modalPresentationStyle = .fullScreen
                            self?.present(chat_navi, animated: true, completion: nil)
                        }
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    // MARK: - MeetingManagerDelegate
    func meetingUsersDidJoin(users: Array<UserInfoStruct>) {
        for obj in users {
            if self.searchUser(with: obj.user_id!) != nil {
                self.upgradeMemberAttr(obj)
            } else {
                self.meetingMembers.append(obj)
                if self.videoList_view != nil {
                    self.videoList_view.register(UINib.init(nibName: "VideoDisplayViewCell", bundle: nil), forCellWithReuseIdentifier: "kVideoDisplayViewCell_" + String(obj.user_id!))
                }
            }
            if obj.user_id == self.manager.user_info?.user_id {
                self.user_info = obj
            }
        }
        guard self.videoList_view != nil else {
            return
        }
        self.videoList_view.reloadData()
    }
    
    func meetingDidReceivedCurrentUserHaveToLeave(_ reason: String) {
        self.manager.leaveRoom()
        self.dismissAllDisplaySubVC()
        let alert = UIAlertController.init(title: "Leave Meeting", message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "leave", style: .cancel, handler: { [weak self] action in
            self?.meetingTimer?.invalidate()
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedUserLeave(_ userId: Int32) {
        dispatch_async_on_main_queue { [weak self] in
            let info = self?.searchUser(with: userId)
            if info?.share != "none" {
                self?.dismissAllDisplaySubVC()
                self!.manager.isSharing = false
            }
            self?.userLeave(with: userId)
            guard self?.videoList_view != nil else {
                return
            }
            self?.videoList_view.reloadData()
        }
    }
    
    func meetingDidReceivedAttrs(attrs: MeetingRoomAttrsModel) {
        guard self.manager.user_info?.role == "attendee" else {
            return
        }
        self.manager.changedLocalAudio(with: attrs.audio!)
    }
    
    func meetingDidReceivedCurrentUserBeKickedout() {
        self.dismissAllDisplaySubVC()
        self.manager.leaveRoom()
        let alert = UIAlertController.init(title: "Kick Out", message: "you had been host kocked out from meeting", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "leave", style: .cancel, handler: { [weak self] action in
            self?.meetingTimer?.invalidate()
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedUserAttrsUpdate(updateType: String!, updateValue: Any!, updateUser: Int32) {
        var userInfo:UserInfoStruct = self.searchUser(with: updateUser)!
        switch updateType {
        case "name":
            userInfo.name = (updateValue as! String)
            self.upgradeMemberAttr(userInfo)
            if userInfo.user_id == self.manager.user_info?.user_id {
                self.manager.user_info?.name = (updateValue as! String)
                self.user_info?.name = (updateValue as! String)
                self.manager.manager?.user_name = (self.manager.user_info?.name!)!
            }
            dispatch_async_on_main_queue { [weak self] in
                self?.videoList_view.reloadData()
                self?.menuList_view.reloadData()
            }
            break
        case "audio":
            userInfo.audio = (updateValue as! NSNumber).boolValue
            if userInfo.user_id == self.manager.user_info?.user_id {
                let status:Bool = updateValue as! Bool
                self.manager.manager?.cls_SettingLocalAudioStreamState(status)
                self.manager.user_info?.audio = status
                self.user_info?.audio = status
            }
            self.upgradeMemberAttr(userInfo)
            dispatch_async_on_main_queue { [weak self] in
                self?.videoList_view.reloadData()
                self?.menuList_view.reloadData()
            }
            break
        case "video":
            userInfo.video = (updateValue as! NSNumber).boolValue
            if userInfo.user_id == self.manager.user_info?.user_id {
                let status:Bool = updateValue as! Bool
                self.manager.manager?.cls_SettingLocalVideoStreamState(status)
                self.manager.user_info?.video = status
                self.user_info?.video = status
            }
            self.upgradeMemberAttr(userInfo)
            dispatch_async_on_main_queue { [weak self] in
                self?.videoList_view.reloadData()
                self?.menuList_view.reloadData()
            }
            break
        case "role":
            userInfo.role = (updateValue as! String)
            if userInfo.user_id == self.manager.user_info?.user_id {
                self.manager.user_info?.role = (updateValue as! String)
                self.user_info?.role = (updateValue as! String)
                self.manager.manager?.user_role = (self.manager.user_info?.role!)!
            }
            self.upgradeMemberAttr(userInfo)
            break
        case "groupId":
            let targetGroupId = (updateValue as! Int)
            self.manager.updateUserGroup(userInfo.user_id!, fromGroupId: userInfo.groupId!, toGroupId: targetGroupId)
            if self.manager.isBreakout {
                let oriGroupId = userInfo.groupId
                if oriGroupId != 0 {
                    var info:MeetingGroupInfo = self.manager.group![oriGroupId!]!
                    info.users!.removeAll(where: ({$0 == userInfo.groupId!}))
                }
                if targetGroupId != 0 {
                    userInfo.groupId = targetGroupId
                    var info:MeetingGroupInfo = self.manager.group![targetGroupId]!
                    info.users!.append(userInfo.user_id!)
                }
            }
            userInfo.groupId = targetGroupId
            if userInfo.user_id == self.manager.user_info?.user_id {
                self.manager.user_info?.groupId = targetGroupId
                self.user_info?.groupId = targetGroupId
            }
            self.upgradeMemberAttr(userInfo)
            if self.groupVC.presentingViewController != nil {
                self.groupVC.upgradeGroupInfo(self.manager.group, all_members: self.meetingMembers)
            }
            break
        case "hand":
            userInfo.hand = (updateValue as! NSNumber).boolValue
            self.user_info?.hand = (updateValue as! NSNumber).boolValue
            self.upgradeMemberAttr(userInfo)
            break
        case "share":
            userInfo.share = (updateValue as! String)
            if userInfo.user_id == self.manager.user_info?.user_id {
                self.manager.user_info?.share = (updateValue as! String)
                self.user_info?.share = (updateValue as! String)
            } else {
                switch userInfo.share {
                case "whiteboard":
                    manager.isSharing = true
                    self.whiteboardVC.isSelfShare = false
                    if self.whiteboardVC.presentingViewController == nil {
                        perform(#selector(delayPresentVC(_:)), with: self.whiteboardVC, afterDelay: 0.5)
                    }
                    break
                case "desktop":
                    manager.isSharing = true
                    if self.screenShareVC.isShow == false {
                        self.screenShareVC.info = screenShareInfo.init(share_user: userInfo.user_id, share_name: userInfo.name)
                        self.screenShareVC.isShow = true
                        perform(#selector(delayPresentVC(_:)), with: self.screenShareVC, afterDelay: 0.5)
                    }
                    break
                case "none":
                    manager.isSharing = false
                    guard self.whiteboardVC.presentingViewController != nil else {
                        return
                    }
                    self.whiteboardVC.dismiss(animated: true, completion: nil)
                    guard self.screenShareVC.isShow == true else {
                        return
                    }
                    self.screenShareVC.isShow = false
                    self.screenShareVC.dismiss(animated: true, completion: nil)
                    break
                default: break
                }
            }
            self.upgradeMemberAttr(userInfo)
            break
        default:
            break
        }
        if self.memberVC.presentingViewController != nil {
            self.memberVC.upgradeUserInfo(updateUser, update_power: updateType, value: updateValue as Any)
        }
    }
    
    func meetingDidReceivedRoomAttrsUpdate(updateType: String!, updateValue: Any!, updateRoomId: Int32) {
        switch updateType {
        case "audio":
            guard self.manager.user_info?.role == "attendee" else {
                return
            }
            self.manager.changedLocalAudio(with: (updateValue as! Bool))
            break
        case "subRooms":
            break
        default: break
        }
    }
    
    func meetingDidReceivedPowerChangedRequest(_ power_name: String, value: Any) {
        switch power_name {
        case "audio":
            let status:Bool = value as! Bool
            self.showNoticeAlert("audio", value: status ? "open" : "close") { [weak self] result, type in
                if result {
                    self?.manager.changedLocalAudio(with: status)
                }
            }
            break
        case "video":
            let status:Bool = value as! Bool
            self.showNoticeAlert("video", value: status ? "open" : "close") { [weak self] result, type in
                if result {
                    self?.manager.changedLocalVideo(with: result)
                }
            }
            break
        case "role":
            let role:String = value as! String
            self.showNoticeAlert("role", value: role) { [weak self] result, type in
                self?.manager.changedLocalPower(with: type, value: role)
            }
            break
        case "name":
            let name:String = value as! String
            self.showNoticeAlert("username", value: name) { [weak self] result, type in
                self?.manager.changedLocalPower(with: type, value: name)
            }
            break
        default:
            return
        }
    }
    
    func meetingDidReceivedSystemChatMessage(_ model: MeetingChatMessageDataModel) {
        self.chatVC.chatView.addChatMessage(model)
    }
    
    func meetingDidReceivedGroupBreakoutNotify(_ group_info: Dictionary<Int, MeetingGroupInfo>, selfInGroup: Int) {
        for obj in group_info.values {
            let contain = (obj.users!.contains(where: ({$0 == self.user_info!.user_id})))
            if contain {
                self.user_info?.groupId = obj.id
                self.manager.user_info?.groupId = obj.id
                self.manager.changedLocalPower(with: "groupId", value: obj.id!)
            }
        }
        self.meetingGroupUsers = self.searchSameGroupMembers(selfInGroup)
        self.manager.handleGroupRTCStream()
        self.videoList_view.reloadData()
    }
    
    func meetingDidReceivedScreenShareStream() {
        guard self.screenShareVC.isShow == false else {
            return
        }
        let result = self.meetingMembers.filter(({$0.share == "desktop"}))
        if result.count > 0 {
            let info = result.first
            guard info?.user_id != self.user_info?.user_id else {
                return
            }
            self.screenShareVC.info = screenShareInfo.init(share_user: info?.user_id, share_name: info?.name)
            self.screenShareVC.isShow = true
            self.present(self.screenShareVC, animated: true, completion: nil)
        }
    }
    
    func meetingDidReceivedGroupMoveRequest(_ target_group: Int) {
        let group_info = self.manager.group?[target_group] ?? nil
        guard group_info != nil else {
            return
        }
        let alert = UIAlertController.init(title: "Group Move Request", message: "you have been moved to group [ " + (group_info!.name ?? String(group_info!.id!)) + " ], are you sure ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { action in
            self.manager.changedLocalPower(with: "groupId", value: target_group)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedBreakoutStatusChanged(_ status: Bool) {
        if status == false {
            if self.user_info?.groupId != 0 {
                self.user_info?.groupId = 0
                self.manager.user_info?.groupId = 0
                self.manager.changedLocalPower(with: "groupId", value: 0)
            }
            self.manager.handleGroupRTCStream()
            self.meetingGroupUsers.removeAll()
            self.videoList_view.reloadData()
        }
    }
    
    func meetingDidReceivedMemberCallHost(_ groupId: Int, senderId: Int32) {
        guard self.user_info?.role != "attendee" else {
            return
        }
        let info = self.searchUser(with: senderId)
        let group = self.manager.group?[groupId]
        let message = "group member [ " + (info?.name ?? String(senderId)) + " ] call you go to group [ " + (group?.name ?? String(groupId)) + " ]"
        let alert = UIAlertController.init(title: "Member Call Host", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { action in
            self.user_info?.groupId = groupId
            self.manager.user_info?.groupId = groupId
            self.manager.changedLocalPower(with: "groupId", value: groupId)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedAudioChangedRequest(_ from: Int32, value: Bool) {
        let alert = UIAlertController.init(title: "Change Audio", message: "host will " + (value ? "open" : "close") + " your auido", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: (value ? "open" : "close"), style: .default, handler: { action in
            self.manager.changedLocalAudio(with: value)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedVideoChangedRequest(_ from: Int32, value: Bool) {
        let alert = UIAlertController.init(title: "Change Video", message: "host will " + (value ? "open" : "close") + " your video", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: (value ? "open" : "close"), style: .default, handler: { action in
            self.manager.changedLocalVideo(with: value)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedRoleChangedRequest(_ from: Int32, value: String) {
        let alert = UIAlertController.init(title: "Change Role", message: "host will change your role to " + value, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "agree", style: .default, handler: { action in
            self.manager.changedLocalPower(with: "role", value: value)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedNameChagnedRequest(_ from: Int32, value: String) {
        let alert = UIAlertController.init(title: "Change Name", message: "host will change your name to " + value, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "agree", style: .default, handler: { action in
            self.manager.changedLocalPower(with: "name", value: value)
        }))
        alert.addAction(UIAlertAction.init(title: "cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func meetingDidReceivedWhiteboardMessage(_ message: String) {
        let draw_model = (WhiteboardMessageInfoModel.model(withJSON: message))!
        switch draw_model.typeEnum {
        case .DRW_LINE:
            let drw_line = (DrawLineControlInfoModel.model(withJSON: message))!
            self.whiteboardVC.receivedDrawPencilMessage(drw_line)
            break
        case .DRW_STRAIGHT_LINE, .DRW_ROUND, .DRW_TEXT, .DRW_RECT:
            let drw_size = (DrawShapeControlInfoModel.model(withJSON: message))!
            self.whiteboardVC.receivedDrawShapeMessage(drw_size)
            break
        case .DRW_PAGE, .DRW_PAGE_CHANGE, .DRW_PAGE_DELETE:
            break
        case .DRW_REVOKE, .DRW_REVOKE_ON, .DRW_REVOKE_OFF:
            break
        case .DRW_DELETE, .DRW_CLEARALL:
            let drw_delete = (DrawShapeControlInfoModel.model(withJSON: message))!
            self.whiteboardVC.receivedDrawShapeMessage(drw_delete)
            break
        case .DRW_HISTORY:
            let history_info = (DrawPageHistoryDataInfo.model(withJSON: message))!
            self.whiteboardVC.receivedDrawHistoryMessage(history_info)
            break
        default: break
        }
    }
    
    func meetingDidReceivedChatMessage(_ message: String, sender_info: Int32) {
        let sender_user_info = self.searchUser(with: sender_info)!
        let chat_data_model = MeetingChatMessageDataModel.init()
        chat_data_model.chat_message = message
        chat_data_model.userId = String(sender_user_info.user_id!)
        chat_data_model.user_name = sender_user_info.name!
        self.chatVC.receivedMeetingChatMessage(chat_data_model)
    }
    
    func meetingDidReceivedRoteStartMessage(_ voteId: String) {
        let voteVC = VoteController()
        let navi = RootNavigationController.init(rootViewController: voteVC)
        navi.modalPresentationStyle = .fullScreen
        voteVC.voteId = voteId as NSString
        self.present(navi, animated: true, completion: nil)
    }
    
    func meetingDidReceivedPublishVoteResult(_ voteId: String) {
        let vote_result = VoteResultController()
        vote_result.voteId = voteId as NSString
        vote_result.is_pulishing = "1"
        vote_result.is_mainUser = "0"
        let navi = RootNavigationController.init(rootViewController: vote_result)
        navi.modalPresentationStyle = .fullScreen
        self.present(navi, animated: true, completion: nil)
    }
    
    // MARK: - WhiteBroadVCDelegate
    func whiteboardDrawMessage(_ message: String) {
        self.manager.sendWhiteboardMessage(with: message)
    }
    
    func whiteboardDidDismiss() {
        if self.manager.user_info?.share == "whiteboard" {
            self.manager.changedLocalPower(with: "share", value: "none")
        }
    }
    
    // MARK: - MeetingChatViewDelegate
    func meetingChatPopoverView(_ chatPopView: MeetingChatViewController, userDidInputChatMessage text: String, userId: NSNumber) -> MeetingChatMessageDataModel {
        let chat_data_model = MeetingChatMessageDataModel.init()
        chat_data_model.chat_message = text
        chat_data_model.userId = String(self.manager.user_info!.user_id!)
        chat_data_model.user_name = self.manager.user_info!.name!
        self.manager.sendChatMessageOnSystemChatChannel(with: text)
        return chat_data_model
    }
    
    func meetingChatPopoverViewChoseUserList(_ chatPopView: MeetingChatViewController) {
        
    }
    
    // MARK: - GroupVCOperationProtocol
    func groupVCMoveUserToGroup(_ targetGroupId: Int, fromGroupId: Int, users: Array<Int32>) {
        if users.contains(where: ({$0 == self.user_info?.user_id})) {
            self.manager.changedLocalPower(with: "groupId", value: targetGroupId)
            if users.count > 1 {
                self.manager.hostMoveMembersToGroup(with: users, fromGroup: fromGroupId, toGroup: targetGroupId)
            }
        } else {
            self.manager.hostMoveMembersToGroup(with: users, fromGroup: fromGroupId, toGroup: targetGroupId)
        }
    }
    
    func groupStart(_ groupsInfo: Dictionary<Int, MeetingGroupInfo>) {
        guard groupsInfo.count > 0 else {
            return
        }
        var group_datas:Array<Dictionary<String, Any>> = Array.init()
        for obj in groupsInfo.values {
            if obj.users!.contains(where: ({$0 == self.user_info!.user_id})) {
                self.user_info?.groupId = obj.id
            }
            group_datas.append(obj.convertToDict()!)
        }
        self.manager.hostStartGroup(with: group_datas)
    }
    
    func groupStop() {
        self.manager.hostStopGroup()
    }
    
    func groupHostSendBroadcastMessage(_ message: String?) {
        self.manager.hostSendBroadcastMessage(message!)
    }
    
    func groupMemberCallHost(_ groupId: Int) {
        self.manager.manager?.cls_CallHost(fromGroup: NSNumber.init(value: groupId), completedHandler: { success, response, error in
            
        })
    }
    
    func groupDidDismiss() {
        
    }
    
    // MARK: - MemberListViewControllerDelegate
    func memberListOperationData(_ power: String, value: Any, user_id: Int32) {
        switch power {
        case "audio":
            if user_id != self.manager.user_info?.user_id {
                self.manager.requestChangeOtherAudio(with: user_id, value: (value as! Bool))
            } else {
                self.manager.changedLocalAudio(with: (value as! Bool))
            }
            break
        case "video":
            if user_id == self.manager.user_info?.user_id {
                self.manager.changedLocalVideo(with: (value as! Bool))
            }
            break
        case "hand":
            if user_id == self.manager.user_info?.user_id {
                self.manager.changedLocalPower(with: "hand", value: (value as! Bool))
            }
            break
        case "kick_out":
            self.manager.hostKockoutUser(user_id)
            break
        case "role":
            if (value as! Bool) {
                self.manager.hostGiveUserCoHost(with: user_id)
            } else {
                self.manager.hostCancelUserCoHost(with: user_id)
            }
            break
        case "name":
            self.manager.requestChangeOtherName(with: user_id, rename: (value as! String))
            break
        default: break
        }
    }
    
    func memberListAllMemberMute(_ status: Bool, enableChange: Bool) {
        self.manager.hostChangeMeetingAudioAttrs(status, enable_change: enableChange)
    }
    
    //MARK: - ScreenShareViewControllerDelegate
    func screenShareVCDidDisplayUI(_ videoView: UIView) {
        self.manager.manager?.cls_ShowRemoteUser(withId: NSNumber(value: Int(self.manager.shareInfo!.sharerId!)), displayUI: videoView, isFullDisplay: false)
    }
}
