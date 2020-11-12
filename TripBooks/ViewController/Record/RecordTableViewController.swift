//
//  RecordTableViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/9/30.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let tableViewPadding: CGFloat = 15


class RecordTableViewController: UIViewController {

    var book: Book!
    
    var tableView = UITableView()
    
    var dayIndex = 0
    
    var records: [Record] = []
    
    var currentCell: RecordTableViewCell? {
        didSet {
            if currentCell != nil {
                currentCell?.updateDeleteWidthContraint()
            }
        }
        willSet {
            if currentCell != nil {
                currentCell?.updateDeleteWidthContraint(reset: true)
            }
        }
    }
    
    var onLongPress = false
    
    var observer: TBObserver!
    
    lazy var clearView = UIView {
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        tableView.fillSuperview(padding: UIEdgeInsets(top: tableViewPadding, left: tableViewPadding, bottom: 8, right: tableViewPadding))
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: String(describing: RecordTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        if let bookDayRecord = RecordSevice.shared.bookDaysRecordCache[self.book.id] {
            records = bookDayRecord[dayIndex]
        }
        
        observer = TBObserver.init(notification: .recordTableUpdate, infoKey: .defalut)
        observer.delegate = self
        
        setupLongPressGesture()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
    }

    func setupLongPressGesture() {
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.6
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @IBAction func tap(_ gesture: UITapGestureRecognizer) {
        currentCell = nil
        onLongPress = false
    }

    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint),
               let cell = tableView.cellForRow(at: indexPath) as? RecordTableViewCell {
                currentCell = cell
                onLongPress = true
            }
        }
    }
}


extension RecordTableViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer is UITapGestureRecognizer {
            if onLongPress {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}

extension RecordTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.records.count == 0 {
            let msg1 = NSLocalizedString("There is no records here.", comment: "There is no records here.")
            let msg2 = NSLocalizedString("Add a new record!", comment: "Add a new record!")
            self.tableView.setEmptyMessage(msg1 + "\n\n" + msg2)
        } else {
            self.tableView.restore()
        }
        return self.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecordTableViewCell.self), for: indexPath) as? RecordTableViewCell {
            cell.record = records[indexPath.row]
            // because if set selectionStyle to .none, controller display would have bug, so set selectedBackgroundView to clear view.
            cell.selectedBackgroundView = clearView
            cell.rounded = false
            cell.lineView.isHidden = false
            if indexPath.row == 0 {
                if indexPath.row == self.records.count - 1 { // only one cell
                    cell.lineView.isHidden = true
                    cell.roundedType = .all
                } else {
                    cell.roundedType = .top // 1. these two order can't change!
                }
                cell.rounded = true // 2.
            } else if indexPath.row == self.records.count - 1 {
                cell.roundedType = .bottom // 1. these two order can't change!
                cell.rounded = true // 2.
                cell.lineView.isHidden = true
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
}

extension RecordTableViewController: ObserverProtocol {
    func handleNotification(infoValue: Any?) {
        if let bookDayRecord = RecordSevice.shared.bookDaysRecordCache[self.book.id] {
            records = bookDayRecord[dayIndex]
            self.tableView.reloadData()
            if onLongPress {
                currentCell = nil
                onLongPress = false
            }
        }
    }
}
