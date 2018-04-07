//
//  RecordsCollectionViewController.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/23.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit
import RealmSwift

let MapRunModeSegmentToChinese = [
    "basic": "基础跑",
    "timer": "计时跑",
    "distance": "距离跑"
]


class RecordsCollectionViewController: UIViewController {
    var realm: Realm!
    var records: Results<Record>!
    @IBOutlet weak var recordsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordsTable.delegate = self
        recordsTable.dataSource = self
        recordsTable.rowHeight = 100
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        realm = try! Realm()
        records = realm.objects(Record.self)
        recordsTable.reloadData()
    }
}

extension RecordsCollectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecordCell
        let record = records.toArray()[indexPath.row]
        cell.timeDescription.text = record.date!.convertDateToString() + " " + record.date!.mapDateToChineseString()
        cell.distanceDescription.text = record.distance.clipTopTwoToString().appendDistanceDescription()
        cell.recordType.text =  "\(MapRunModeSegmentToChinese["\(RunModeSegment(rawValue: record.mode)!)"]!)"
        if record.mapSnap != nil {
            cell.imageView?.image = record.getMapSnapImage()
            cell.imageView?.layer.cornerRadius = 10
            cell.imageView?.layer.masksToBounds = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "删除") { _,_,complete  in
            let record = self.records.toArray()[indexPath.row]
            self.realm = try! Realm()
            try! self.realm.write {
                self.realm.delete(record)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recordDetail = storyboard?.instantiateViewController(withIdentifier: "recordDetail") as! RecordDetailViewController
        recordDetail.record = records.toArray()[indexPath.row]
        navigationController?.pushViewController(recordDetail, animated: true)
        
    }
}

