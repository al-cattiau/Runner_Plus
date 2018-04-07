   //
//  AppDelegate.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/8.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if UserDefaults.getReminderRepeat() == false{
            if let date = UserDefaults.getReminderDate() {
                if date.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                   UserDefaults.clearReminder()
                }
            }
        }
        
        if let shortcutItem =
            launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
                as? UIApplicationShortcutItem {
            return true
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // 当用户使用 3D Touch 进入应用程序，此函数被调用
        if let type = RunModeShortCut(rawValue: shortcutItem.type) {
            // 判断进入的选项
            let vc = (application.keyWindow?.rootViewController as! UITabBarController).customizableViewControllers![0] as! RunningEntryViewController
            // 初始化入口 controller
            guard UserDefaults.hasWeightSetBefore() else {
                // 检测用户是否设置了体重，如果没有，跳转到设置里的体重设置界面
                let alert = UIAlertController(title: "提醒", message: "你还未设置体重，将导致卡路里统计不准确", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "好的", style: .cancel, handler: nil)
                let jumpToSetting = UIAlertAction(title: "去设置", style: .default, handler: {
                    _ in
                    let setting = vc.storyboard!.instantiateViewController(withIdentifier: "Setting") as! SettingsViewController
                    
                    let navigationController = UINavigationController(rootViewController: setting)
                    vc.present(navigationController, animated: true, completion: nil)

                })
                alert.addAction(jumpToSetting)
                alert.addAction(cancel)
                vc.present(alert, animated: true, completion: nil)
                completionHandler(true)
                return
            }
            let toRunVc = vc.storyboard!.instantiateViewController(withIdentifier: "recordVC") as! RunningRecordViewController
            // 根据用户进入时选择的类型初始化跑步记录 controller
            switch type {
                case .basic:
                    toRunVc.mode = .basic
                case .timer:
                    toRunVc.mode = .timer
                    toRunVc.targetValue = UserDefaults.durationSetting()
                case .distance:
                    toRunVc.mode = .timer
                    toRunVc.targetValue = UserDefaults.distanceSetting()
            }
            
            vc.present(toRunVc, animated: true, completion: nil)
            
            completionHandler(true)
        }else{
            completionHandler(false)
        }
    }
}

