//
//  SettingsViewController.swift
//  Runner_Plus
//
//  Created by liujx on 2018/2/25.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit

let pickerViewOffset  = 45

class SettingsViewController: UITableViewController, UIPickerViewDataSource, CustomModalDelegate, UIPickerViewDelegate {

    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    let weightPicker = UIPickerView(frame: CGRect(x: 20, y: 300, width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.5))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        weightPicker.dataSource = self
        weightPicker.delegate = self
        _ = UserDefaults.standard.rx.observe(Int.self, UserDefaultsKeys.weightSetting)
            .asObservable().filter({$0 != nil })
            .map({ String(describing: $0!) }).subscribe({ (e) in
                self.weightLabel.text = e.element! + " kg"
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if  UserDefaults.getReminderDate() != nil {
            reminderLabel.text = "已开启"
        }else {
            reminderLabel.text = "未设置"
        }
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1{
            let alert = CustomAlert(title: "选择您的体重", delegate: self, customView: weightPicker)
            alert.show(animated: true, navigationView: navigationController!.view)
            weightPicker.selectRow(
                UserDefaults.hasWeightSetBefore() ?
                    UserDefaults.weightSetting() - pickerViewOffset:
                    52 - pickerViewOffset
                , inComponent: 0, animated: false)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func touchCancel() {
        
        
    }
    
    func touchConfirm(_ data: Any) {
        let weight = data as! Int + pickerViewOffset
        UserDefaults.setWeightSetting(to: weight)
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = "\(row + pickerViewOffset) kg"
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
        label.textAlignment = .center
        return label
    }
    
}
