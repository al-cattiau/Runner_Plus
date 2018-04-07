//
//  ReminderSetting.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/3.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderSetting: UITableViewController {
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if (UserDefaults.getReminderDate() != nil) {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
        }else if indexPath.row == 1{
            let isRepeat = UserDefaults.getReminderRepeat()
            cell.detailTextLabel?.text = isRepeat ? "每天" : "不重复"
        }else if indexPath.row == 2 {
            if let date = UserDefaults.getReminderDate(){
                cell.detailTextLabel?.text = date.convertDateToSimpleString()
            }else {
                cell.detailTextLabel?.text = "无"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if (UserDefaults.getReminderDate() != nil) {
                UserDefaults.clearReminder()
                updateNotification()
                tableView.reloadData()
            }else {
                let datePicker = UIDatePicker()
                datePicker.date = Date().addingTimeInterval( 60 * 60 * 3)
                datePicker.datePickerMode = .time
                let alert = CustomAlert(title: "选择提醒时间", delegate: self, customView: datePicker)
                alert.show(animated: true, navigationView: navigationController!.view)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        }else if indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}


extension ReminderSetting: CustomModalDelegate {
    func touchConfirm(_ data: Any) {
        UserDefaults.setReminderDate(date: data as? Date)
        registerLocal()
        updateNotification()
        tableView.reloadData()
    }
    
    
    func touchCancel() {
        
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
            } else {
            }
        
        }
        
    }
    
    func updateNotification(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard let date = UserDefaults.getReminderDate() else{
            return;
        }
        
        let content = UNMutableNotificationContent()
        content.title = "已到跑步时间"
        content.body = "开启 Runner Pro 完成今天的目标吧~"
        content.sound = UNNotificationSound.default()
        
        let unitFlags:Set<Calendar.Component> = [
            .hour, .minute, .second
        ]
        
        let dateComponent = Calendar.current.dateComponents(unitFlags, from: date)
        let isRepeat = UserDefaults.getReminderRepeat()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: isRepeat)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
 
    
}
