//
//  Modal.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/1.
//  Copyright © 2018年 liujx. All rights reserved.
//
import UIKit

protocol CustomModalDelegate: class {
    func touchConfirm(_ data:Any)
    func touchCancel()
}

class CustomAlert: UIView, Modal {
    var backgroundView = UIView()
    var dialogView = UIView()
    weak var delegate: CustomModalDelegate?
    var customView: UIView!
    
    
    convenience init(title:String, delegate: CustomModalDelegate, customView: UIView) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title, delegate: delegate, customView: customView)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialize(title:String, delegate: CustomModalDelegate, customView: UIView){
        self.customView = customView
        self.delegate = delegate
        dialogView.clipsToBounds = true
        
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        addSubview(backgroundView)
        
        
        
        let dialogViewWidth = frame.width-64
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)
        
        customView.frame.origin = CGPoint(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8 )
        customView.frame.size = CGSize(width: 300, height: 162 )
        
        dialogView.addSubview(customView)
        
        let sureButton = UIButton()
        sureButton.frame.origin = CGPoint(x: 8 , y: customView.frame.height + customView.frame.origin.y + 8 )
        sureButton.frame.size = CGSize(width: 100, height: 30)
        sureButton.setTitle("确认", for: .normal)
        sureButton.titleLabel?.textColor = UIColor.black
        sureButton.backgroundColor = UIColor.darkGray
        
        
        sureButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmTapped)))
        
        
        sureButton.layer.cornerRadius = 6
        
        let cancelButton = UIButton()
        cancelButton.frame.origin = CGPoint(x: (frame.width - 64) - 108 , y: customView.frame.height + customView.frame.origin.y + 8 )
        cancelButton.frame.size = CGSize(width: 100, height: 30)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.textColor = UIColor.black
        cancelButton.backgroundColor = UIColor.darkGray
        cancelButton.layer.cornerRadius = 6
        
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
        
        dialogView.addSubview(cancelButton)
        
        dialogView.addSubview(sureButton)
        
        let dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + customView.frame.height + 8 + sureButton.frame.height + 8
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)
    }
    
    
    
    @objc func confirmTapped(){
        dismiss(animated: true)
        if self.customView.isKind(of: UIDatePicker.self) {
            delegate?.touchConfirm((self.customView as! UIDatePicker).date)
        }else if self.customView.isKind(of: UIPickerView.self){
            delegate?.touchConfirm((self.customView as! UIPickerView).selectedRow(inComponent: 0))
        }
    }
    
    @objc func cancelTapped(){
        dismiss(animated: true)
        delegate?.touchCancel()
    }
    
    
    
}

