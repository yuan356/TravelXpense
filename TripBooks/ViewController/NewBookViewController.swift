//
//  NewBookViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class NewBookViewController: UIViewController {

    lazy var startDateBtn = UIButton {
        $0.setTitle("start", for: .normal)
        $0.restorationIdentifier = "start"
        $0.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
    }
    
    lazy var endDateBtn = UIButton {
        $0.setTitle("end", for: .normal)
        $0.restorationIdentifier = "end"
        $0.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
    }
    
    lazy var saveDateBtn = UIButton {
        $0.setTitle("save", for: .normal)
        $0.addTarget(self, action: #selector(save), for: .touchUpInside)
    }
    
    var startDate: Date? {
        didSet {
            print(startDate)
//            startDateTextField.text = TBFunc.convertDateToDateStr(date: startDate!)
        }
    }
    
    var endDate: Date? {
        didSet {
            print(endDate)
//            endDateTextField.text = TBFunc.convertDateToDateStr(date: endDate!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.system.background.dark
        self.view.addSubview(startDateBtn)
        self.view.addSubview(endDateBtn)
        self.view.addSubview(saveDateBtn)
        startDateBtn.anchorToSuperViewCenter()
        
        endDateBtn.setAutoresizingToFalse()
        endDateBtn.anchorCenterX(to: view)
        endDateBtn.centerYAnchor.constraint(equalTo: startDateBtn.centerYAnchor, constant: 100).isActive = true
        
        saveDateBtn.setAutoresizingToFalse()
        saveDateBtn.anchorCenterX(to: view)
        
        saveDateBtn.centerYAnchor.constraint(equalTo: endDateBtn.centerYAnchor, constant: 100).isActive = true
        
    }
    
    @IBAction func save() {
        
        let bookName = "Test"
        let location = "Taiwan"
        
        guard let startDate = startDate, let endDate = endDate else {
            
            return
        }
        BookService.shared.addNewBook(bookName: bookName, country: location, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970) { (newBook) in
            print("success")
//            print("startDate: ", startDate.timeIntervalSince1970, "endDate: ", endDate.timeIntervalSince1970)
//            print(newBook.startDate)
//            print(newBook.endDate)
        }
    }

    @IBAction func selectDate(_ sender: UIButton) {
        let datePickerVC = TBdatePickerViewController()
        if let identifier = sender.restorationIdentifier {
            datePickerVC.buttonIdentifier = identifier
        }
        
        datePickerVC.delegate = self
        datePickerVC.show(on: self)
    }
}

extension NewBookViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        if buttonIdentifier == "start" {
            startDate = date
        } else {
            endDate = date
        }
    }
}
