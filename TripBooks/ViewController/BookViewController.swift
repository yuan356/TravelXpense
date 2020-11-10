//
//  ViewController.swift
//  TripBooks
//
//  Created by yuan on 2020/9/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, EditNewBookDelegate {
            
    var books: [Book] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var didSelectedBook: Book?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeImage: UIImageView! {
        didSet {
            homeImage.tintColor = .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "BookTableViewCell")
        
        // initialize setting
        BookService.shared.getAllBooksToCache()
        
        self.books = BookService.shared.orderdBookList
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? InsertNewBookViewController {
            vc.delegate = self
            if segue.identifier == "update" {
                vc.isAdd = false
                vc.book = didSelectedBook
            }
        }
    }

    func updateTable() {
        self.books = BookService.shared.orderdBookList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.books = BookService.shared.orderdBookList
        tableView.reloadData()
        
    }
}

extension BookViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = AccountingViewController()
        let vc = BookContainerViewController()
        BookService.shared.currentOpenBook = self.books[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            BookService.shared.deleteBook(bookId: self.books[indexPath.row].id) {
                self.updateTable()
            }
            completionHandler(true)
        }
        
        let updateAction = UIContextualAction(style: .normal, title: "Update") { (action, sourceView, completionHandler) in
            self.didSelectedBook = self.books[indexPath.row]
            self.performSegue(withIdentifier: "update", sender: nil)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as? BookTableViewCellold {
            let book = books[indexPath.row]
            cell.booknameLabel.text = book.name
            cell.countryLabel.text = book.country.code
            cell.idLabel.text = String(book.id)
            cell.coverImageNo.text = book.imageUrl
            cell.createTime.text = TBFunc.convertDoubleTimeToDateStr(timeStamp: book.createDate)
            cell.startDateLabel.text = TBFunc.convertDateToDateStr(date: book.startDate)
            cell.endDateLabel.text = TBFunc.convertDateToDateStr(date: book.endDate)
            cell.totalAmountLabel.text = String(book.totalAmount)
            cell.daysInterval.text = String(book.days)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

