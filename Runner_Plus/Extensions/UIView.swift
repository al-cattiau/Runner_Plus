//
//  File.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/16.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit

extension UIView {
    func addBlur(){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.frame
        self.superview!.insertSubview(blur, belowSubview: self)
    }
    
    func addShadow(){
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.3
    }
}
