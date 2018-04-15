//
//  RunningRecordViewController.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/21.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Realm
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import AVFoundation

class RunningRecordViewController: UIViewController, CLLocationManagerDelegate {
    var mode: RunModeSegment!
    var targetValue: Float?
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet var targetView: UIView!
    @IBOutlet weak var dashBoardView: UIStackView!
    let record = Record()
    var realm: Realm!
    let locationManager = CLLocationManager()
    var bag: DisposeBag? = DisposeBag()
    var bagForTarget: DisposeBag? = DisposeBag()
    var recordObservable: Observable<Record>!
    var timer: Timer!
    var earlierLocation: CLLocation? = nil
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var progressContentWidth: NSLayoutConstraint!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var stopButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var targetLabel: UILabel!
    var animationBefore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetViewSetting()
        locationManager.delegate = self
        realm = try! Realm()
        record.date = Date()
        try! realm.write {
            realm.add(record)
        }
        recordObservable = Observable.from(object: record)
        initRecord()
        
        
    }
    
    func initRecord(){
        startTimer()
        bindUIToModel()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if animationBefore == false{
            stopButtonBottom.constant = -300
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.stopButtonBottom.constant = 20
        
        UIView.animate(withDuration: 1, delay: 5, options: [.curveEaseIn], animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.animationBefore = true
        }
        
    }
    
    func targetViewSetting(){
        switch mode {
        case .timer:
            fallthrough
        case .distance:
            view.addSubview(targetView)
            targetView.translatesAutoresizingMaskIntoConstraints = false
            targetView.topAnchor.constraint(equalTo: dashBoardView.bottomAnchor ).isActive = true
            targetView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            targetView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        default:
            return;
        }
    }
    
    
    
    func bindUIToModel(){
        _ = recordObservable
            .map{ $0.time.mapSecondToDigiString() }
            .subscribe(onNext: { (time) in
                self.timerLabel.text = time
            })
            .disposed(by: bag!)
        
        _ = recordObservable
            .map{ String(format: "%.2f", $0.distance) }
            .subscribe(onNext: { (distance) in
                self.distanceLabel.text = distance

            })
            .disposed(by: bag!)
        
        _ = recordObservable
            .skipWhile({ $0.distance == 0  })
            .map{ Record.calcuSpeedFrom(time: $0.time, to: $0.distance).mapSecondToFormattedStirng() }
            .subscribe(onNext: { (speed) in
                self.speedLabel.text = speed
                
            })
            .disposed(by: bag!)
        
        _ = recordObservable
            .map({ $0.distance })
            .subscribe({ (distance) in
                self.calorieLabel.text = "\(Int(Record.getCalorieBy(distance: distance.element!)))"
            }).disposed(by: bag!)
        
        
        switch mode {
            case .basic:
                break;
            case .timer:
                let targetSecond = self.targetValue! * 60
                targetLabel.text = targetValue!.clipTopOneToString() + "分钟"
                _ = recordObservable
                    .map({ Double($0.time) / Double(targetSecond) })
                    .subscribe(onNext: { (percent) in
                        let truePercent  = percent > 1 ? 1 : percent
                        if percent > 1 {
                            self.targetCompleteAlert()
                        }
                        
                        self.progressContentWidth.constant = CGFloat( truePercent * 300.0 )
                    }).disposed(by: bagForTarget!)
            
            case .distance:
                targetLabel.text = "\(targetValue!.clipTopOneToString())" + "公里"
                _ = recordObservable
                    .map({ Double($0.distance) / Double(self.targetValue!) })
                    .subscribe(onNext: { (percent) in
                        let truePercent  = percent > 1 ? 1 : percent
                        if percent > 1 {
                            self.targetCompleteAlert()
                        }
                        self.progressContentWidth.constant = CGFloat( truePercent * 300.0 )
                    }).disposed(by: bagForTarget!)
            default:
                break;
        }

    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (scheduledTimer) in
            try! self.realm.write {
                self.record.time += 1
            }
        }
        
    }
    
    func saveDataBeforeComplete( completion: @escaping()-> Void ){
        self.locationManager.stopUpdatingLocation()
        self.timer.invalidate()
        self.record.getMapSnap(completionHandler: { (data) in
            try! self.realm.write {
                self.record.mapSnap = data
                self.record.mode = self.mode.rawValue
                completion()
            }
        })
    }
    
    func targetCompleteAlert(){
        let alert = UIAlertController(title: "目标完成～", message: "你已经完成了你的目标", preferredStyle: .alert)
        let cancle = UIAlertAction(title: "我还能再跑两圈～", style: .default, handler: nil)
        let stop = UIAlertAction(title: "好，今天就到这里吧", style: .default, handler:  {
            _ in
            self.saveDataBeforeComplete(completion:  {
                self.dismiss(animated: true, completion: nil)
            })
        })
        alert.addAction(cancle)
        alert.addAction(stop)
        present(alert, animated: true, completion: nil)
        bagForTarget = nil
    }
    
    
    @IBAction func complete(_ sender: Any) {
        let alert = UIAlertController(title: "结束运动？", message: "系统将为你记录此次跑步的情况。", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            self.saveDataBeforeComplete( completion: { self.dismiss(animated: true, completion: {
                self.locationManager.stopUpdatingLocation()
                self.timer.invalidate()
                self.bag = nil
            })})
        }))
        
        alert.addAction(UIAlertAction(title: "我不想保存此次跑步记录", style: .destructive, handler: { (action) in
            self.dismiss(animated: true, completion: {
                self.locationManager.stopUpdatingLocation()
                self.timer.invalidate()
                self.bag = nil
                try! self.realm.write {
                    self.realm.delete(self.record)
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 如果最新获取到的精度数据精度小于零，即说明是一个错误的位置，丢弃
        // 如果最新获取的位置距离现在已经过去五秒以上，则说明是过时的缓存数据，丢弃
        guard (locations.last!.horizontalAccuracy > 0 && locations.last!.timestamp.timeIntervalSinceNow < 5) else {
            return;
        }
        
        if(earlierLocation == nil){
            // 存储上一次的位置信息，为了计算跑步距离用
            earlierLocation = locations.last!
        }else{
            // 写入数据库
            try! self.realm.write {
                // 距离等于最新位置与上一次位置距离加上之前的值
                record.distance += Float(locations.last!.distance(from: earlierLocation!) / 1000)
                // 初始化一个位置结构体
                let newLocation = Location()
                // 将获取到的经纬度
                newLocation.latitude = locations.last!.coordinate.latitude
                newLocation.longitude = locations.last!.coordinate.longitude
                // 将新的地理位置坐标存储到位置数组中
                record.locations.append(newLocation)
            }
            // 更新前一个位置
            earlierLocation = locations.last!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapReocrd"{
            let destination = segue.destination as! RunningMapRecordViewController
            destination.recordObservable = recordObservable
            
        }
    }
    
    @IBAction func turnOnFlashLight(_ sender: Any) {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                try device.lockForConfiguration()
                if(device.torchMode == .on ){
                    device.torchMode = .off
                }else{
                    device.torchMode = .on
                }
                
                device.unlockForConfiguration()   
            } catch {
                print("error")
            }
        }
    }
}
