//
//  Achievement.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/20.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Achievement: UIViewController {

    @IBOutlet weak var totalCalorie: UILabel!
    @IBOutlet weak var totalTimes: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var timerMode: UILabel!
    @IBOutlet weak var distanceMode: UILabel!
    @IBOutlet weak var baseMode: UILabel!
    @IBOutlet weak var card2Top: NSLayoutConstraint!
    @IBOutlet weak var card1Top: NSLayoutConstraint!
     @IBOutlet weak var shareHeightConstraint: NSLayoutConstraint!
    var records: [Record] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shareHeightConstraint.constant = 0
        card1Top.constant = 100
        card2Top.constant = 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let realm = try! Realm()
        // 获取数据库实例
        records = realm.objects(Record.self).toArray()
        // 将所有的跑步记录取出并转化为数组
        shareHeightConstraint.constant = 18
        card1Top.constant = 20
        card2Top.constant = 35
        // 更新 UI 的 constrains
        UIView.animate(withDuration: 0.2) {
            // 通知系统在一定时间内更新界面，达到过渡动画的效果
            self.view.layoutIfNeeded()
        }
        
        // 界面上各个文本元素的值的设置
        totalDistance.text = records.reduce(0, { (result, record) -> Float in
            return result + record.distance
        }).clipTopOneToString().appendDistanceDescription(prefix: "")
        
        totalTimes.text = records.reduce(0, { (result, record) -> Int in
            return result + record.time
        }).mapSecondToDigiString()
        
        totalCalorie.text = records.reduce(0, { (result, record) -> Float in
            return result + record.getCalorie()
        }).clipTopOneToString().appendCalorieDescription(prefix: "")
        
        baseMode.text = "\(records.filter({$0.mode == 0}).count) 次"
        timerMode.text = "\(records.filter({$0.mode == 1}).count) 次"
        distanceMode.text = "\(records.filter({$0.mode == 2}).count) 次"
    
    }
    
    @IBAction func share(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(vc, animated: true , completion: nil)
        
    }
    
}
