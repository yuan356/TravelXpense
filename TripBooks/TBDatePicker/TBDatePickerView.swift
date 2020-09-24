//
//  TBDatePickerView.swift
//  DatePickerDemo
//
//  Created by 阿遠 on 2020/9/24.
//

import UIKit

protocol TBDatePickerViewDelegate {
    func removeFromSuperView()
}

class TBDatePickerView: UIView {

   var delegate: TBDatePickerViewDelegate?
    
    init(_ datePicker: UIDatePicker) {
        super.init(frame: UIScreen.main.bounds)
        
        let bottomView = UIView()
        bottomView.backgroundColor = .gray
        self.addSubview(bottomView)
        
        bottomView.addSubview(datePicker)
        datePicker.anchor(top: nil, bottom: bottomView.safeAreaLayoutGuide.bottomAnchor, leading: bottomView.leadingAnchor, trailing: bottomView.trailingAnchor)
        
        let buttonView = UIView()
        bottomView.addSubview(buttonView)
        
        buttonView.anchor(top: nil, bottom: datePicker.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor)
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomView.anchor(top: buttonView.topAnchor, bottom: self.bottomAnchor, leading: self.safeAreaLayoutGuide.leadingAnchor, trailing: self.safeAreaLayoutGuide.trailingAnchor)

        // background View
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.7
        self.addSubview(backgroundView)
        backgroundView.anchor(top: self.topAnchor, bottom: buttonView.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor)
        
        // close button
        let closeBtn = UIButton()
        backgroundView.addSubview(closeBtn)
        closeBtn.fillSuperview()
        closeBtn.addTarget(self, action: #selector(closeDatePicker), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func closeDatePicker() {
        self.delegate?.removeFromSuperView()
    }
    
}
