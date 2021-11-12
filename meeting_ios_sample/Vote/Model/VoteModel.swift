//
//  VoteModel.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/2.
//

import UIKit
import HandyJSON

class JsonUtil: NSObject {
    /**
     *  Json转对象
     */
    static func jsonToModel<T:HandyJSON>(_ jsonStr:String,_ modelType:T.Type) ->T {
        if jsonStr == "" || jsonStr.count == 0 {
            #if DEBUG
                print("jsonoModel:字符串为空")
            #endif
            return T()
        }
        return modelType.deserialize(from: jsonStr)!
        
    }
    
    /**
     *  Json转数组对象
     */
    static func jsonArrayToMode<T:HandyJSON>(_ jsonArrayStr:String, _ modelType:T.Type) ->[T] {
        if jsonArrayStr == "" || jsonArrayStr.count == 0 {
            #if DEBUG
                print("jsonToModelArray:字符串为空")
            #endif
            return []
        }
        var modelArray:Array<T> = Array.init()
        let data = jsonArrayStr.data(using: String.Encoding.utf8)
        let peoplesArray = try! JSONSerialization.jsonObject(with:data!, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
        for people in peoplesArray! {
            modelArray.append(dictionaryToModel(people as! [String : Any], modelType))
        }
        return modelArray
        
    }
    
    /**
     *  字典转对象
     */
    static func dictionaryToModel<T:HandyJSON>(_ dictionStr:[String:Any],_ modelType:T.Type) -> T {
        if dictionStr.count == 0 {
            #if DEBUG
                print("dictionaryToModel:字符串为空")
            #endif
            return T()
        }
        return modelType.deserialize(from: dictionStr)!
    }
    
    /**
     *  对象转JSON
     */
    static func modelToJson<T:HandyJSON>(_ model:T?) -> String {
        if model == nil {
            #if DEBUG
                print("modelToJson:model为空")
            #endif
             return ""
        }
        return (model?.toJSONString())!
    }
    
    /**
     *  对象转字典
     */
    static func modelToDictionary<T:HandyJSON>(_ model:T?) -> [String:Any] {
        if model == nil {
            #if DEBUG
                print("modelToJson:model为空")
            #endif
            return [:]
        }
        return (model?.toJSON())!
    }
    
}

class VoteModel: HandyJSON {
    var id = ""
    var title = ""
    var isAnonymous = 0 // 0:非匿名 1:匿名
    var status: Int? // 0:未开始 1:进行中 2：已结束
    var questions : [VoteQustionModel]?
    var creatquestions : NSMutableArray?
    var createrId : NSString?
    var voterNum:   Int?
    var room_id : NSString?
    var is_publishing :  Int?
    var share:  Bool?
    var meeting:    Int?
    required init() {
        id = ""
        title = ""
        createrId = ""
        isAnonymous = 0
        room_id = ""
        status = 0
        questions = [VoteQustionModel.init()]
        creatquestions = [VoteQustionModel.init()]
    }
}

class VoteQustionModel: HandyJSON {
    var id : NSString?
    var content : NSString?
    var isSingle : Int?
    var options : [VoteOptionModel]
    var itemArray : NSMutableArray?
    var optionArray : NSMutableArray?
    required init() {
        id = ""
        isSingle = 1
        content = ""
        options = [VoteOptionModel()]
        itemArray = NSMutableArray.init(array: options)
        optionArray = NSMutableArray.init()
    }
}

class VoteOptionModel: HandyJSON {
    var id : NSString?
    var content : NSString?
    var count : Int?
    var voters : Array<Dictionary<String, Any>>?
    var is_single : Int?
    var is_select : Bool?
    required init() {
        id = ""
        content = ""
        is_single = 1
        voters = []
        count = 0
        is_select = false
    }
    
    func mapping(mapper: HelpingMapper) {
          mapper <<<
              self.is_select <-- "select"
    }
}



class VoteModelList : HandyJSON {
    required init() {
        data = [VoteModelListItem].init()
    }
    
    var data : [VoteModelListItem]
}

class VoteModelListItem : HandyJSON {
    var id :  NSString?
    var isAnonymous :  Int?
    var status :  Int?
    var title :  NSString?
    var createrId : NSString?
    var roomId : NSString?
    var share :  Bool?
    var questionCount : Array<VoteModel>?
    required init() {
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.questionCount <-- TransformOf<Array<VoteModel>, String>(fromJSON: { (rawString) -> Array<VoteModel>? in
                        ///用“/”分割字符创 创建元组
                guard rawString != nil else {
                    return nil
                }
                let questions = JsonUtil.jsonArrayToMode(rawString!, VoteModel.self)
                    return questions
                }, toJSON: { (tuple) -> String? in
                 ///返回上面创建的元组 再进行自定义格式
                    if let _tuple = tuple {
                        return _tuple.toJSONString()
                    }
                    return nil
                })
    }
}
