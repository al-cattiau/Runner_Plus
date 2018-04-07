//
//  RunningMapRecord.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/1.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import CoreLocation

class RunningMapRecordViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView! // 界面上的地图对象
    var recordObservable: Observable<Record>!
    // 从上一层 Controller 里面传过来一个关于此次记录的可观察对象
    var polyline: MKPolyline!
    var bag: DisposeBag? = DisposeBag()
    
    override func viewDidLoad() {
        map.delegate = self
        // 声明自己为地图对象的代理，即接管地图的绘制与更新
        _ = recordObservable.map({ ($0.locations, $0.distance, $0) }).subscribe(onNext: { (locations, distance, reocrd) in
            // 订阅每次跑步记录的更新（包括位置及距离，时间的更新）
            guard locations.count > 0 else{
                //如果位置数组没有任何元素，返回函数
                return
            }
            var cocoaLocations: [CLLocationCoordinate2D] = []
            
            locations.forEach({
                cocoaLocations.append(CLLocationCoordinate2DMake($0.latitude, $0.longitude))
            })
            // 将位置信息的数组转化为 Cocoa 的坐标对象
            self.polyline = MKPolyline(coordinates: cocoaLocations, count: locations.count)
            // 根据位置数组绘制一条曲线
            self.map.add(self.polyline)
            // 将绘制好的曲线添加到地图中
            self.map.setRegion(reocrd.getRegion(), animated: true)
            // 根据位置数组最新的坐标更新地图的显示范围，一般根据跑步距离不断扩大
        }).disposed(by: bag!)
    }
    @IBAction func close(_ sender: Any) {
        // 在 controller 销毁的时候取消订阅，释放内存
        dismiss(animated: true, completion: { self.bag = nil })
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // mapview 地图协议需要实现的函数，定义了绘制的曲线在地图上的样式
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(hue: 355, saturation: 67, brightness: 96, alpha: 20)
        // 填充曲线颜色为红色
        polylineRenderer.lineWidth = 5
        // 曲线宽度为 5 个点
        return polylineRenderer
    }
}
