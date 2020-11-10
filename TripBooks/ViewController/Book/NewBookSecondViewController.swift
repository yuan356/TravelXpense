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

class NewBookSecondViewController: NewBookViewController {
    
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
    
    var bookName: String? {
        didSet {
            nameTextField.text = bookName
        }
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
            $0.text = "Which country do you go?"
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
        

//        vStack.addArrangedSubview(getView(obj: endView, lineWithObj: endLabel))
        
        
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
}

fileprivate let nameMaxLength = 100

extension NewBookSecondViewController: UITextFieldDelegate {
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= nameMaxLength
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // store name text
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let pageVC = self.parent as? NewBookPageViewController {
            pageVC.bookName = textField.text
        }
    }
}
