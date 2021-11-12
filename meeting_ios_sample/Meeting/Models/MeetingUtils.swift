//
//  MeetingUtils.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/7.
//

import Foundation

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let navTitleColor = HEXColor(h:0x666666)
let mainColor = HEXColor(h:0x127BF8)
let leftItemBlackColor = HEXColor(h:0x666666)
let mainBlackColor = HEXColor(h:0x333333)
let klineColor = HEXColor(h:0xEEEEEE)
let graylineColor = HEXColor(h:0x121212)
let grayBlackTextColor = HEXColor(h:0x999999)
let grayTextColor = HEXColor(h:0xCCCCCC)
let placeHoldColor = HEXColor(h:0xc9c8cb)
let backGroundColor = HEXColor(h:0xf8f8f8)

func HEXColor(h:Int) -> UIColor {
    return RGBColor(r: CGFloat(((h)>>16) & 0xFF), g:   CGFloat(((h)>>8) & 0xFF), b:  CGFloat((h) & 0xFF),a:1.0)
}

func HEXColorA(h:Int,a:CGFloat) -> UIColor {
    return RGBColor(r: CGFloat(((h)>>16) & 0xFF), g:CGFloat(((h)>>8) & 0xFF), b:  CGFloat((h) & 0xFF),a:a)
}

func RGBColor(r:CGFloat,g:CGFloat,b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

//iPhonex以上判断

let IS_IPhoneX_All = UIDevice.current.isiPhoneXMore()

//导航栏高

let NaviBar_Height = (IS_IPhoneX_All ? 88 : 64)

//状态栏高

let StatusBar_Height = (IS_IPhoneX_All ? 44 : 20)

//选项卡高

let TabBar_Height = (IS_IPhoneX_All ? 83 : 69)

//安全区高

let SafeArea_BottomHeight = (IS_IPhoneX_All ? 34 : 0)

extension UIDevice {
    public func isiPhoneXMore() -> Bool {
        var isMore:Bool = false
        if #available(iOS 11.0, *) {
            isMore = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! > 0.0
        }
        return isMore
    }
}

enum CLS_MenuItem: Int {
    case audio = 0, video, share, members, more
}

enum CLS_MeetingJoinType: Int {
    case fromFast = 1, fromList
}

struct UserInfoStruct: Convertable, Hashable {
    
    var name:           String?
    var audio:          Bool?
    var video:          Bool?
    var role:           String?
    var groupId:        Int?
    var hand:           Bool?
    var share:          String?
    var user_id:    Int32?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(audio)
        hasher.combine(video)
        hasher.combine(role)
        hasher.combine(groupId)
        hasher.combine(hand)
        hasher.combine(share)
        hasher.combine(user_id)
    }
}

struct MeetingJoinInfo: Convertable {
    var meeting_code:           Int32?
    var meeting_nickname:       String?
    var meeting_muteType:       Int?
    var meeting_type:           CLS_MeetingJoinType?
    var is_admin:               Bool?
    var carmera_status:         Bool! = true
    var audio_status:           Bool! = true
    var speaker_status:         Bool! = true
}

struct JoinMeetingDataModel: Convertable {
    var token:          String?
    var appKey:         String?
    var roomId:         Int32?
    var shareUserId:    Int32?
    var shareUserToken: String?
    var isBreakout:     Bool?
}

struct MeetingShareInfoModel {
    var sharerId:       Int32?
    var sharerToken:      String?
}

struct MeetingRoomAttrsModel: Convertable {
    var audio:      Bool?
    var enableAudioChange:  Bool?
    var subRooms:   [MeetingGroupInfo]
}

struct MeetingGroupInfo: Convertable {
    var id:         Int?
    var name:       String?
    var users:      Array<Int32>?
}

protocol Convertable: Codable {

}

extension Convertable {
    /// 直接将Struct或Class转成Dictionary
    func convertToDict() -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            print("init student")
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            print("struct convert to data")
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        } catch {
            print(error)
        }
        return dict
    }
}


extension CLS_MeetingJoinType: Codable {
    
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 1:
            self = .fromFast
        case 2:
            self = .fromList
        default:
            throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .fromFast:
            try container.encode(1, forKey: .rawValue)
        case .fromList:
            try container.encode(2, forKey: .rawValue)
        }
    }
}

extension String {
    func boolValue() -> Bool? {
        let trueValues = ["true", "yes", "1"]
        let falseValues = ["false", "no", "0"]

        let lowerSelf = self.lowercased()

        if trueValues.contains(lowerSelf) {
            return true
        } else if falseValues.contains(lowerSelf) {
            return false
        } else {
            return nil
        }
    }
}
