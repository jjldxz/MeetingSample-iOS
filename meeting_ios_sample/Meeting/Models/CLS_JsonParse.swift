//
//  CLS_JsonParse.swift
//  meeting_ios_sample
//
//  Created by Fox Doggy on 2021/9/6.
//

import Foundation

func JSON<T:Codable>(withJSONObject obj: Any?, modelType:T.Type) ->T? {
    guard let obj = obj else {
        return nil
    }
    do {
        if ((obj as AnyObject).isKind(of: NSString.self)) {
            guard let jsonData = (obj as! String).data(using: .utf8) else { return nil }
            let model = try JSONDecoder().decode(modelType, from: jsonData)
            return model
        } else if ((obj as AnyObject).isKind(of: NSDictionary.self)) {
            let jsonData = try! JSONSerialization.data(withJSONObject: obj as Any, options: [])
            let model = try JSONDecoder().decode(modelType, from: jsonData)
            return model
        } else if ((obj as AnyObject).isKind(of: NSArray.self)) {
            let jsonData = try! JSONSerialization.data(withJSONObject: obj as Any, options: [])
            let model = try JSONDecoder().decode(modelType, from: jsonData)
            return model
        } else if ((obj as AnyObject).isKind(of: NSData.self)) {
            let model = try JSONDecoder().decode(modelType, from: obj as! Data)
            return model
        } else {
            return nil
        }
    } catch {
        print(error)
        return nil
    }
}

func modelToString<T:Codable>(withModel model:T?) -> String? {
    guard let model = model else {
        return nil
    }
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(model)
        return String(data: data, encoding: .utf8)
    } catch {
        print(error)
        return nil
    }
}
