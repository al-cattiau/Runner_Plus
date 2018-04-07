//
//  Record.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/14.
//  Copyright © 2018年 liujx. All rights reserved.
//

import Foundation
import RealmSwift
//import CoreLocation
import CoreImage
import MapKit


class Location: Object {
    @objc dynamic var latitude : Double = 0 //经度值，使用双精度浮点数存储
    @objc dynamic var longitude : Double = 0 // 纬度值，数据结构同上
}

class Record: Object {
    @objc dynamic var date: Date? // 日期
    @objc dynamic var time: Int = 0 //用时，即整个过程消耗的秒数
    @objc dynamic var mapSnap: Data? // 跑步截图
    @objc dynamic var distance: Float = 0 // 距离，单精度浮点数
    @objc dynamic var mode: Int = 0 // 模式，0 代表基本类型，1 代表计时跑，2 代表距离跑
    
    let locations = List<Location>() // 位置数组，数组里的每个元素是上面的 Location 结构体
    
    //  下面是一些辅助计算的方法，如根据时间与距离计算速度等
    static  func calcuSpeedFrom(time: Int, to distance: Float) -> Int {
        let speed =  Int(Float(time) / distance)
        return speed
    }
    
    func calcuSpeed() -> Int {
        return Record.calcuSpeedFrom(time: time, to: distance)
    }
    
    func getCalorie() -> Float {
        return Float(UserDefaults.weightSetting()) *  self.distance * 1.036
    }
    
    static func getCalorieBy(distance: Float) -> Float {
        return Float(UserDefaults.weightSetting()) *  distance * 1.036
    }
    
    func getMapSnapImage() -> UIImage{
        let deviceScale = UIScreen.main.scale
    
        let image = UIImage(cgImage: UIImage(data: self.mapSnap!)!.cgImage!, scale: deviceScale, orientation: UIImage(data: self.mapSnap!)!.imageOrientation)
        
        return image
    
    }
    
    func getRegion() -> MKCoordinateRegion{
        let latitudeDelta = locations.map({ $0.latitude }).max()! - locations.map({ $0.latitude }).min()!
        // 地图显示的纬度范围应该是用户跑步的最大维度差的两倍
        let longitudeDelta = locations.map({ $0.longitude }).max()! - locations.map({ $0.longitude }).min()!
        // 地图显示的经度范围应该是用户跑步的最大维度差的两倍
        let center = locations[locations.count / 2]
        // 地图页的正中间是用户位置信息数组的中位数
        return MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(center.latitude, center.longitude),
            MKCoordinateSpanMake(latitudeDelta * 2, longitudeDelta * 2))
    }
    
    func getMapSnap( completionHandler: @escaping (_ data: Data) -> Void ){
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: 80, height: 80)
        options.region = getRegion()
        let snapShotter =  MKMapSnapshotter.init(options: options)
        snapShotter.start(completionHandler: { (snapShot, error) in
            if let snapShot = snapShot {
                let imageToRender = snapShot.image
                let snapView = UIImageView(image: imageToRender)
                
                UIGraphicsBeginImageContextWithOptions(imageToRender.size, false, imageToRender.scale)
                imageToRender.draw(at: CGPoint.zero)
                var points: [CGPoint] = []
                for location in self.locations{
                    let coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    points.append(snapShot.point(for: coordinate))
                }
                let context = UIGraphicsGetCurrentContext()
                
                context!.setLineWidth(2.0)
                context!.setStrokeColor(UIColor.orange.cgColor)
                context?.move(to: points.first!)
                for i in 0...points.count - 1{
                    context?.addLine(to: points[i])
                    context?.move(to: points[i])
                }
                context!.strokePath()
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                snapView.addSubview(UIImageView(image: resultImage!))
                let renderer = UIGraphicsImageRenderer(size: snapView.bounds.size)
                let image = renderer.image(actions: { (ctx) in
                    snapView.drawHierarchy(in: snapView.bounds, afterScreenUpdates: true)
                })
                completionHandler(UIImagePNGRepresentation(image)!)
            }
        })
    }
}
