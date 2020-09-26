//
//  TBDatePickerView.swift
//  DatePickerDemo
//
//  Created by 阿遠 on 2020/9/24.
//

import UIKit

protocol TBDatePickerViewDelegate {
    func removeFromSuperView()
    func setDateToToday()
    func selectDateDone()
}

class TBDatePickerView: UIView {
    
    var delegate: TBDatePickerViewDelegate?
    
    init(_ datePicker: UIDatePicker) {
        super.init(frame: UIScreen.main.bounds)
        
        // bottom view (buttonView + datePicker + safeArea)
        let bottomView = UIView()
        bottomView.backgroundColor = .gray
        self.addSubview(bottomView)
        
        bottomView.addSubview(datePicker)
        datePicker.anchor(top: nil, bottom: bottomView.safeAreaLayoutGuide.bottomAnchor, leading: bottomView.leadingAnchor, trailing: bottomView.trailingAnchor)
        
        // button view
        let buttonView = UIView()
        bottomView.addSubview(buttonView)
        
        buttonView.anchor(top: nil, bottom: datePicker.topAnchor, leading: self.leadingAnchor, trailing: self.trailingAnchor)
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomView.anchor(top: buttonView.topAnchor, bottom: self.bottomAnchor, leading: self.safeAreaLayoutGuide.leadingAnchor, trailing: self.safeAreaLayoutGuide.trailingAnchor)

        createButton(to: buttonView)
        
        // background View
        let backgroundView = UIView()
        backgroundView.backgroundColor = .gray
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
    
    func createButton(to view: UIView) {
        let todayBtn = UIButton()
        todayBtn.setTitle("Today", for: .normal)
        todayBtn.addTarget(self, action: #selector(setToday), for: .touchUpInside)

        let doneBtn = UIButton()
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.addTarget(self, action: #selector(selectedDone), for: .touchUpInside)
        
        view.addSubview(todayBtn)
        view.addSubview(doneBtn)
        
        todayBtn.setAutoresizingToFalse()
        todayBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        todayBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        doneBtn.setAutoresizingToFalse()
        doneBtn.centerYAnchor.constraint(equalTo: todayBtn.centerYAnchor).isActive = true
        doneBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }
    
    @IBAction func closeDatePicker() {
        self.delegate?.removeFromSuperView()
    }
    
    @IBAction func setToday() {
        self.delegate?.setDateToToday()
    }
    
    @IBAction func selectedDone() {
        self.delegate?.selectDateDone()
    }
    
}
