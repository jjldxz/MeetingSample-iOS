//
//  RTMControlChannalModel.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/15.
//

import UIKit
import Foundation

func videoChange(roomId: Int32, userId: Int32, value: Bool) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_video_change", "value": value, "roomId": roomId, "userId": userId]
}

func AudioChange(roomId: Int32, userId: Int32, value: Bool) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_audio_change", "value": value, "roomId": roomId, "userId": userId]
}

func NameChange(roomId: Int32, userId: Int32, value: String) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_name_change", "value": value, "roomId": roomId, "userId": userId]
}

func RoleChange(roomId: Int32, userId: Int32, value: String) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_role_change", "value": value, "roomId": roomId, "userId": userId]
}

func CustomEvent(subType: String, opts: Dictionary<String, Any>) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_custom_signal", "subType": subType, "data": opts]
}

func MoveUserToBreakoutGroups(toRoomId: Int, userIds:Array<Int32>) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_move_user_to_room_request", "toRoomId": toRoomId, "userIds": userIds]
}

func BroadcastMessageToGroups(senderId: Int32, message: String, groupId: Int) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_broadcast_message_to_groups", "groupId": groupId, "senderId": senderId, "messaage": message]
}

func CallHostToRoom(senderId: Int32, groupId: Int) -> Dictionary<String, Any> {
    return ["kind": "msg_control", "type": "ctl_call_host_to_group", "senderId": senderId, "groupId": groupId]
}
