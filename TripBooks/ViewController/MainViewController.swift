//
//  MainViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/4.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var books = [Book]()
    
    var bookTableView: UITableView!
    
    lazy var headerView = UIView {
        $0.anchorSize(h: 60)
        $0.addSubview(settingButton)
        $0.roundedCorners(radius: 20, roundedType: .bottom)
        settingButton.anchor(top: $0.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: $0.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 20))
    }
    
    lazy var settingButton: UIButton = {
        let btn = TBNavigationIcon.settings.getButton()
        btn.anchorSize(h: 30, w: 30)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(settingBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var addButton = UIButton {
        $0.setTitle("New book", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(TBColor.gray.medium, for: .highlighted)
        $0.backgroundColor = TBColor.system.veronese
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        $0.roundedCorners(radius: 22, shadow: true)
        $0.anchorSize(h: 45, w: 130)
    }
    
    lazy var clearView = UIView {
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.system.background.dark
        
//        // initialize setting
        BookService.shared.getAllBooksToCache()
        self.books = BookService.shared.orderdBookList
        
        bookTableViewSetting()
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.books = BookService.shared.orderdBookList
        bookTableView.reloadData() // temp
    }
    
    private func bookTableViewSetting() {
        bookTableView = UITableView()
        bookTableView.backgroundColor = .clear
        bookTableView.showsVerticalScrollIndicator = false
        bookTableView.delegate = self
        bookTableView.dataSource = self
        bookTableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
    }

    private func setViews() {
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        let topSafeAreaView = UIView()
        self.view.addSubview(topSafeAreaView)
        topSafeAreaView.anchor(top: self.view.topAnchor, bottom: headerView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(bookTableView)
        bookTableView.anchor(top: headerView.bottomAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        self.view.addSubview(addButton)
        addButton.setAutoresizingToFalse()
        addButton.anchorCenterX(to: self.view)
        addButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
    }
 
    @IBAction func settingBtnClicked() {
        print("settingBtnClicked")
    }
    
    @IBAction func addButtonClicked() {
        print("addButtonClicked")
        let vc = NewBookViewController()
        present(vc, animated: true, completion: nil)
    }
    
    private func addBtnIsShow(_ show: Bool) {
        let alpha: CGFloat = show ? 1 : 0
        UIView.animate(withDuration: 0.45) {
            self.addButton.alpha = alpha
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = bookTableView.dequeueReusableCell(withIdentifier: String(describing: BookTableViewCell.self), for: indexPath) as? BookTableViewCell {
            cell.selectedBackgroundView = clearView
            cell.item = self.books[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = BookContainerViewController()
        BookService.shared.currentOpenBook = self.books[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        if contentOffset == 0 { // on top
            addButton.isHidden = false
            return
        }
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y > 0 {
            // up
            addBtnIsShow(false)
        } else {
            // down
            addBtnIsShow(true)
        }
    }

}
