//
//  RecordCell.swift
//  Runner_Plus
//
//  Created by liujx on 2018/3/2.
//  Copyright © 2018年 liujx. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet weak var mapSnap: UIImageView!
    @IBOutlet weak var timeDescription: UILabel!
    @IBOutlet weak var distanceDescription: UILabel!
    @IBOutlet weak var completeMark: UIImageView!
    @IBOutlet weak var recordType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
