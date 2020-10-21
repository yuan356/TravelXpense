//
//  RecordTableViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/30.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let recordTableViewCellIdentifier = "RecordTableViewCell"

class RecordTableViewController: UIViewController, UIGestureRecognizerDelegate {

    var book: Book!
    
    var tableView = UITableView()
    
    var dayIndex = 0
    
    var records: [Record] = []
    
    var observer: Observer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let padding: CGFloat = 20
        self.view.backgroundColor = .clear
        self.view.addSubview(tableView)
        tableView.fillSuperview(padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: recordTableViewCellIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        
        if let bookDayRecord = RecordSevice.shared.bookDaysRecordCache[self.book.id] {
            records = bookDayRecord[dayIndex]
        }
        
        observer = Observer.init(notification: .recordTableUpdate, infoKey: .defalut)
        observer.delegate = self
        
        setupLongPressGesture()
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath.row)
                
            }
        }
    }
}

extension RecordTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: recordTableViewCellIdentifier, for: indexPath) as? RecordTableViewCell {
            cell.record = records[indexPath.row]
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == 0 {
                cell.roundedType = .top // 1. these two order can't change!
                cell.rounded = true // 2.
                
            } else if indexPath.row == self.records.count - 1 {
                cell.roundedType = .bottom // 1. these two order can't change!
                cell.rounded = true // 2.
            }
            else {
                cell.rounded = false
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = RecordDetailViewController()
        controller.book = self.book
        controller.record = self.records[indexPath.row]
        present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
}



extension RecordTableViewController: ObserverProtocol {
    func handleNotification(infoValue: Any?) {
        if let bookDayRecord = RecordSevice.shared.bookDaysRecordCache[self.book.id] {
            records = bookDayRecord[dayIndex]
            self.tableView.reloadData()
        }
    }
    
}
