//
//  SampleMeetingManager.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/7.
//

import UIKit
import cloud_lvb_sdk_ios
import HandyJSON
import YYKit

class SampleMeetingManager: NSObject, CLS_PlatformManagerDelegate {
    
    var user_info:                          UserInfoStruct?
    var manager:                            CLS_PlatformManager?
    var shareInfo:                          MeetingShareInfoModel?
    var meetingJoinMembers:                 Set<UserInfoStruct> = Set.init()
    var meetingAttrsModel:                  MeetingRoomAttrsModel?
    var vote_status:                        Bool = false
    var meetingInfo:                        meetingInfoStruct?
    var group:                              Dictionary<Int, MeetingGroupInfo>?
    var isSharing = false
    var isBreakout = false
    weak var delegate:                      MeetingManagerDelegate?
        
    private static var _sharedInstance: SampleMeetingManager?
    
    @objc class func defaultManager() -> SampleMeetingManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = SampleMeetingManager()
            return _sharedInstance!
        }
        return instance
    }
    
    @objc func destroyInstance() {
        SampleMeetingManager._sharedInstance = nil
    }
    
    override init() {
        super.init()
    }
    
    func joinMeeting(with user_info: UserInfoStruct, meeting_info: meetingInfoStruct, meeting_setting: MeetingJoinInfo, completedHandler: @escaping (_ completed: Bool, _ error_message:String?) ->Void) {
        self.user_info = user_info
        self.meetingInfo = meeting_info
        self.meetingJoinMembers.insert(user_info)
        MeetingAPIRequest.meetingJoin(number: meeting_info.number!, password: meeting_info.password) {[weak self] response in
            if response != nil {
                let join_info:JoinMeetingDataModel = JSON(withJSONObject: response, modelType: JoinMeetingDataModel.self)!
                debugPrint(response as Any)
                self?.isBreakout = join_info.isBreakout ?? false
                if (join_info.appKey != nil && join_info.token != nil) {
                    
                    let file_url:URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.OpenPlatformTeam.meeting-ios-sample")!
                    let write_path = file_url.appendingPathComponent("Library/Caches/", isDirectory: true)
                    let path = write_path.appendingPathComponent("shareInfo").appendingPathExtension("plist")
                    
                    let share_info = ["user_id": join_info.shareUserId!, "token": join_info.shareUserToken!, "app_key": join_info.appKey!, "room_id": join_info.roomId!] as NSDictionary
                    self?.manager?.cls_SettingShareUserInfo(withId: NSNumber.init(value: join_info.shareUserId!), token: join_info.shareUserToken!)
                    debugPrint(share_info)
                    
                    let data = share_info.modelToJSONData()
                    
                    do {
                        try data?.write(to: path)
                    } catch {
                        debugPrint(error)
                    }
                    
                    self!.shareInfo = MeetingShareInfoModel.init(sharerId: join_info.shareUserId, sharerToken: join_info.shareUserToken)
                    self!.manager = CLS_PlatformManager.defaultManager(authToken: join_info.token!, appkey: join_info.appKey!)
                    self!.manager?.delegate = self
                    self?.manager?.user_name = (self?.user_info?.name)!
                    self?.manager?.user_role = (self?.user_info?.role)!
                    let is_admin:Bool = meeting_info.ownerId! == LoginUserDataModel.manager.userId!
                    self!.manager?.cls_JoinRoom(withUserId: NSNumber.init(value: LoginUserDataModel.manager.userId!), roomId: NSNumber.init(value: join_info.roomId!), isAdmin: is_admin, defaultAudioRoute: meeting_setting.speaker_status!, completedHandler: { success, error, meetingMembers, meetingAttrs in
                        dispatch_async_on_main_queue {
                            if success {
                                completedHandler(true, nil)
                                self?.manager?.cls_SettingShareUserInfo(withId: NSNumber.init(value: join_info.shareUserId!), token: join_info.shareUserToken!)
                                if meetingMembers!.count > 0 {
                                    for keys in meetingMembers!.keys {
                                        let obj:Dictionary<String, Any> = meetingMembers![keys] as! Dictionary<String, Any>
                                        var userInfo = JSON(withJSONObject: obj["Attrs"], modelType: UserInfoStruct.self)!
                                        userInfo.user_id = Int32(keys as! String)
                                        if userInfo.user_id == LoginUserDataModel.manager.userId {
                                            continue
                                        } else {
                                            self!.meetingJoinMembers.insert(userInfo)
                                            if (userInfo.share != nil && userInfo.share != "none") {
                                                self!.isSharing = true
                                            }
                                        }
                                    }
                                    self!.delegate?.meetingUsersDidJoin(users: Array.init(self!.meetingJoinMembers))
                                    if self!.isSharing {
                                        let search_result:Set<UserInfoStruct> = (self?.meetingJoinMembers.filter(({$0.share != "none"})))!
                                        if search_result.count > 0 {
                                            let info = search_result.first
                                            self?.delegate?.meetingDidReceivedUserAttrsUpdate(updateType: "share", updateValue: info?.share, updateUser: (info?.user_id)!)
                                        }
                                    }
                                }
                                if (meetingAttrs != nil && meetingAttrs!.count > 0) {
                                    self!.meetingAttrsModel = JSON(withJSONObject: meetingAttrs, modelType: MeetingRoomAttrsModel.self)
                                    if (self?.meetingAttrsModel?.subRooms.count)! > 0 {
                                        
                                    }
                                    self!.delegate?.meetingDidReceivedAttrs(attrs: self!.meetingAttrsModel!)
                                }
                            } else {
                                completedHandler(false, error?.localizedDescription)
                            }
                        }
                    })
                }
            } else {
                completedHandler(false, "meeting join api recover empty message")
            }
        }
    }
    
    func readMeetingGroupInfo(with group_detail: @escaping (_ group_status: Bool) -> Void) {
        MeetingAPIRequest.meetingGroupDetail(with: (self.meetingInfo?.number!)!) { [weak self] response in
            guard response != nil else {
                return
            }
            let responseObj_dict = response as! Dictionary<String, Any>
            if responseObj_dict.count > 0 {
                let obj = responseObj_dict["group"]
                if (obj as! NSObject).self.isKind(of:(NSNull.self)) {
                    group_detail(false)
                    return
                }
                let group_info:Array<MeetingGroupInfo> = JSON(withJSONObject: responseObj_dict["group"], modelType: [MeetingGroupInfo].self)!
                guard group_info.count > 0 else {
                    group_detail(true)
                    return
                }
                self?.isBreakout = true
                var selfGroupId: Int = 0
                self?.group = Dictionary.init()
                for obj in group_info {
                    var user_ids:Array<Int32> = Array.init()
                    for user in obj.users! {
                        user_ids.append(user)
                    }
                    if user_ids.contains((self?.user_info?.user_id)!) {
                        selfGroupId = obj.id!
                        self?.changedLocalPower(with: "groupId", value: obj.id!)
                    }
                    let group_data:MeetingGroupInfo = MeetingGroupInfo.init(id: obj.id, name: obj.name, users: user_ids)
                    self?.group![obj.id!] = group_data
                }
                self?.handleGroupRTCStream()
                self?.delegate?.meetingDidReceivedGroupBreakoutNotify((self?.group)!, selfInGroup: selfGroupId)
                group_detail(true)
            } else {
                group_detail(false)
            }
        }
    }
    
    func readMeetingWhiteboardHistory() {
        self.manager?.cls_SynchronizeWhiteboardDrawContent({ success, error in
            guard !success else {
                return
            }
            debugPrint(error!.localizedDescription)
        })
    }
    //MARK: - local audio video power change
    func changedLocalAudio(with status:Bool) {
        self.manager?.cls_SettingUserAttr(withUserId: NSNumber(value: self.user_info!.user_id!), roomId: NSNumber(value: (self.meetingInfo?.number!)!), attrsMap: ["audio": status], completedHandler: { success, response, error in
            if success == false {
                debugPrint("setting loacl audio request error")
            }
        })
    }
    
    func changedLocalVideo(with status:Bool) {
        self.manager?.cls_SettingUserAttr(withUserId: NSNumber(value: self.user_info!.user_id!), roomId: NSNumber(value: (self.meetingInfo?.number!)!), attrsMap: ["video": status], completedHandler: { success, response, error in
            if success == false {
                debugPrint("setting loacl video request error")
            }
        })
    }
    
    func changedLocalPower(with type:String, value: Any) {
        self.manager?.cls_SettingUserAttr(withUserId: NSNumber(value: self.user_info!.user_id!), roomId: NSNumber(value: (self.meetingInfo?.number!)!), attrsMap: [type: value], completedHandler: { [weak self] success, response, error in
            if success {
                switch type {
                case "role":
                    self?.user_info?.role = (value as! String)
                    break
                case "name":
                    self?.user_info?.name = (value as! String)
                    break
                case "share":
                    self?.user_info?.share = (value as! String)
                    break
                case "groupId":
                    self?.user_info?.groupId = (value as! Int)
                    break
                default:
                    break
                }
                debugPrint(response as Any)
            } else {
                debugPrint(error?.localizedDescription as Any)
            }
        })
    }
    
    func requestChangeOtherAudio(with userId: Int32, value: Bool) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_ChangeOtherAudioStatus(withUserId: NSNumber.init(value: userId), statusValue: value, completedHandler: { success, response, error in
                if error != nil {
                    debugPrint(error?.localizedDescription as Any)
                } else {
                    debugPrint(response as Any)
                }
            })
        }
    }
    
    func requestChangeOtherName(with userId: Int32, rename: String) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_ChangeOtherNama(withUserId: NSNumber.init(value: userId), nameValue: rename, completedHandler: { success, response, error in
                if error != nil {
                    debugPrint(error?.localizedDescription as Any)
                } else {
                    debugPrint(response as Any)
                }
            })
        }
    }
    
    func hostChangeMeetingAudioAttrs(_ audio: Bool, enable_change: Bool) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_SettingRoomAttr(withRoomId: NSNumber.init(value: (self.meetingInfo?.number)!), attrsMap: ["audio": audio, "enableAudioChange": enable_change], completedHandler: { success, response, error in
                
            })
        }
    }
    
    func hostKockoutUser(_ userId: Int32) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_KickoutRoomMember(withUserId: NSNumber.init(value: userId), roomId: NSNumber(value: (self.meetingInfo?.number!)!), completedHandler: { success, response, error in
                
            })
        }
    }
    
    func hostGiveUserCoHost(with userId: Int32) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_ChangeOtherRole(withUserId: NSNumber.init(value: userId), roleValue: "co-host", completedHandler: { success, response, error in
                if error != nil {
                    debugPrint(error?.localizedDescription as Any)
                } else {
                    debugPrint(response as Any)
                }
            })
        }
    }
    
    func hostSendCustomControlMessageToRoom(_ content:Dictionary<AnyHashable, Any>, subType: String) {
        self.manager?.cls_SendSystemCustomMessage(withType: subType, opts: content, completedHandler: { success, response, error in
            if error != nil {
                debugPrint(error?.localizedDescription as Any)
            } else {
                debugPrint(response as Any)
            }
        })
    }
    
    func hostSendBroadcastMessage(_ message: String) {
        guard (self.isBreakout && message.isEmpty == false) else {
            return
        }
        self.manager?.cls_SendSystemBroadcastMessageToGroup(withGroupId: NSNumber.init(value: -1), message: message, completedHandler: { success, response, error in
            
        })
    }
    
    func hostCancelUserCoHost(with userId: Int32) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.manager?.cls_ChangeOtherRole(withUserId: NSNumber.init(value: userId), roleValue: "attendee", completedHandler: { success, response, error in
                if error != nil {
                    debugPrint(error?.localizedDescription as Any)
                } else {
                    debugPrint(response as Any)
                }
            })
        }
    }
    
    func startOrCancelShareStatus(with shareType: String, status: Bool) {
        self.manager?.cls_SettingUserAttr(withUserId: NSNumber.init(value: (self.user_info?.user_id)!), roomId: NSNumber.init(value: (self.meetingInfo?.number)!), attrsMap: ["share": status ? shareType : "none"], completedHandler: { success, response, error in
            if error != nil {
                debugPrint(error?.localizedDescription as Any)
            } else {
                debugPrint(response as Any)
            }
        })
    }
    
    func switchLocalCamera() {
        self.manager?.cls_SwitchCamera()
    }
    
    func changedLocalSoundMode(_ isSpeaker: Bool) {
        self.manager?.cls_ChangedSoundMode(isSpeaker)
    }
    
    func sendWhiteboardMessage(with data: String) {
        self.manager?.cls_SendMessageToRoom(withRoomId: NSNumber.init(value: (self.meetingInfo?.number)!), category: .RTMMessageCategory_WHITEBOARD_MESSAGE, messageContent: data, completedHandler: { success, response, error in
            if success {
                debugPrint(response as Any)
            } else {
                debugPrint(error?.localizedDescription as Any)
            }
        })
    }
    
    func sendChatMessageOnSystemChatChannel(with data: String) {
        self.manager?.cls_RTMSystemSendCommonChatMessage(data, completedHandler: { success, response, error in
            if success {
                debugPrint(response as Any)
            } else {
                debugPrint(error?.localizedDescription as Any)
            }
        })
    }
    
    func hostStartGroup(with groupInfo: Array<Dictionary<String, Any>>) {
        if self.user_info!.role!.lowercased() != "attendee" {
            self.isBreakout = true
            MeetingAPIRequest.meetingStartGroup(with: (self.meetingInfo?.number)!, group: groupInfo) { [weak self] response in
                if response != nil {
                    self?.manager?.cls_HostChangeBreakoutStatus(true, completedHandler: { success, response, error in
                        if error != nil {
                            debugPrint(error!.localizedDescription as String)
                        }
                    })
                }
            }
        }
    }
    
    func hostStopGroup() {
        guard self.group != nil else {
            return
        }
        let group_values:Array<MeetingGroupInfo> = Array(self.group!.values)
        var groups = Array<Dictionary<String, Any>>()
        for obj in group_values {
            let dict = obj.convertToDict()
            groups.append(dict!)
        }
        self.isBreakout = false
        MeetingAPIRequest.meetingStopGroup(with: (self.meetingInfo?.number)!, group: groups) { [weak self] response in
            if response != nil {
                let response_dict = response as! Dictionary<String, Any>
                if ((response_dict["success"] != nil)) {
                    self!.group = nil
                    self?.manager?.cls_HostChangeBreakoutStatus(false, completedHandler: { success, response, error in
                        if error != nil {
                            debugPrint(error!.localizedDescription as String)
                        }
                    })
                }
            }
        }
    }
    
    func hostMoveMembersToGroup(with members: Array<Int32>, fromGroup: Int, toGroup: Int) {
        guard members.count > 0 else {
            return
        }
        var users:Set<Int32> = Set.init()
        for obj in members {
            users.insert(obj)
        }
        MeetingAPIRequest.meetingGroupMoveMember(with: (self.meetingInfo?.number)!, members: users.map({$0}), fromGroup: Int32(fromGroup), toGroup: Int32(toGroup)) { [weak self] response in
            if response != nil {
                let member_ids = NSMutableArray.init()
                for id in users {
                    member_ids.add(NSNumber.init(value: id))
                }
                self?.manager?.cls_RequestUsersMoveToBreakoutGroup(withGroupId: NSNumber(value: toGroup), moveUsersId: ((member_ids as NSArray) as! [NSNumber]), completedHandler: { success, response, error in
                    
                })
            }
        }
    }
    
    func loadGroupInfo() {
        MeetingAPIRequest.meetingGroupDetail(with: (self.meetingInfo?.number)!) { [weak self] response in
            if response != nil {
                let responseObject = response as! Array<Dictionary<String, Any>>
                for obj in responseObject {
                    let groupId = obj["id"] as! Int
                    self?.group![groupId] = JSON(withJSONObject: obj, modelType: MeetingGroupInfo.self)
                }
            } else {
                debugPrint("request group detail error")
            }
        }
    }
    
    func leaveRoom() {
        self.manager?.cls_LeaveTheSystem()
        self.releaseSource()
    }
    
    func closeRoom() {
        self.manager?.cls_RoomStop(withRoomId: NSNumber.init(value: self.meetingInfo!.number!), completedHandler: { [weak self] success, response, error in
            self?.leaveRoom()
        })
    }
    
    func handleGroupRTCStream() {
        if self.isBreakout {
            let search_result:Array<UserInfoStruct> = self.meetingJoinMembers.filter(({$0.groupId == self.user_info?.groupId}))
            let tmpUsers = self.meetingJoinMembers
            if search_result.count > 0 {
                let result = tmpUsers.symmetricDifference(search_result)
                for obj in tmpUsers {
                    if result.contains(obj) {
                        self.manager?.cls_RemoteUserStream(withId: NSNumber.init(value: obj.user_id!), muteStatus: true)
                    } else {
                        self.manager?.cls_RemoteUserStream(withId: NSNumber.init(value: obj.user_id!), muteStatus: false)
                    }
                }
            }
        } else {
            for obj in self.meetingJoinMembers {
                self.manager?.cls_RemoteUserStream(withId: NSNumber.init(value: obj.user_id!), muteStatus: false)
            }
        }
    }
    
    func updateUserGroup(_ userId: Int32, fromGroupId: Int, toGroupId: Int) {
        if fromGroupId == 0 {
            var group_info:MeetingGroupInfo = self.group![toGroupId]!
            group_info.users!.append(userId)
        } else {
            var group_info:MeetingGroupInfo = self.group![fromGroupId]!
            group_info.users!.removeAll(where: ({$0 == userId}))
            if toGroupId != 0 {
                var target_info:MeetingGroupInfo = self.group![toGroupId]!
                target_info.users!.append(userId)
            }
        }
    }

    // MARK: - 私有方法
    fileprivate func searchUser(with ext_id: Int32) -> UserInfoStruct? {
        let searchResult:[UserInfoStruct] = self.meetingJoinMembers.filter {$0.user_id == ext_id}
        if searchResult.count > 0 {
            return searchResult.first
        } else {
             return nil
        }
    }
    
    fileprivate func containsUser(with ext_id: Int32) -> Bool {
        let searchResult:[UserInfoStruct] = self.meetingJoinMembers.filter {$0.user_id == ext_id}
        return searchResult.count > 0
    }
    
    fileprivate func releaseSource() {
        self.meetingJoinMembers.removeAll()
        self.manager?.delegate = nil
        self.manager = nil
        self.destroyInstance()
    }
    
    fileprivate func updateUserStruct(_ id: Int32, key: String, value: Any) {
        var info = self.searchUser(with: id)
        guard info != nil else {
            return
        }
        switch key {
        case "audio":
            info!.audio = (value as! Bool)
            break
        case "video":
            info!.video = (value as! Bool)
            break
        case "name":
            info!.name = (value as! String)
            break
        case "role":
            info!.role = (value as! String)
            break
        case "groupId":
            info!.groupId = (value as! Int)
            break
        case "share":
            info!.share = (value as! String)
            break
        case "hand":
            info!.hand = (value as! Bool)
            break
        default: break
        }
        meetingJoinMembers.insert(info!)
        if key == "groupId" {
            self.handleGroupRTCStream()
        }
    }
    
    // MARK: - CLS_PlatformManagerDelegate
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, currentUserDidJoinedSystem roomId: NSNumber) {
        manager.cls_InitUserAttrsMap((user_info?.convertToDict())!) { [weak self] success, response, error in
            if success {
                self?.manager?.cls_StartOnPlatform()
                debugPrint(response as Any)
            } else {

            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, userDidJoinedRoomWithId userId: NSNumber, attrs userAttrs: [String : Any]) {
        dispatch_async_on_main_queue { [weak self] in
            var joinUser:UserInfoStruct = JSON(withJSONObject: userAttrs["Attrs"], modelType: UserInfoStruct.self)!
            joinUser.user_id = userId.int32Value
            if self?.containsUser(with: userId.int32Value) == false {
                self?.meetingJoinMembers.insert(joinUser)
                self?.delegate?.meetingUsersDidJoin(users: [joinUser])
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, userDidLeavedRoomWithId userId: NSNumber) {
        let leave_user = self.searchUser(with: userId.int32Value)
        let reslut = self.meetingJoinMembers.filter({$0.user_id == leave_user?.user_id})
        for obj in reslut {
            self.meetingJoinMembers.remove(obj)
        }
        self.delegate?.meetingDidReceivedUserLeave(userId.int32Value)
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, currentUserDidBeenKickoutFromRoomSenderUserWithId userId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedCurrentUserBeKickedout()
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, currentUserRemoteLoginWithMessage message: String) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedCurrentUserHaveToLeave("remote login with device:" + message)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, roomStatusDidUpdate status: CLS_RoomStatusEnum) {
        dispatch_async_on_main_queue { [weak self] in
            if status == .STOP {
                self?.delegate?.meetingDidReceivedCurrentUserHaveToLeave("meeting closed")
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, currentUserDidLeavedRoomWithId userId: NSNumber) {
        manager.cls_LeaveTheSystem()
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, userUpdateAttrs attrs: [String : Any], withUserId userId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            let user:UserInfoStruct = (self?.searchUser(with: userId.int32Value)!)!
            for (key, value) in (attrs["Attrs"] as! Dictionary<String, Any>) {
                self?.updateUserStruct(user.user_id!, key: key, value: value)
                self?.delegate?.meetingDidReceivedUserAttrsUpdate(updateType: key, updateValue: value, updateUser: user.user_id!)
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, roomDidUpdatedAttrs roomAttrs: [String : Any], senderUserId userId: NSNumber) {
        for (key, value) in roomAttrs {
            switch key {
            case "audio":
                self.meetingAttrsModel?.audio = (value as! Bool)
                break
            case "subRooms":
                let subrooms:Array<MeetingGroupInfo> = JSON(withJSONObject: value, modelType: [MeetingGroupInfo].self)!
                self.meetingAttrsModel?.subRooms = subrooms
                break
            case "enableAudioChange":
                self.meetingAttrsModel?.enableAudioChange = (value as! Bool)
                break
            default:
                break
            }
            dispatch_async_on_main_queue { [weak self] in
                self?.delegate?.meetingDidReceivedRoomAttrsUpdate(updateType: key, updateValue: value, updateRoomId: (self?.meetingInfo?.number)!)
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, roomUsersAudioVolume infos: [CLS_PlatformAudioVolumeModel]) {
        
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, didReceivedChatMessageWithContent content_json: String, receiveType ReceiveType: Int, receiveId ReceiveId: NSNumber, senderId: NSNumber) {
        
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, didReceivedControlMessageWithContent content_json: String, receiveType ReceiveType: Int, receiveId ReceiveId: NSNumber, senderId: NSNumber) {
        
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, didReceivedWhiteboardMessageWithContent content_json: String, receiveType ReceiveType: Int, receiveId ReceiveId: NSNumber, senderId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            if senderId.int32Value != self?.user_info?.user_id {
                self?.delegate?.meetingDidReceivedWhiteboardMessage(content_json)
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, userDidStartedPublishStreamWithId userId: NSNumber) {
        if (userId.int32Value == self.shareInfo?.sharerId) {
            dispatch_async_on_main_queue { [weak self] in
                self?.isSharing = true
                self?.delegate?.meetingDidReceivedScreenShareStream()
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, userDidStoppedPublishStreamWithId userId: NSNumber) {
        if (userId.int32Value == self.shareInfo?.sharerId) {
            self.isSharing = false
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, requestAudioStatusChanged value: Bool, senderId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedAudioChangedRequest(senderId.int32Value, value: value)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, requestVideoStatusChanged value: Bool, senderId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedVideoChangedRequest(senderId.int32Value, value: value)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, requestNameChanged value: String, senderId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedNameChagnedRequest(senderId.int32Value, value: value)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, requestRoleChanged value: String, senderId: NSNumber) {
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedRoleChangedRequest(senderId.int32Value, value: value)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedBreakoutStatusChanged status: Bool) {
        dispatch_async_on_main_queue { [weak self] in
            if status {
                self?.readMeetingGroupInfo { group_status in
                    
                }
            } else {
                self?.isBreakout = false
                self?.delegate?.meetingDidReceivedBreakoutStatusChanged(false)
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, roomSharerDidPublishStream shareId: NSNumber) {
        self.delegate?.meetingDidReceivedScreenShareStream()
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedSystemMoveUserToSubRoomRequest toRoomId: NSNumber, senderId: NSNumber) {
        if senderId.int32Value != self.user_info?.user_id {
            dispatch_async_on_main_queue { [weak self] in
                self?.delegate?.meetingDidReceivedGroupMoveRequest(toRoomId.intValue)
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedSystemBroadcastMessage message: String, groupId: NSNumber, senderId: NSNumber) {
        dispatch_async_on_main_queue {
            let received_chat_message:MeetingChatMessageDataModel = MeetingChatMessageDataModel.init()
            received_chat_message.chat_message = "Host Notice: " + message
            received_chat_message.userId = senderId.stringValue
            let senderUserInfo:UserInfoStruct = (self.searchUser(with: senderId.int32Value)!)
            received_chat_message.user_name = senderUserInfo.name!
            received_chat_message.messageDate = Date.init()
            self.delegate?.meetingDidReceivedSystemChatMessage(received_chat_message)
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedSystemCallHostGroupId groupId: NSNumber, senderId: NSNumber) {
        guard self.user_info?.role != "attendee" else {
            return
        }
        dispatch_async_on_main_queue { [weak self] in
            self?.delegate?.meetingDidReceivedMemberCallHost(groupId.intValue, senderId: senderId.int32Value)
        }
    }
        
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedSystemCustomMessage opts: [AnyHashable : Any], type typeName: String, senderId: NSNumber) {
        dispatch_async_on_main_queue {
            switch typeName {
            case "poll_commit":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCommitData"), object: nil)
                break
            case "poll_start":
                if (self.user_info?.role == "attendee" && senderId.int32Value != self.user_info?.user_id) {
                    let vote_id = opts["vote_id"] as! String
                    guard !vote_id.isEmpty else {
                        return
                    }
                    self.delegate?.meetingDidReceivedRoteStartMessage(vote_id)
                }
                break
            case "poll_publishResult":
                if (self.user_info?.role == "attendee" && senderId.int32Value != self.user_info?.user_id) {
                    let vote_id = opts["vote_id"] as! String
                    guard !vote_id.isEmpty else {
                        return
                    }
                    self.delegate?.meetingDidReceivedPublishVoteResult(vote_id)
                }
                break
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
                break
            }
        }
    }
    
    internal func cls_PlatformManager(_ manager: CLS_PlatformManager, receivedSystemChatChannelMessageWithContent content: String, receivedType type: String, senderId: NSNumber) {
        guard senderId.int32Value != self.user_info?.user_id else {
            return
        }
        dispatch_async_on_main_queue { [weak self] in
            let senderUserInfo:UserInfoStruct = (self?.searchUser(with: senderId.int32Value)!)!
            if (self!.isBreakout && senderUserInfo.groupId == self!.user_info!.groupId) {
                let received_chat_message:MeetingChatMessageDataModel = MeetingChatMessageDataModel.init()
                received_chat_message.chat_message = content
                received_chat_message.userId = senderId.stringValue
                received_chat_message.user_name = senderUserInfo.name!
                received_chat_message.messageDate = Date.init()
                self?.delegate?.meetingDidReceivedSystemChatMessage(received_chat_message)
            } else {
                let received_chat_message:MeetingChatMessageDataModel = MeetingChatMessageDataModel.init()
                received_chat_message.chat_message = content
                received_chat_message.userId = senderId.stringValue
                received_chat_message.user_name = senderUserInfo.name!
                received_chat_message.messageDate = Date.init()
                self?.delegate?.meetingDidReceivedSystemChatMessage(received_chat_message)
            }
        }
    }
}
