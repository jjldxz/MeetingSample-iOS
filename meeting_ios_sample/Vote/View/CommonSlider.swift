//
//  CommonSlider.swift
//  meeting_iOS
//
//  Created by HYWD on 2021/6/12.
//

import UIKit

class CommonSlider: UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let newRect = CGRect(x: rect.origin.x - 10, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
        return  super.thumbRect(forBounds: bounds, trackRect: newRect, value: value).insetBy(dx: 20, dy: 10)
    }
    
}
