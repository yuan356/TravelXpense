//
//  NewBookPageViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/9.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum BookValue {
    case name
    case country
    case currency
    case startDate
    case endDate
    case imageUrl
}

protocol NewBookDelegate: AnyObject {
    func insertNewBook()
}

class NewBookContainerViewController: UIViewController, NewBookPageViewControllerDelegate {
   
    lazy var pageView = UIView()
    lazy var controlView = UIView()
    
    weak var delegate: NewBookDelegate?
    
    lazy var nextBtn = TXButton {
        $0.roundedCorners(radius: 16)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 21)
        $0.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
        $0.anchorSize(h: 45, w: 150)
        $0.backgroundColor = TXColor.orange.light
        $0.setBackgroundColor(color: TXColor.orange.dark, forState: .highlighted)
        $0.addTarget(self, action: #selector(pageBtnClicked), for: .touchUpInside)
    }
    
    lazy var doneBtn = TXButton {
        $0.roundedCorners(radius: 16)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 21)
        $0.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        $0.anchorSize(h: 45, w: 150)
        $0.isHidden = true
        $0.backgroundColor = TXColor.system.veronese
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.addTarget(self, action: #selector(doneBtnClicked), for: .touchUpInside)
    }
        
    var pageViewController = NewBookPageViewController()
    
    override func viewDidLoad() {
        self.view.backgroundColor = TXColor.background()
        self.view.addSubview(pageView)
        pageView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: UIScreen.main.bounds.height * 0.7))
        pageView.addSubview(pageViewController.view)
        self.addChild(pageViewController)
        pageViewController.view.fillSuperview()
        pageViewController.pageDelegate = self
        
        self.view.addSubview(controlView)
        controlView.anchor(top: pageView.bottomAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        controlView.addSubview(nextBtn)
        nextBtn.setAutoresizingToFalse()
        nextBtn.anchorCenterX(to: controlView)
        nextBtn.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 20).isActive = true
        
        controlView.addSubview(doneBtn)
        doneBtn.setAutoresizingToFalse()
        doneBtn.anchorCenterX(to: nextBtn)
        doneBtn.topAnchor.constraint(equalTo: nextBtn.bottomAnchor, constant: 20).isActive = true
    }
    
    @IBAction func pageBtnClicked(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            if title == NSLocalizedString("Next", comment: "Next") {
                pageViewController.forwardPage()
            } else {
                pageViewController.backwardPage()
            }
        }
        updateUI()
    }
    
    @IBAction func doneBtnClicked() {
        let errMsg = checkInput()
        if errMsg != "" {
            TXAlert.showCenterAlert(message: errMsg)
            return
        }
        
        guard let name = pageViewController.bookName ?? "",
              let startDate = pageViewController.startDate,
              let endDate = pageViewController.endDate,
              let country = pageViewController.bookCountry,
              let currency = pageViewController.bookCurrency else {
            return
        }
        
        
        var imageUrl: String? = nil
        if pageViewController.bookImage != nil {
            imageUrl = ""
        }

        BookService.shared.addNewBook(bookName: name, country: country.code, currency: currency.code, imageUrl: imageUrl, image: pageViewController.bookImage, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970) { (book) in
            self.delegate?.insertNewBook()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func checkInput() -> String {
        if let name = pageViewController.bookName, name.count > 100  {
            return NSLocalizedString("Book name should less than 100.", comment: "Book name should less than 100.")
        }
        
        guard let start = pageViewController.startDate else {
            return NSLocalizedString("You should set the start date.", comment: "You should set the start date.")
        }
        
        guard let end = pageViewController.endDate else {
            return NSLocalizedString("You should set the end date.", comment: "You should set the end date.")
        }
        
        if start > end {
            return NSLocalizedString("Start date should less than end date.", comment: "Start date should less than end date.")
        }
        
        if end < start {
            return NSLocalizedString("End date should greater than start date.", comment: "End date should greater than start date.")
        }
        
        if pageViewController.bookCountry == nil {
            return NSLocalizedString("You should set the country.", comment: "You should set the country.")
        }
        
        if pageViewController.bookCurrency == nil {
            return NSLocalizedString("You should set the currency.", comment: "You should set the currency.")
        }
        
        return ""
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    func updateUI() {
        let index = pageViewController.currentIndex
            switch index {
            case 0:
                nextBtn.setTitle(NSLocalizedString("Next", comment: "Next"), for: .normal)
                doneBtn.isHidden = true
            case 1:
                nextBtn.setTitle(NSLocalizedString("Previous", comment: "Previous"), for: .normal)
                doneBtn.isHidden = false
            default: break
        }
    }
}

protocol NewBookPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

class NewBookPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var currentIndex = 0
    
    var bookName: String?
    var bookCountry: Country?
    var bookCurrency: Currency?
    var bookImage: UIImage?
    var startDate: Date?
    var endDate: Date?
    
    weak var pageDelegate: NewBookPageViewControllerDelegate?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var cancelBtn: UIButton = {
        let btn = TXNavigationIcon.cancel.getButton()
        btn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    lazy var headerView = UIView {
        $0.addSubview(cancelBtn)
        cancelBtn.anchorButtonToHeader(position: .left)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(headerView)
        headerView.anchorViewOnTop()
        self.delegate = self
        self.dataSource = self

        if let startingVC = contentViewController(at: currentIndex) {
            self.setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! NewBookViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! NewBookViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> NewBookViewController? {
        guard index >= 0 && index < 2 else {
            return nil
        }
        
        if index == 0 {
            let newBookVC = NewBookFirstViewController()
            newBookVC.index = index
            newBookVC.bookName = bookName
            newBookVC.startDate = startDate
            newBookVC.endDate = endDate
            return newBookVC
        } else if index == 1 {
            let newBookVC = NewBookSecondViewController()
            newBookVC.index = index
            newBookVC.country = bookCountry
            newBookVC.currency = bookCurrency
            newBookVC.imageView.image = bookImage
            return newBookVC
        }
        
        return NewBookViewController()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first as? NewBookViewController {
                self.currentIndex = vc.index
                pageDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    @IBAction func cancelBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func backwardPage() {
        currentIndex -= 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .reverse, animated: true, completion: nil)
        }
    }
}

class NewBookViewController: UIViewController {
    var index = 0
}
