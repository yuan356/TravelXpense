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
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    
    weak var delegate: EditNewBookDelegate?
    
    var isAdd: Bool = true
    
    var book: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookNameTextField.delegate = self
        
        if let book = book {
            bookNameTextField.text = book.name
            startDate.date = book.startDate
            let calendar = Calendar.current
            endDate.date = calendar.date(byAdding: .day, value: book.daysInterval, to: book.startDate)!
            locationTextField.text = book.country
        }
    }

    @IBAction func startDateChanged(_ sender: Any) {
        endDate.minimumDate = startDate.date
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        guard let bookName = bookNameTextField.text,
              let location = locationTextField.text,
              let daysInterval = Func.getDaysInterval(start: startDate.date, end: endDate.date) else {
            return
        }
        

        if isAdd {
            BookService.shared.addNewBook(bookName: bookName, country: location, startDate: startDate.date, daysInterval: daysInterval) { (newBook) in
                self.delegate?.updateTable()
                self.showMsg("新增成功！")
            }
            
        } else {
            if let bookId = self.book?.id {
                BookService.shared.updateBook(bookName: bookName, country: location, startDate: startDate.date, daysInterval: daysInterval, bookId: bookId) { (book) in
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
    
    @IBAction func selectDate(_ sender: Any) {
        let datepicker = TBDatePicker(superview: self.view)
        datepicker.show()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
