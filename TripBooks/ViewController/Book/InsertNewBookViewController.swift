//
//  InsertNewBookViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/22.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

protocol EditNewBookDelegate: AnyObject {
    func updateTable()
}

class InsertNewBookViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var bookNameTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    var startDate: Date? {
        didSet {
            startDateTextField.text = TBFunc.convertDateToDateStr(date: startDate!)
        }
    }
    
    var endDate: Date? {
        didSet {
            endDateTextField.text = TBFunc.convertDateToDateStr(date: endDate!)
        }
    }
    
    weak var delegate: EditNewBookDelegate?
    
    var isAdd: Bool = true
    
    var book: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookNameTextField.delegate = self
        
        if let book = book {
            bookNameTextField.text = book.name
            startDate = book.startDate
            let calendar = Calendar.current
            endDate = calendar.date(byAdding: .day, value: book.days, to: book.startDate)!
            locationTextField.text = book.country
        }
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        guard let bookName = bookNameTextField.text,
              let location = locationTextField.text,
              let startDate = startDate,
              let endDate = endDate else {
            return
        }
        
        if isAdd {
            BookService.shared.addNewBook(bookName: bookName, country: location, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970) { (newBook) in
                self.delegate?.updateTable()
                self.showMsg("新增成功！")
            }
            
        } else {
            if let bookId = self.book?.id {
//                BookService.shared.updateBook(bookName: bookName, country: location, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970, bookId: bookId) { (book) in
//                    self.delegate?.updateTable()
//                    self.showMsg("更新成功！")
//                }
            }
        }
        
    }
    
    private func showMsg(_ msg: String) {
        let alertController = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        
        let oKayAction = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(oKayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        let datePickerVC = TBdatePickerViewController()
        if let identifier = sender.restorationIdentifier {
            datePickerVC.buttonIdentifier = identifier
            if identifier == "end" {
                if let startDate = startDate {
                    datePickerVC.setMinimumDate(startDate)
                }
            }
        }

        datePickerVC.delegate = self
        UIView.transition(with: self.view, duration: 0.15, options: [.transitionCrossDissolve], animations: {
                self.view.addSubview(datePickerVC.view)
                datePickerVC.view.fillSuperview()
                self.addChild(datePickerVC)
            }, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension InsertNewBookViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        if buttonIdentifier == "start" {
            startDate = date
        } else {
            endDate = date
        }
    }
}
