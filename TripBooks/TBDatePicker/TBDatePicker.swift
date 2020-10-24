//
//  TBDatePicker.swift
//  DatePickerDemo
//
//  Created by 阿遠 on 2020/9/24.
//

import UIKit

protocol TBDatePickerDelegate: AnyObject {
    func changeDate(buttonIdentifier: String, date: Date)
}

class TBdatePickerViewController: UIViewController {
    
    weak var delegate: TBDatePickerDelegate?
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        return datePicker
    }()
    
    var buttonIdentifier: String = ""
    
    override func viewDidLoad() {
        self.setView()
    }
    
    func setView() {
        // bottom view (buttonView + datePicker + safeArea)
        let bottomView = UIView()
        bottomView.backgroundColor = .gray
        self.view.addSubview(bottomView)
        
        bottomView.addSubview(datePicker)
        datePicker.anchor(top: nil, bottom: bottomView.safeAreaLayoutGuide.bottomAnchor, leading: bottomView.leadingAnchor, trailing: bottomView.trailingAnchor)
        
        // button view
        let buttonView = UIView()
        bottomView.addSubview(buttonView)
        
        buttonView.anchor(top: nil, bottom: datePicker.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        buttonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bottomView.anchor(top: buttonView.topAnchor, bottom: self.view.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor)

        createButton(to: buttonView)
        
        // background View
        let backgroundView = UIView()
        backgroundView.backgroundColor = .gray
        backgroundView.alpha = 0.7
        self.view.addSubview(backgroundView)
        backgroundView.anchor(top: self.view.topAnchor, bottom: buttonView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        // close button
        let closeBtn = UIButton()
        backgroundView.addSubview(closeBtn)
        closeBtn.fillSuperview()
        closeBtn.addTarget(self, action: #selector(closeDatePicker), for: .touchUpInside)
    }
    
    @IBAction func closeDatePicker() {
        close()
    }
    
    @IBAction func setToday() {
        self.datePicker.setDate(Date(), animated: true)
    }
    
    @IBAction func selectedDone() {
        self.delegate?.changeDate(buttonIdentifier: self.buttonIdentifier, date: self.datePicker.date)
        close()
    }
    
    func close() {
        UIView.transition(with: self.view, duration: 0.15, options: [.transitionCrossDissolve], animations: {
                self.view.removeFromSuperview()
                self.removeFromParent()
             }, completion: nil)
    }
    
    func show(on parent: UIViewController) {
        UIView.transition(with: parent.view, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            parent.view.addSubview(self.view)
            self.view.fillSuperview()
            parent.addChild(self)
            }, completion: nil)
    }
    
    func setDate(date: Date) {
        self.datePicker.setDate(date, animated: false)
    }
    
    func getDate() -> Date {
        return self.datePicker.date
    }

    func setMinimumDate(_ date: Date) {
        self.datePicker.minimumDate = date
    }
    
    func setMaximumDate(_ date: Date) {
        self.datePicker.maximumDate = date
    }
    
    private func createButton(to view: UIView) {
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

}
