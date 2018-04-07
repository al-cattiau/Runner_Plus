//
//  RecordDetailViewController.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/3.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import MapKit

class RecordDetailViewController: UIViewController, MKMapViewDelegate {
    var record: Record!

    @IBOutlet weak var shareToBottom: NSLayoutConstraint!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var distanceDescription: UILabel!
    @IBOutlet weak var timeDescription: UILabel!
    @IBOutlet weak var speedDescription: UILabel!
    @IBOutlet weak var calorieDescription: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        shareToBottom.constant = -60
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        title = record.date!.convertDateToSimpleString() + " " + record.date!.mapDateToChineseString()
        renderMap()
        distanceDescription.text = record.distance.clipTopOneToString().appendDistanceDescription()
        timeDescription.text = record.time.mapSecondToDigiString().appendTimeDescription()
        calorieDescription.text = record.getCalorie().clipTopTwoToString().appendCalorieDescription()
        speedDescription.text = record.calcuSpeed().mapSecondToFormattedStirng().appendStepperDescription()
//            .clipTopOneToString().appendStepperDescription()
    }
    
    func renderMap(){
        var cocoaLocations: [CLLocationCoordinate2D] = []
        record.locations.forEach({
            cocoaLocations.append(CLLocationCoordinate2DMake($0.latitude, $0.longitude))
        })
        
        let polyline = MKPolyline(coordinates: cocoaLocations, count: record.locations.count)
        map.add(polyline)
        self.map.setRegion(record.getRegion(), animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        shareToBottom.constant = 16
        UIView.animate(withDuration: 2, delay: 0.5,
                       usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0,
                       options: .curveEaseIn,
                       animations: {
                        self.view.layoutIfNeeded()
        },completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(hue: 355, saturation: 67, brightness: 96, alpha: 20)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
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
