//
//  MainViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/4.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let headerHeight: CGFloat = 60
fileprivate let userInfoWidth: CGFloat = UIScreen.main.bounds.width * 0.5


class MainViewController: UIViewController, NewBookDelegate {
    
    var books: [Book]!
    
    var bookTableView: UITableView!
    
    var blockingViewController: BlockingViewController?
        
    lazy var headerView = UIView {
        $0.anchorSize(h: headerHeight)
        $0.addSubview(userButton)
        userButton.anchorButtonToHeader(position: .left, height: 30)
        $0.addSubview(settingButton)
        settingButton.anchorButtonToHeader(position: .right, height: 30)
    }
    
    lazy var userButton: UIButton = {
        let btn = TXNavigationIcon.user.getButton()
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(userButtonClicked), for: .touchUpInside)
        return btn
    }()

    
    lazy var settingButton: UIButton = {
        let btn = TXNavigationIcon.settings.getButton()
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(settingBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var addButton = TXButton {
        $0.setTitle(NSLocalizedString("New book", comment: "New book"), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(TXColor.gray.medium, for: .highlighted)
        $0.backgroundColor = TXColor.system.veronese
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.roundedCorners(radius: 23, shadow: true)
        $0.anchorSize(h: 45, w: 130)
    }
    
    lazy var userView = UIView {
        $0.addSubview(blockingCancelView)
        blockingCancelView.fillSuperview()
        $0.addSubview(userInfoView)
        userInfoView.anchor(top: $0.topAnchor, bottom: $0.bottomAnchor, leading: nil, trailing: nil)
    }
    
    lazy var userLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 3
        $0.font = MainFont.medium.with(fontSize: .medium)
    }
    
    lazy var noteLabel = UILabel {
        $0.textColor = TXColor.gray.medium
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "Log In then you can backup your data."
        $0.font = MainFont.medium.with(fontSize: 15)
    }
    
    lazy var infoView = UIView {
        $0.anchorSize(h: 180)
        $0.addSubview(userLabel)
        userLabel.anchorToSuperViewCenter()
        userLabel.anchorSuperViewLeading(padding: 8)
        userLabel.anchorSuperViewTrailing(padding: 8)
        $0.addSubview(noteLabel)
        noteLabel.anchorTopTo(to: userLabel, padding: 15)
        noteLabel.anchorSuperViewLeading(padding: 8)
        noteLabel.anchorSuperViewTrailing(padding: 8)
        noteLabel.anchorCenterX(to: $0)
    }

    lazy var logInBtn = TXButton {
        $0.setTitle(NSLocalizedString("Log in", comment: "Log in"), for: .normal)
        $0.addTarget(self, action: #selector(logInClicked), for: .touchUpInside)
        $0.anchorSize(h: 45, w: userInfoWidth - 20)
    }
    
    lazy var signUpBtn = TXButton {
        $0.setTitle(NSLocalizedString("Sign up", comment: "Sign up"), for: .normal)
        $0.addTarget(self, action: #selector(signUpClicked), for: .touchUpInside)
        $0.anchorSize(h: 45, w: userInfoWidth - 20)
    }
    
    lazy var logOutBtn = TXButton {
        $0.setTitle(NSLocalizedString("Log out", comment: "Log out"), for: .normal)
        $0.addTarget(self, action: #selector(logOutClicked), for: .touchUpInside)
        $0.anchorSize(h: 45, w: userInfoWidth - 20)
    }
    
    lazy var btnStackView = UIStackView {
        $0.alignment = .center
        $0.axis = .vertical
        $0.spacing = 5
        $0.distribution = .equalSpacing
    }
    
    // MARK: userInfoView
    lazy var userInfoView = UIView {
        $0.backgroundColor = TXColor.background()
        $0.anchorSize(w: userInfoWidth)
        
        print("is log in: ", AuthService.isUserLogin)
        
        $0.addSubview(infoView)
        infoView.anchor(top: $0.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: $0.leadingAnchor, trailing: $0.trailingAnchor)
        
        $0.addSubview(btnStackView)
        btnStackView.anchor(top: infoView.bottomAnchor, bottom: nil, leading: $0.leadingAnchor, trailing: $0.trailingAnchor)
    }
    
    var userInfoLeadingConstraint: NSLayoutConstraint!
    
    lazy var blockingCancelView = UIView {
        $0.backgroundColor = TXColor.blurBackground
        let btn = UIButton()
        btn.addTarget(self, action: #selector(blockingCancel), for: .touchUpInside)
        $0.addSubview(btn)
        btn.fillSuperview()
    }
    
    lazy var clearView = UIView {
        $0.backgroundColor = .clear
    }
    var observer: TXObserver!

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.system.background.dark
        
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
        
        self.books = BookService.shared.bookList
        
        bookTableViewSetting()
        
        setViews()
        
        updateUserInfoUI()
                
        toggleFloatingSideBarView(enable: false, animate: false)
        
        observer = TXObserver.init(notification: .authLog, infoKey: nil)
        observer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.books = BookService.shared.bookList
        bookTableView.reloadData()
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
        
        self.view.addSubview(userView)
        userView.fillSuperview()
        userInfoLeadingConstraint = userInfoView.leadingAnchor.constraint(equalTo: userView.leadingAnchor)
        userInfoLeadingConstraint.isActive = true
    }
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = TXColor.system.background.dark
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
    
    private func updateUserInfoUI() {
        for view in btnStackView.subviews {
            view.removeFromSuperview()
        }
        
        if let user = AuthService.currentUser {
            btnStackView.addArrangedSubview(logOutBtn)
            btnStackView.addArrangedSubview(getLineView())
            noteLabel.isHidden = true
            if let name = user.displayName  {
                userLabel.text = "Hello," + "\n\n" + name
            }
        } else {
            noteLabel.isHidden = false
            btnStackView.addArrangedSubview(logInBtn)
            btnStackView.addArrangedSubview(getLineView())
            btnStackView.addArrangedSubview(signUpBtn)
            btnStackView.addArrangedSubview(getLineView())
            userLabel.text = "You are not log in."
        }
    }
    
    private func getLineView() -> UIView {
        let lineView = UIView {
            $0.backgroundColor = TXColor.gray.medium
            $0.anchorSize(h: 1, w: 120)
        }
        return lineView
    }
 
    // MARK: Action
    @IBAction func settingBtnClicked() {
        self.navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    @IBAction func addButtonClicked() {
        let vc = NewBookContainerViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private func toggleFloatingSideBarView(enable: Bool, animate: Bool = true) {
        let alpha: CGFloat = enable ? 1 : 0
        if animate {
            if enable {
                UIView.animate(withDuration: 0.1) {
                    self.userView.alpha = alpha
                } completion: { (_) in
                    self.userInfoLeadingConstraint.constant = 0
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }

            } else {
                self.userInfoLeadingConstraint.constant = -userInfoWidth
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { (_) in
                    UIView.animate(withDuration: 0.1) {
                        self.userView.alpha = alpha
                    }
                }
            }
        } else {
            if enable {
                self.userView.alpha = alpha
                self.userInfoLeadingConstraint.constant = 0
            } else {
                self.userView.alpha = alpha
                self.userInfoLeadingConstraint.constant = -userInfoWidth
            }
        }
    }
    
    @IBAction func userButtonClicked() {
        toggleFloatingSideBarView(enable: true)
    }
    
    @IBAction func blockingCancel() {
        toggleFloatingSideBarView(enable: false)
    }
    
    @IBAction func logInClicked() {
        toggleFloatingSideBarView(enable: false)
        let logVC = LogViewController()
        logVC.isLogIn = true
        let vc = UINavigationController(rootViewController: logVC)
        self.present(vc, animated: true, completion: nil)

    }
    
    @IBAction func signUpClicked() {
        toggleFloatingSideBarView(enable: false)
        let signVC = LogViewController()
        signVC.isLogIn = false
        let vc = UINavigationController(rootViewController: signVC)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logOutClicked() {
        AuthService.logOut()
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
    
    func insertNewBook() {
        self.books = BookService.shared.bookList
        bookTableView.beginUpdates()
        bookTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
        bookTableView.endUpdates()
    }
}

extension MainViewController: ObserverProtocol {
    func handleNotification(infoValue: Any?) {
        updateUserInfoUI()
    }
}

// MARK: extension UITableViewDataSource
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if books.count == 0 {
                let msg1 = NSLocalizedString("You don't have a book right now.", comment: "bookTableViewEmpty")
                let msg2 = NSLocalizedString("Go add a new book!", comment: "bookTableViewEmpty")
                self.bookTableView.setEmptyMessage(msg1 + "\n\n" + msg2, isForBookTable: true)
            } else {
                self.bookTableView.restore()
            }
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
