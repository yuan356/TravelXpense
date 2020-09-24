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
}

extension BookViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectedBook = books[indexPath.row]
        performSegue(withIdentifier: "update", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            BookService.shared.deleteBook(bookId: self.books[indexPath.row].id) {
                self.updateTable()
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as? BookTableViewCell {
            let book = books[indexPath.row]
            cell.booknameLabel.text = book.name
            cell.countryLabel.text = book.country
            cell.idLabel.text = String(book.id)
            cell.coverImageNo.text = String(book.coverImageNo ?? 0)
            cell.createTime.text = Func.convertDoubleTimeToDateStr(timeStamp: book.createTime)
            cell.startDateLabel.text = Func.convertDateToDateStr(date: book.startDate)
            cell.daysInterval.text = String(book.daysInterval)
            return cell
        }
        
        return UITableViewCell()
    }
}

