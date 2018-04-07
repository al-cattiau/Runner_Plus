//
//  Realm.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/2.
//  Copyright © 2018年 liujx. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}
