//
//  UserDefaults.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/19.
//  Copyright © 2018年 liujx. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let durationSetting = "duration"
    static let distanceSetting = "distance"
    static let weightSetting = "weightSetting"
    static let reminderDate = "reminderDate"
    static let reminderRepeat = "reminderRepeat"
}

extension UserDefaults {
    static func durationSetting()-> Float{
        let value = UserDefaults.standard.float(
            forKey: UserDefaultsKeys.durationSetting)
        return value != 0 ? value : 30.0 // 默认 30.0 分钟
    }
    
    static func distanceSetting()-> Float{
        let value = UserDefaults.standard.float(
            forKey: UserDefaultsKeys.distanceSetting)
        return value != 0 ? value : 5.0 // 默认 5.0 公里
    }
    
    static func weightSetting()-> Int{
        let value = UserDefaults.standard.integer(
            forKey: UserDefaultsKeys.weightSetting)
        return value  // 没有默认值
    }
    
    static func getReminderDate() -> Date? {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.reminderDate) as? Date
    }
    
    static func setReminderRepeat(isRepeat: Bool){
        UserDefaults.standard.set(isRepeat, forKey: UserDefaultsKeys.reminderRepeat)
    }
    
    static func clearReminder(){
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.reminderRepeat)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.reminderDate)
    }
    
    
    
    static func getReminderRepeat() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.reminderRepeat)
    }
    
    static func setReminderDate(date: Date?)  {
        UserDefaults.standard.set(date, forKey: UserDefaultsKeys.reminderDate)
    }
    
    static func hasWeightSetBefore() -> Bool{
        return Int(UserDefaults.standard.integer(
            forKey: UserDefaultsKeys.weightSetting)) != 0
    }
    
    static func setDurationSetting(to value: Float){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.durationSetting)
    }
    
    static func setDistanceSetting(to value: Float){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.distanceSetting)
    }
    
    static func setWeightSetting(to value: Int){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.weightSetting)
    }
}
