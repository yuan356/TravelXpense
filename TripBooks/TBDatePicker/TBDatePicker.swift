//
//  TBDatePicker.swift
//  DatePickerDemo
//
//  Created by 阿遠 on 2020/9/24.
//

import UIKit

protocol TBDatePickerDelegate: AnyObject {
    func changeDate(identifier: String, date: Date)
}

class TBDatePicker {
    
    private let superview: UIView
    private let datepickeView: TBDatePickerView
    
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
    
    init(superview: UIView) {
        
        self.superview = superview
        
        self.datepickeView = TBDatePickerView(self.datePicker)
        self.datepickeView.delegate = self
    }
    
    func getDate() -> Date {
        return self.datePicker.date
    }
    
    func setMinimumDate(date: Date) {
        self.datePicker.minimumDate = date
    }
    
    // MARK: show & close
    func show() {
        UIView.transition(with: self.superview, duration: 0.15, options: [.transitionCrossDissolve], animations: {
            self.superview.addSubview(self.datepickeView)
        }, completion: nil)
    }
}

extension TBDatePicker: TBDatePickerViewDelegate {
    func removeFromSuperView() {
        UIView.transition(with: self.superview, duration: 0.15, options: [.transitionCrossDissolve], animations: {
            self.datepickeView.removeFromSuperview()
        }, completion: nil)
    }
    
    func setDateToToday() {
        self.datePicker.setDate( Date(), animated: true)
    }
    
    func selectDateDone() {
        self.delegate?.changeDate(identifier: self.buttonIdentifier, date: self.datePicker.date)
        removeFromSuperView()
    }
    
}
