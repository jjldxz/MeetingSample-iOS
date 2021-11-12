//
//  LoginUserDataModel.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/1.
//

import UIKit

class LoginUserDataModel: NSObject {
    static let manager = LoginUserDataModel()
    
    open var userId:Int32?
    open var authToken:String?
    open var refreshToken:String?
    open var user_name:String?
    
    override init() {
        super.init()
    }
    
}
