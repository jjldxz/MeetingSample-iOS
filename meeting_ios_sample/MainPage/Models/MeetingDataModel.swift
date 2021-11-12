//
//  MeetingDataModel.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/2.
//

import Foundation


struct meetingInfoStruct:Codable {
    var name:       String?
    var number:     Int32?
    var password:   String?
    var ownerName:  String?
    var ownerId:    Int?
    var status:     Int?
    var beginAt:    String?
    var endAt:      String?
    var muteType:   Int?
}
