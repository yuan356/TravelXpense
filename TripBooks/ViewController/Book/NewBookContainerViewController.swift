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

class NewBookContainerViewController: UIViewController, NewBookPageViewControllerDelegate {
   
    lazy var pageView = UIView()
    lazy var controlView = UIView()
    
    lazy var nextBtn = UIButton {
        $0.roundedCorners(radius: 16)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 21)
        $0.setTitle("Next", for: .normal)
        $0.anchorSize(h: 45, w: 150)
        $0.backgroundColor = TBColor.orange.light
        $0.addTarget(self, action: #selector(pageBtnClicked), for: .touchUpInside)
    }
    
    lazy var doneBtn = UIButton {
        $0.roundedCorners(radius: 16)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 21)
        $0.setTitle("Done", for: .normal)
        $0.anchorSize(h: 45, w: 150)
        $0.isHidden = true
        $0.backgroundColor = TBColor.system.veronese
        $0.addTarget(self, action: #selector(doneBtnClicked), for: .touchUpInside)
    }
        
    var pageViewController = NewBookPageViewController()
    
    override func viewDidLoad() {
        self.view.backgroundColor = TBColor.background()
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
            if title == "Next" {
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
            TBNotify.showCenterAlert(message: errMsg)
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
            print("success")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func checkInput() -> String {
        if let name = pageViewController.bookName, name.count > 100  {
            return "Book name should less than 100."
        }
        
        if pageViewController.startDate == nil {
             return "You should set the start date."
        }
        
        if pageViewController.endDate == nil {
            return "You should set the end date."
        }
        
        if pageViewController.bookCountry == nil {
            return "You should set the country."
        }
        
        if pageViewController.bookCurrency == nil {
            return "You should set the currency."
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
                nextBtn.setTitle("Next", for: .normal)
                doneBtn.isHidden = true
            case 1:
                nextBtn.setTitle("Previous", for: .normal)
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
        let btn = TBNavigationIcon.cancel.getButton()
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
                print(currentIndex)
                pageDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
                print("currentIdex", currentIndex)
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
