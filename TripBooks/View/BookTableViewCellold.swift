//
//  BookTableViewCell.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/22.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class BookTableViewCellold: UITableViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var booknameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var daysInterval: UILabel!
    @IBOutlet weak var coverImageNo: UILabel!
    @IBOutlet weak var createTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
