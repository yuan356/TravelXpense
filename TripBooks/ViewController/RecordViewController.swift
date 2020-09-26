//
//  RecordViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/26.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let indexLabel = UILabel()
        indexLabel.text = "\(index)"
        
        self.view.addSubview(indexLabel)
        indexLabel.anchorToSuperViewCenter()
    }

}
