//
//  MeetingManagerDelegate.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/8.
//

import Foundation

protocol MeetingManagerDelegate: NSObjectProtocol {
    func meetingUsersDidJoin(users: Array<UserInfoStruct>)
    func meetingDidReceivedCurrentUserBeKickedout()
    func meetingDidReceivedUserLeave(_ userId: Int32)
    func meetingDidReceivedCurrentUserHaveToLeave(_ reason: String)
    func meetingDidReceivedAttrs(attrs: MeetingRoomAttrsModel)
    func meetingDidReceivedUserAttrsUpdate(updateType: String!, updateValue: Any!, updateUser: Int32)
    func meetingDidReceivedRoomAttrsUpdate(updateType: String!, updateValue: Any!, updateRoomId: Int32)
    func meetingDidReceivedSystemChatMessage(_ model: MeetingChatMessageDataModel)
    func meetingDidReceivedPowerChangedRequest(_ power_name: String, value: Any)
    func meetingDidReceivedGroupBreakoutNotify(_ group_info: Dictionary<Int, MeetingGroupInfo>, selfInGroup: Int)
    func meetingDidReceivedGroupMoveRequest(_ target_group: Int)
    func meetingDidReceivedBreakoutStatusChanged(_ status:Bool)
    func meetingDidReceivedMemberCallHost(_ groupId: Int, senderId: Int32)
    func meetingDidReceivedScreenShareStream()
    
    func meetingDidReceivedAudioChangedRequest(_ from: Int32, value: Bool)
    func meetingDidReceivedVideoChangedRequest(_ from: Int32, value: Bool)
    func meetingDidReceivedRoleChangedRequest(_ from: Int32, value: String)
    func meetingDidReceivedNameChagnedRequest(_ from: Int32, value: String)
    
    func meetingDidReceivedWhiteboardMessage(_ message: String)
    func meetingDidReceivedChatMessage(_ message: String, sender_info: Int32)
    
    func meetingDidReceivedRoteStartMessage(_ voteId: String)
    func meetingDidReceivedPublishVoteResult(_ voteId: String)
    
    
}
