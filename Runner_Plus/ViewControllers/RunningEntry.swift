//
//  RunningEntry.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/14.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import UserNotifications
import CoreLocation

class RunningEntryViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var runModeSegment: UISegmentedControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var iconSetting: UIButton!
    @IBOutlet weak var unitText: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var configure: UIButton!
    
    let durationSetting = BehaviorRelay<Float>(value: UserDefaults.durationSetting())
    let distanceSetting = BehaviorRelay<Float>(value: UserDefaults.distanceSetting())
    var runModeSegmentObservable: Observable<RunModeSegment>!
    let locationManager = CLLocationManager()
    var bag: DisposeBag? = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runModeSegmentObservable = runModeSegment.rx.selectedSegmentIndex.asObservable()
            .map{RunModeSegment(rawValue: $0)!}
        _ = runModeSegmentObservable.subscribe(onNext: {
            // 订阅分页控件，根据分页的变化改变下方的数字按钮与分页标签
            switch $0 {
            case .basic:
                self.configure.isHidden = true
                self.unitText.isHidden = true
            case .timer:
                self.configure.isHidden = false
                self.unitText.isHidden = false
                _ = self.durationSetting.asObservable().map{ $0.clipTopOneToString() }.bind(to: self.configure.rx.title(for: .normal))
                self.unitText.text = "分钟"
                
            case .distance:
                self.configure.isHidden = false
                self.unitText.isHidden = false
                _ = self.distanceSetting.asObservable().map{ $0.clipTopOneToString() }.bind(to: self.configure.rx.title(for: .normal))
                self.unitText.text = "公里"
            }
        })
        getLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewSetting()
    }
    
    func animateButtons(){
        self.startButton.transform = CGAffineTransform.identity
        self.startButton.layer.opacity = 1
        
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat,.allowUserInteraction,], animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.startButton.layer.opacity = 0.9
        }) { (finished) in
            guard finished else  {
                //说明用户触摸事件触发了新的动画，而中止了原动画
                return
            }
            self.startButton.transform = CGAffineTransform.identity
            self.startButton.layer.opacity = 1
        }
    }
    
    func getLocation(){
        locationManager.delegate = self
        // 将地理位置代理设置为自己，即这个 controller 将接受到新的位置
        locationManager.startUpdatingLocation()
        // 启动 GPS 定位
        locationManager.activityType = .fitness
        // 设置为健身类型，让位置信息更新尽量频繁
        
        let authStatus = CLLocationManager.authorizationStatus()
        // 获取用户目前位置授权信息，如果为未知，即表示用户还没有授权
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return;
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 用接收到的位置信息更新地图位置
        map.setRegion(MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 150, 150) , animated: true)
    }
    
    func viewSetting(){
        startButton.addShadow()
        iconSetting.addShadow()
        map.layer.opacity = 0.8
        configure.titleLabel?.adjustsFontSizeToFitWidth = true
        animateButtons()
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isRotateEnabled = false
        map.isPitchEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToRun"{
                let destination = segue.destination as! RunningRecordViewController
                _ = runModeSegmentObservable.subscribe(onNext: {
                    switch $0 {
                    case .timer:
                        destination.mode = .timer
                        destination.targetValue = self.durationSetting.value
                    case .distance:
                        destination.mode = .distance;
                        destination.targetValue = self.distanceSetting.value
                    case .basic:
                        destination.mode = .basic;
                    }
                })
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ToRun"{
            if UserDefaults.hasWeightSetBefore() {
                return true
        }else {
            let alert = UIAlertController(title: "提醒", message: "你还未设置体重，将导致卡路里统计不准确", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "好的", style: .cancel, handler: nil)
            let jumpToSetting = UIAlertAction(title: "去设置", style: .default, handler: {
                _ in
                let setting = self.storyboard!.instantiateViewController(withIdentifier: "Setting") as! SettingsViewController
                
                let navigationController = UINavigationController(rootViewController: setting)
                self.present(navigationController, animated: true, completion: nil)
                    
            })
            alert.addAction(jumpToSetting)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            return false
            }
        }
        return true
    }
    
    @IBAction func configureClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "设定距离", message: "给自己设一个小目标吧～", preferredStyle: .alert)
        let complete = UIAlertAction(title: "完成", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if(self.unitText.text == "公里"){
                self.distanceSetting.accept(Float(textField.text!)!)
            }else {
                self.durationSetting.accept(Float(textField.text!)!)
            }
        }
        let completeAndSetDefault = UIAlertAction(title: "完成并设置为默认", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if(self.unitText.text == "公里"){
                let distance = Float(textField.text!)!
                self.distanceSetting.accept(distance)
                UserDefaults.setDistanceSetting(to: distance)
            }else {
                let duration = Float(textField.text!)!
                self.durationSetting.accept(duration)
                UserDefaults.setDurationSetting(to: duration)
            }
        }
        
        let cancle = UIAlertAction(title: "取消", style: .default)
        alert.addTextField { (textField) in
            _ = self.runModeSegmentObservable.subscribe(onNext: {
                switch $0 {
                    case .timer:
                        textField.text = "\(self.durationSetting.value)"
                    case .distance:
                        textField.text = "\(self.distanceSetting.value)"
                    default:
                        return
                    
                }
            })
            textField.keyboardType = .decimalPad
        }
        
        let textObservable = alert.textFields![0].rx.text.asObservable()
            .map({
                $0!.count > 0 &&
                Float($0!)!.checkIfDecpartLargerThanOne() &&
                !Float($0!)!.checkIfTooLarge()
            })
        
        textObservable.bind(to: complete.rx.isEnabled).disposed(by: bag!)
        textObservable.bind(to: completeAndSetDefault.rx.isEnabled).disposed(by: bag!)
        alert.addAction(complete)
        alert.addAction(completeAndSetDefault)
        alert.addAction(cancle)
        present(alert, animated: true)
    }
    
}
