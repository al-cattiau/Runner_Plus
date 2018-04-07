//
//  ReminderRepeatSetting.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/4.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderRepeatSetting: UITableViewController {
    override func viewDidLoad() {
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isRepeat = UserDefaults.getReminderRepeat()
        
        if indexPath.row == 0 {
            cell.accessoryType = isRepeat ? .checkmark : .none
        }else if indexPath.row == 1{
            cell.accessoryType = isRepeat ?   .none : .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UserDefaults.setReminderRepeat(isRepeat: true)
        }else if indexPath.row == 1{
            UserDefaults.setReminderRepeat(isRepeat: false)
        }
        tableView.reloadData()
    }
    
    //
    func updateNotification(){
        let center = UNUserNotificationCenter.current()
        // 获取当前的通知中心对象
        center.removeAllPendingNotificationRequests()
        // 将目前等待发出的所有推送通知取消
        guard let date = UserDefaults.getReminderDate() else{
            // 获取用户设定的提醒日期
            return;
        }
        let content = UNMutableNotificationContent()
        // 实例化一个通知内容对象
        // 设置通知的声音，标题以及内容
        content.title = "已到跑步时间"
        content.body = "开启 Runner Pro 完成今天的目标吧~"
        content.sound = UNNotificationSound.default()
        let unitFlags:Set<Calendar.Component> = [
            .hour, .minute, .second
        ]
        let dateComponent = Calendar.current.dateComponents(unitFlags, from: date)
        //设定日期
        let isRepeat = UserDefaults.getReminderRepeat()
        // 根据用户在设置中的操作决定是否重复提醒
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: isRepeat)
        // 添加这个通知到系统的通知中心
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
