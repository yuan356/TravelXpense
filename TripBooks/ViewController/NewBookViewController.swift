//
//  NewBookViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let titleFont = MainFont.regular.with(fontSize: .large)
fileprivate let textFont = MainFont.regular.with(fontSize: 23)
fileprivate let titleColor: UIColor = .white
fileprivate let inputColor = TBColor.gray.light

fileprivate let titleHeight: CGFloat = 80
fileprivate let itemHeight: CGFloat = 50

class NewBookViewController: UIViewController {
    var index = 0
}

class NewBookFirstViewController: NewBookViewController {
    
    lazy var startDateBtn = UIButton {
        $0.restorationIdentifier = "start"
        $0.addTarget(self, action: #selector(selectDate(_:)), for: .touchUpInside)
    }
    
    lazy var endDateBtn = UIButton {
        $0.restorationIdentifier = "end"
        $0.addTarget(self, action: #selector(selectDate(_:)), for: .touchUpInside)
    }

    lazy var startLabel = UILabel {
        $0.textColor = inputColor
        $0.font = textFont
        $0.textAlignment = .right
    }

    lazy var endLabel = UILabel {
        $0.textColor = inputColor
        $0.font = textFont
        $0.textAlignment = .right
    }

    var startDate: Date? {
        didSet {
            if let date = startDate {
                startLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }

    var endDate: Date? {
        didSet {
            if let date = endDate {
                endLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    lazy var nameTextField = UITextField {
        $0.textColor = inputColor
        $0.font = textFont
        $0.textAlignment = .right
    }
    
    lazy var vStack = UIStackView {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.system.background.dark
        setVStack()
        
    }
    
    private func setVStack() {
        let nameDesc = UILabel {
            $0.textColor = titleColor
            $0.font = titleFont
            $0.text = "Name your travel book !"
            $0.anchorSize(h: titleHeight)
        }
        
        let dateDesc = UILabel {
            $0.textColor = titleColor
            $0.font = titleFont
            $0.text = "Set your travel date."
            $0.anchorSize(h: titleHeight)
        }
        
        vStack.addArrangedSubview(nameDesc)
        vStack.addArrangedSubview(getView(obj: nameTextField))
        vStack.addArrangedSubview(dateDesc)
        
        let startView = EditInfoView(viewheight: itemHeight-1, title: "Start date", object: startLabel, withButton: startDateBtn, anchorBottom: true)
        vStack.addArrangedSubview(getView(obj: startView, lineWithObj: startLabel))
        let endView = EditInfoView(viewheight: itemHeight-1, title: "End date", object: endLabel, withButton: endDateBtn, anchorBottom: true)
        vStack.addArrangedSubview(getView(obj: endView, lineWithObj: endLabel))
        
        
        self.view.addSubview(vStack)
        vStack.anchorSize(h: titleHeight * 2 + itemHeight * 3)
        vStack.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 35, left: 15, bottom: 0, right: 15))
    }
    
    private func getView(obj: UIView, lineWithObj: UIView? = nil) -> UIView {
        let view = UIView()
        view.anchorSize(h: itemHeight)
        let lineView = UIView {
            $0.anchorSize(h: 1)
            $0.backgroundColor = .white
        }
        view.addSubview(lineView)
        
        
        view.addSubview(obj)
        if let withObj = lineWithObj {
            lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: withObj.leadingAnchor, trailing: withObj.trailingAnchor)
        } else {
            lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        }
        obj.anchor(top: view.topAnchor, bottom: lineView.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        return view
    }
    
//    @IBAction func save() {
//
//        let bookName = "Test"
//        let location = "Taiwan"
//
//        guard let startDate = startDate, let endDate = endDate else {
//
//            return
//        }
//        BookService.shared.addNewBook(bookName: bookName, country: location, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970) { (newBook) in
//
//        }
//    }

    @IBAction func selectDate(_ sender: UIButton) {
        let datePickerVC = TBdatePickerViewController()
        if let identifier = sender.restorationIdentifier {
            datePickerVC.buttonIdentifier = identifier
            if identifier == "start", let end = endDate {
                datePickerVC.setMaximumDate(end)
            }
            if identifier == "end", let start = startDate {
                datePickerVC.setMinimumDate(start)
            }
        }
        
        datePickerVC.delegate = self
        if let vc = self.parent?.parent as? NewBookContainerViewController {
            datePickerVC.show(on: vc)
        }
    }
}

extension NewBookFirstViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        if buttonIdentifier == "start" {
            startDate = date
            if let pageVC = self.parent as? NewBookPageViewController {
                pageVC.startDate = startDate
            }
        } else {
            endDate = date
            if let pageVC = self.parent as? NewBookPageViewController {
                pageVC.endDate = endDate
            }
        }
    }
}
