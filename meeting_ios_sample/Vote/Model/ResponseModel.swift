//
//  ResponseModel.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/10.
//

import UIKit
import HandyJSON

class ResponseModel: HandyJSON {
    var code : Int = 0
    var data : Any = []
    var message = ""
    
    required init() {
        code = 0
        data = []
        message = ""
    }
}
