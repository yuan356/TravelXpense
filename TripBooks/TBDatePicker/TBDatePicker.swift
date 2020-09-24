//
//  TBDatePicker.swift
//  DatePickerDemo
//
//  Created by 阿遠 on 2020/9/24.
//

import UIKit

class TBDatePicker: TBDatePickerViewDelegate {

    private let superview: UIView
    private let datepickeView: TBDatePickerView
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        return datePicker
    }()
    
    init(superview: UIView) {
        
        self.superview = superview
        
        self.datepickeView = TBDatePickerView(self.datePicker)
        self.datepickeView.delegate = self
    }
    
    func getDate() -> Date {
        print(self.datePicker.date)
        return self.datePicker.date
    }
    
    // MARK: show & close
    func show() {
        UIView.transition(with: self.superview, duration: 0.15, options: [.transitionCrossDissolve], animations: {
            self.superview.addSubview(self.datepickeView)
        }, completion: nil)
    }
    
    func removeFromSuperView() {
        getDate()
        UIView.transition(with: self.superview, duration: 0.15, options: [.transitionCrossDissolve], animations: {
            self.datepickeView.removeFromSuperview()
        }, completion: nil)
    }
}
