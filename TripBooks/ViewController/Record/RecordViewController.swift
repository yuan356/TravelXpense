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
        indexLabel.setAutoresizingToFalse()
        let button = UIButton()
        button.setTitle("Button", for: .normal)
        button.backgroundColor = .brown
        button.addTarget(self, action: #selector(clicked), for: .touchUpInside)
        self.view.addSubview(button)
        button.setAutoresizingToFalse()
        
        let button2 = UIButton()
        button2.setTitle("Button", for: .normal)
        button2.backgroundColor = .yellow
        self.view.addSubview(button2)
        
        var constraint = [NSLayoutConstraint]()
        let views = ["indexLabel": indexLabel, "button": button, "button2": button2]
        
        constraint += NSLayoutConstraint.constraints(withVisualFormat: "V:[indexLabel]-20-[button]-20-[button2]", options:.alignAllCenterX, metrics: nil, views: views)
        
        constraint += NSLayoutConstraint.constraints(withVisualFormat: "H:[button(80)]", options: [], metrics: nil, views: views)
        
        button2.setAutoresizingToFalse()
        constraint += NSLayoutConstraint.constraints(withVisualFormat: "H:[button2(==button)]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraint)

    }
    
    @IBAction func clicked() {
        print("clicked: \(index)")
    }

}


