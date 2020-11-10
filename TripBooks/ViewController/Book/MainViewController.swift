//
//  MainViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/4.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let headerHeight: CGFloat = 60

class MainViewController: UIViewController {

    var books: [Book]!
    
    var bookTableView: UITableView!
    
    lazy var headerView = UIView {
        $0.anchorSize(h: headerHeight)
        $0.addSubview(settingButton)
        settingButton.anchorButtonToHeader(position: .right, height: 30)
    }
    
    lazy var settingButton: UIButton = {
        let btn = TBNavigationIcon.settings.getButton()
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
        $0.roundedCorners(radius: 23, shadow: true)
        $0.anchorSize(h: 45, w: 130)
    }
    
    lazy var clearView = UIView {
        $0.backgroundColor = .clear
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.system.background.dark
        
        let emptyImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = emptyImage
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backButtonTitle = ""
        if DisplayMode.statusBarStyle() == .lightContent {
            navigationController?.navigationBar.barStyle = .black
        } else {
            navigationController?.navigationBar.barStyle = .default
        }
        

        // initialize setting
        BookService.shared.getAllBooksToCache()
        self.books = BookService.shared.orderdBookList
        
        bookTableViewSetting()
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.books = BookService.shared.orderdBookList
        bookTableView.reloadData() // temp
    }
    
    private func bookTableViewSetting() {
        bookTableView = UITableView()
        bookTableView.backgroundColor = .clear
        bookTableView.showsVerticalScrollIndicator = false
        bookTableView.delegate = self
        bookTableView.dataSource = self
        bookTableView.separatorStyle = .none
        bookTableView.register(BookTableViewCell.self, forCellReuseIdentifier: String(describing: BookTableViewCell.self))
    }
    
    private func setViews() {
        self.view.addSubview(bookTableView)
        bookTableView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        setHeader()
        
        self.view.addSubview(addButton)
        addButton.setAutoresizingToFalse()
        addButton.anchorCenterX(to: self.view)
        addButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
    }
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = TBColor.system.background.dark
        blurEffectView.alpha = 0
        return blurEffectView
    }()
    
    private func setHeader() {
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        let topSafeAreaView = UIView()
        self.view.addSubview(topSafeAreaView)
        topSafeAreaView.anchor(top: self.view.topAnchor, bottom: headerView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(blurEffectView)
        blurEffectView.anchor(top: topSafeAreaView.topAnchor, bottom: headerView.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        self.view.bringSubviewToFront(headerView)
    }
 
    @IBAction func settingBtnClicked() {
        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    @IBAction func addButtonClicked() {
        print("addButtonClicked")
        let vc = NewBookContainerViewController()
        present(vc, animated: true, completion: nil)
    }
    
    private func addBtnIsShow(_ show: Bool) {
        let alpha: CGFloat = show ? 1 : 0
        UIView.animate(withDuration: 0.45) {
            self.addButton.alpha = alpha
        }
    }
    
    func headerBlurEffect(show: Bool, animate: Bool) {
        let alpha: CGFloat = show ? 0.75 : 0
        
        if self.blurEffectView.alpha != alpha {
            if animate {
                UIView.animate(withDuration: 0.3) {
                    self.blurEffectView.alpha = alpha
                }
            } else {
                self.blurEffectView.alpha = alpha
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.books.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = headerCell()
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: headerHeight).usingPriority(.almostRequired).isActive = true
            cell.contentView.addSubview(view)
            view.fillSuperview()
            return cell
        }
        
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
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y >= 0 {
            // up
            addBtnIsShow(true)
        } else {
            // down
            addBtnIsShow(false)
        }
        
        // tableView 滑動的位移
        if scrollView.contentOffset.y > headerHeight / 2 {
            headerBlurEffect(show: true, animate: true)
        } else {
            headerBlurEffect(show: false, animate: true)
        }
    }
}

class headerCell: UITableViewCell {
    lazy var view = UIView {
        $0.heightAnchor.constraint(equalToConstant: headerHeight).usingPriority(.almostRequired).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.addSubview(view)
        view.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
