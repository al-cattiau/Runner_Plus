//
//  Int.swift
//  Runner_Pro
//
//  Created by liu jx on 2017/12/31.
//  Copyright © 2017年 Liu jx. All rights reserved.
//

import Foundation


extension Int {
    func mapSecondToDigiString() -> String {
        var timeText = ""
        
        let min = self / 60
        let sec = self % 60
        
        if min > 10 {
            timeText += "\(min)"
        }else if min > 0 {
            timeText += "0\(min)"
        }else{
            timeText += "00"
        }
        
        timeText += " : "
        if sec >= 10 {
            timeText += "\(sec)"
        }else if sec > 0{
            timeText += "0\(sec)"
        }else {
            timeText += "00"
        }
        return timeText
    }
    
    func mapSecondToFormattedStirng() -> String {
        var timeText = ""
        let hour = self / 3600
        let min = self % 3600 / 60
        let sec = self % 60
        
        if hour > 0 {
            timeText += "\(hour) h "
        }
        if min > 0 {
            timeText += "\(min) min "
        }
        if sec > 0 {
            timeText += "\(sec) sec"
        }
        
        return timeText
    }
}

extension Float {
    func clipTopTwoToString() -> String {
        return NSString(format: "%.2f", self) as String
    }
    
    func clipTopOneToString() -> String {
        return NSString(format: "%.1f", self) as String
    }
    
    func checkIfDecpartLargerThanOne() -> Bool {
        return self.clipTopOneToString() == "\(self)"
    }
    
    func checkIfTooLarge() -> Bool {
        return Int(self) > 100
    }
}

extension String {
    
    func appendDistanceDescription() -> String {
        return "距离： \(self) 公里"
    }
    
    func appendDistanceDescription(prefix: String) -> String {
        return "\(prefix) \(self) 公里"
    }
    
    func appendCalorieDescription(prefix: String) -> String {
        return "\(prefix) \(self) 千卡"
    }
    
    func appendCalorieDescription() -> String {
        return "消耗能量： \(self) 千卡"
    }
    
    func appendTimeDescription(prefix: String) -> String {
        return "\(prefix) \(self)"
    }
    
    func appendTimeDescription() -> String {
        return "用时： \(self)"
    }
    
    func appendStepperDescription() -> String {
        return "平均步速： \(self)"
    }
    
    func appendStepperDescription(prefix: String) -> String {
        return "\(prefix) \(self)"
    }
}


extension Date {

    func compareLatterTimeOnly(to: Date) -> Bool {
        let calendar = Calendar.current
        let components2 = calendar.dateComponents([.hour, .minute, .second], from: to)
        let date3 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!
        
        let seconds = calendar.dateComponents([.second], from: self, to: date3).second!
        if seconds == 0 {
            return true
        } else if seconds > 0 {
            
            return true
        } else {
            return false
        }
    }

    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func convertDateToSimpleString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd hh:mm"
        return dateFormatter.string(from: self)
    }
    
    func getLocalTimeZoneDate()-> Date{
        let timeZone = NSTimeZone.system
        let interval = timeZone.secondsFromGMT(for: self)
        let localDate = self.addingTimeInterval(Double(interval))
        
        return localDate
    }
    
    func mapDateToChineseString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let day = dateFormatter.string(from: self)
        switch day {
        case "Sunday" :
            return "周日"
        case "Monday":
            return "周一"
        case "Tuesday":
            return "周二"
        case "Wednesday":
            return "周三"
        case "Thursday":
            return "周四"
        case "Friday":
            return "周五"
        case "Saturday":
            return "周六"
        default:
            return day
        }
    }
}

