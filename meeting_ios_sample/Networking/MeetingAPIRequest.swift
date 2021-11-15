//
//  MeetingAPIRequest.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/8/31.
//

import UIKit
import Alamofire

class MeetingAPIRequest: NSObject {
    static let shareManager = MeetingAPIRequest()
    
    static let BaseURL:String = <#SERVER_API_URL#>
    
    var requestHeader:HTTPHeaders = ["Content-Type": "application/json"]
    
    private override init() {
        super .init()
    }
    
    func settingUserAuthToken(token: String) {
        if !token.isEmpty {
            requestHeader.add(name: "Authorization", value: "Bearer ".appending(token))
        }
    }
    
    class func userLogin(name: String, password: String, responseObject:@escaping (_ response:Any?) -> Void)  {
        if (name.isEmpty == false && password.isEmpty == false) {
            let requestURL = BaseURL.appending("/common/login/") as String
            AF.request(requestURL, method: .post, parameters: ["username": name, "password": password], encoding: JSONEncoding.prettyPrinted, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func userRegist(name: String, password: String, responseObject:@escaping (_ response: Any?) -> Void) {
        if (name.isEmpty == false && password.isEmpty == false) {
            AF.request(BaseURL.appending("/common/register/"), method: .post, parameters: ["username": name, "password": password], encoding: JSONEncoding.prettyPrinted, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func usernameVerify(username: String, responseObject:@escaping (_ response: Any?) -> Void) {
        if !username.isEmpty {
            AF.request(BaseURL.appending("/common/verify_username/"), method: .post, parameters: ["username": username], encoding: JSONEncoding.prettyPrinted, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingDel(meetings: Array<Int32>, responseObject:@escaping (_ response: Any?) -> Void) {
        if !meetings.isEmpty {
            AF.request(BaseURL.appending("/meeting/del/"), method: .post, parameters: ["meetings": meetings], encoding: JSONEncoding.prettyPrinted, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingInfo(number: Int32, responseObject:@escaping (_ response: Any?) -> Void) {
        if (number >= 100000000 && number <= 999999999) {
            AF.request(BaseURL.appending("/meeting/info/"), method: .get, parameters: ["number": number], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingJoin(number: Int32, password: String?, responseObject:@escaping (_ response: Any?) -> Void) {
        if (number >= 100000000 && number <= 999999999) {
            var parameter = ["number": number] as [String: Any]
            if (password != nil) {
                parameter["password"] = password
            }
            AF.request(BaseURL.appending("/meeting/join/"), method: .post, parameters:parameter, encoding: JSONEncoding.prettyPrinted, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingList(startAt: String, endAt: String, responseObject:@escaping (_ response: Any?) -> Void) {
        if (startAt.isEmpty == false && endAt.isEmpty == false) {
            AF.request(BaseURL.appending("/meeting/list/"), method: .get, parameters:["beginAt": startAt, "endAt": endAt], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingCreate(name: String, beginAt: String, endAt: String, muteType: Int, password: String?, responseObject:@escaping (_ response: Any?) -> Void) {
        if (name.isEmpty == false && beginAt.isEmpty == false && endAt.isEmpty == false) {
            var parameters:Dictionary<String, Any> = ["name": name, "beginAt": beginAt, "endAt": endAt, "muteType": muteType]
            if (password != nil && !password!.isEmpty) {
                parameters["password"] = password
            }
            AF.request(BaseURL.appending("/meeting/new/"), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingStop(number: Int32, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/meeting/stop/"), method: .post, parameters: ["number": number], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
        
    }
    
    class func meetingShareStart(number: Int32, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/meeting/start_share/"), method: .post, parameters: ["number": number], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
    }
    
    class func meetingShareStop(number: Int32, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/meeting/stop_share/"), method: .post, parameters: ["number": number], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
    }
    
    
    // MARK: - poll api url
    class func meetingPollAnswer(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/poll/answer/"), method: .get, parameters:["id": poll_id], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
    }
    
    class func meetingPollCommit(poll_id: Int, questions: Array<Int>, responseObject:@escaping (_ response: Any?) -> Void) {
        if (poll_id > 0 && questions.isEmpty == false) {
            AF.request(BaseURL.appending("/poll/commit/"), method: .post, parameters: ["pollId": poll_id, "questions": questions], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollDel(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        if poll_id > 0 {
            AF.request(BaseURL.appending("/poll/del/"), method: .post, parameters: ["pollId": poll_id], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollDetail(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/poll/detail/"), method: .get, parameters:["id": poll_id], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
    }
    
    class func meetingPollList(number: Int32, responseObject:@escaping (_ response: Any?) -> Void) {
        AF.request(BaseURL.appending("/poll/list/"), method: .get, parameters:["number": number], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
            responseObject(responseObj.value)
        }
    }
    
    class func meetingPollCreate<T>(number: Int32, questions:Array<T>, title: String, isAnonymous: Bool, responseObject:@escaping (_ response: Any?) -> Void) {
        if (number > 0 && questions.count > 0 && title.isEmpty == false) {
            AF.request(BaseURL.appending("/poll/new/"), method: .post, parameters: ["number": number, "questions": questions, "title": title, "isAnonymous": isAnonymous], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollResult(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        if (poll_id > 0) {
            AF.request(BaseURL.appending("/poll/result/"), method: .get, parameters:["id": poll_id], encoding: URLEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollShare(poll_id: Int, share: Bool, responseObject:@escaping (_ response: Any?) -> Void) {
        if poll_id > 0 {
            AF.request(BaseURL.appending("/poll/share/"), method: .post, parameters: ["id": poll_id], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollStart(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        if (poll_id > 0) {
            AF.request(BaseURL.appending("/poll/start/"), method: .post, parameters:["id": poll_id], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollStop(poll_id: Int, responseObject:@escaping (_ response: Any?) -> Void) {
        if (poll_id > 0) {
            AF.request(BaseURL.appending("/poll/stop/"), method: .post, parameters:["id": poll_id], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingPollUpdate<T>(number: Int32, questions:Array<T>, title: String, isAnonymous: Bool, responseObject:@escaping (_ response: Any?) -> Void) {
        if (number > 0 && questions.count > 0 && title.isEmpty == false) {
            AF.request(BaseURL.appending("/poll/update/"), method: .post, parameters: ["number": number, "questions": questions, "title": title, "isAnonymous": isAnonymous], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    // MARK: - group api
    class func meetingStartGroup(with number: Int32, group:Array<Dictionary<String, Any>>, responseObject: @escaping (_ response: Any?) -> Void) {
        if (number > 0 && group.count > 0) {
            AF.request(BaseURL.appending("/group/start/"), method: .post, parameters: ["number": number, "group": group], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingStopGroup(with number: Int32, group:Array<Dictionary<String, Any>>, responseObject: @escaping (_ response: Any?) -> Void) {
        if (number > 0 && group.count > 0) {
            AF.request(BaseURL.appending("/group/stop/"), method: .post, parameters: ["number": number, "group": group], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingGroupDetail(with number: Int32, responseObject: @escaping (_ response: Any?) -> Void) {
        if number > 0 {
            AF.request(BaseURL.appending("/group/detail/"), method: .post, parameters: ["number": number], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
    
    class func meetingGroupMoveMember(with number: Int32, members: Array<Int32>, fromGroup: Int32, toGroup: Int32, responseObject: @escaping (_ response: Any?) -> Void) {
        if (number >= 0 && members.count > 0 && fromGroup >= 0 && toGroup >= 0) {
            AF.request(BaseURL.appending("/group/move_member/"), method: .post, parameters: ["number": number, "members": members, "fromGroup": fromGroup, "toGroup": toGroup], encoding: JSONEncoding.default, headers: shareManager.requestHeader).validate().responseJSON { responseObj in
                responseObject(responseObj.value)
            }
        } else {
            responseObject(nil)
        }
    }
}


