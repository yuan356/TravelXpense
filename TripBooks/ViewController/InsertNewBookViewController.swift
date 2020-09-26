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
            startDateTextField.text = Func.convertDateToDateStr(date: startDate!)
        }
    }
    
    var endDate: Date? {
        didSet {
            endDateTextField.text = Func.convertDateToDateStr(date: endDate!)
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
            endDate = calendar.date(byAdding: .day, value: book.daysInterval, to: book.startDate)!
            locationTextField.text = book.country
        }
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        guard let bookName = bookNameTextField.text,
              let location = locationTextField.text,
              let startDate = startDate,
              let endDate = endDate,
              let daysInterval = Func.getDaysInterval(start: startDate, end: endDate) else {
            return
        }
        

        if isAdd {
            BookService.shared.addNewBook(bookName: bookName, country: location, startDate: startDate, daysInterval: daysInterval) { (newBook) in
                self.delegate?.updateTable()
                self.showMsg("新增成功！")
            }
            
        } else {
            if let bookId = self.book?.id {
                BookService.shared.updateBook(bookName: bookName, country: location, startDate: startDate, daysInterval: daysInterval, bookId: bookId) { (book) in
                    self.delegate?.updateTable()
                    self.showMsg("更新成功！")
                }
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
        let datepicker = TBDatePicker(superview: self.view)
        if let identifier = sender.restorationIdentifier {
            datepicker.buttonIdentifier = identifier
            if identifier == "end" {
                if let startDate = startDate {
                    datepicker.setMinimumDate(date: startDate)
                }
            }
        }
        datepicker.delegate = self
        datepicker.show()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension InsertNewBookViewController: TBDatePickerDelegate {
    func changeDate(identifier: String, date: Date) {
        if identifier == "start" {
            startDate = date
        } else {
            endDate = date
        }
    }
}
