//
//  Record.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/14.
//  Copyright © 2018年 liujx. All rights reserved.
//

import Foundation
import RealmSwift


class Record: Object {
    @objc dynamic var date: Date
    @objc dynamic var locations: [CLLocation]
    @objc dynamic var calorie: Float
    @objc dynamic var time: Float //用时
    @objc dynamic var mapSnap: UIImage // 跑步截图
    @objc dynamic var distance: Float
}

