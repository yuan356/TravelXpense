//
//  BookSettingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate enum SettingCellRow {
    case name
    case country
    case currency
    case startDate
    case endDate
    case budget
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let paddingInVStack: CGFloat = 8
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let heightForStackItem: CGFloat = 50
fileprivate let widthForInputObject: CGFloat = 200

// Font
fileprivate let titleTextFont: UIFont = MainFont.regular.with(fontSize: 18)
fileprivate let inputTextFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let inputTextNumberFont = MainFontNumeral.regular.with(fontSize: .medium)

// Color
fileprivate let backgroundColor = TBColor.darkGary
fileprivate let inputTextColor: UIColor = TBColor.lightGary

fileprivate enum buttonType: String {
    case country
    case currency
    case startDate
    case endDate
    case budget
}

fileprivate let nameMaxLength = 100

class BookSettingViewController: UIViewController {

    // MARK: Book Parameters
    var book: Book! {
        didSet {
            if let book = book {
                bookStartDate = book.startDate
                bookEndDate = book.endDate
                bookBudget = book.budget
            }
        }
    }
    
    var bookStartDate: Date? {
        didSet {
            if let date = bookStartDate {
                saveData(field: .startDate, value: date)
                startDateLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    var bookEndDate: Date? {
        didSet {
            if let date = bookEndDate {
                saveData(field: .endDate, value: date)
                endDateLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    var bookBudget: Double = 0 {
        didSet {
            self.budgetLabel.text = TBFunc.convertDoubleToStr(bookBudget, moneyFormat: true)            
        }
    }
    
    var keyboardShown = false {
        didSet {
            countryBtn.isEnabled = !keyboardShown
            currencyBtn.isEnabled = !keyboardShown
            startDateBtn.isEnabled = !keyboardShown
            endDateBtn.isEnabled = !keyboardShown
            budgetBtn.isEnabled = !keyboardShown
        }
    }
            
    
    // MARK: Views
    lazy var imageView = UIView {
        $0.backgroundColor = .yellow
        $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 0.45).isActive = true
    }
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = spacingInVStack
        $0.axis = .vertical
    }

    // MARK: Objects
    lazy var nameTextField = UITextField {
        $0.tintColor = .systemBlue
        $0.textAlignment = .right
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var countryLabel = UILabel {
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var currencyLabel = UILabel {
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var startDateLabel = UILabel {
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var endDateLabel = UILabel {
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var budgetLabel = UILabel {
        $0.textAlignment = .right
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.anchorSize(width: widthForInputObject)
    }
    
    lazy var countryBtn = UIButton()
    lazy var currencyBtn = UIButton()
    lazy var startDateBtn = UIButton()
    lazy var endDateBtn = UIButton()
    lazy var budgetBtn = UIButton()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        setConstraints()
    }
    
    
    private func setConstraints() {
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor)

        setVStackView()
    }
    
    // MARK: vStackView
    /// add vStackView to contentView & setting
    private func setVStackView() {
        var views = [UIView]()
        views.append(getInputView(viewTitle: "Book name", rowType: .name))
        views.append(getInputView(viewTitle: "Country", rowType: .country))
        views.append(getInputView(viewTitle: "Currency", rowType: .currency))
        views.append(getInputView(viewTitle: "Start Date", rowType: .startDate))
        views.append(getInputView(viewTitle: "End Date", rowType: .endDate))
        views.append(getInputView(viewTitle: "Budget", rowType: .budget))
        
        for view in views {
            vStackView.addArrangedSubview(view)
        }
        
        view.addSubview(vStackView)
        let viewCount = CGFloat(views.count)
        let vStackHeight = (heightForStackItem * viewCount)
                            + (paddingInVStack * (viewCount - 1))
        
        vStackView.anchor(top: imageView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView), size: CGSize(width: 0, height: vStackHeight))
    }
    
    // MARK: set detail
    private func setDetailView(title: String, to view: UIView, type: SettingCellRow) {
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = titleTextFont
        titleLabel.textColor = .white
        view.addSubview(titleLabel)
        titleLabel.anchorSuperViewLeading(padding: paddingInVStack)
        titleLabel.anchorCenterY(to: view)
        
        switch type {
        case .name:
            addInputObjects(to: view, object: nameTextField)
            nameTextField.text = "Japan Travel - 京都大阪八日遊"
            nameTextField.delegate = self
        case .country:
            addInputObjects(to: view, object: countryLabel)
            countryLabel.text = "Taiwan"
            addToolsButton(btnType: .country, to: view, on: countryLabel)
        case .currency:
            addInputObjects(to: view, object: currencyLabel)
            currencyLabel.text = "TWD"
            addToolsButton(btnType: .currency, to: view, on: currencyLabel)
        case .startDate:
            addInputObjects(to: view, object: startDateLabel)
            addToolsButton(btnType: .startDate, to: view, on: startDateLabel)
        case .endDate:
            addInputObjects(to: view, object: endDateLabel)
            addToolsButton(btnType: .endDate, to: view, on: endDateLabel)
        case .budget:
            addInputObjects(to: view, object: budgetLabel)
            addToolsButton(btnType: .budget, to: view, on: budgetLabel)
        }
    }
    
    private func getInputView(viewTitle: String, rowType: SettingCellRow) -> UIView {
        let view = UIView()
        view.anchorSize(height: heightForStackItem)
        setDetailView(title: viewTitle, to: view, type: rowType)
        return view
    }
    
    private func addInputObjects(to view: UIView, object: UIView) {
        view.addSubview(object)
        object.anchorSuperViewTrailing(padding: paddingInVStack)
        object.anchorCenterY(to: view)
    }
    
    private func addToolsButton(btnType: buttonType, to container: UIView, on target: UIView) {
        var button: UIButton
        switch btnType {
        case .country:
            button = countryBtn
        case .currency:
            button = currencyBtn
        case .startDate:
            button = startDateBtn
        case .endDate:
            button = endDateBtn
        case .budget:
            button = budgetBtn
        }
        
        container.addSubview(button)
        button.anchorSize(to: target)
        button.anchorCenterX(to: target)
        button.anchorCenterY(to: target)
        button.restorationIdentifier = btnType.rawValue
        button.addTarget(self, action: #selector(openTools(_:)), for: .touchUpInside)
    }
    
    // MARK: open Tools
    @IBAction func openTools(_ sender: UIButton) {
        if let id = sender.restorationIdentifier,
           let type = buttonType.init(rawValue: id) {
            switch type {
            case .country:
                TBNotify.showPicker(type: .country, currentObject: nil) { (result, country) in
                    if result == .success, let country = country {
                        print(country)
                    }
                }
            case .currency:
                break
            case .startDate:
                let datePickerVC = TBdatePickerViewController()
                if let date = bookStartDate {
                    datePickerVC.setDate(date: date)
                }
                datePickerVC.buttonIdentifier = type.rawValue
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .endDate:
                let datePickerVC = TBdatePickerViewController()
                if let date = bookEndDate {
                    datePickerVC.setDate(date: date)
                }
                if let startDate = bookStartDate {
                    datePickerVC.setMinimumDate(startDate)
                }
                datePickerVC.buttonIdentifier = type.rawValue
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .budget:
                TBNotify.showCalculator(on: self, originalAmount: bookBudget, currencyCode: book.currency, isForBudget: true)
            }
        }
    }

    
    // MARK: Save
    private func saveData(field: BookFieldForUpdate, value: Any) {
        var errorMsg = ""
        // check input
        switch field {
        case .name: // limited <= 100
            if let value = value as? String {
                if value.count > nameMaxLength {
                    errorMsg = "Book name should less than \(nameMaxLength)."
                }
            }
        case .country:
            break
        case .currency:
            break
        case .coverImageNo:
            break
        case .budget:
            break
        case .startDate:
            break
        case .endDate:
            break
        }
        
        if errorMsg == "",
           let value = value as? NSObject {
                book.updateData(field: field, value: value)
        } else {
            TBNotify.showCenterAlert(message: errorMsg)
        }
    }
}

// MARK: - extension
extension BookSettingViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        if let type = buttonType.init(rawValue: buttonIdentifier) {
            if type == .startDate {
                bookStartDate = date
            } else if type == .endDate {
                bookEndDate = date
            }
        }
    }
}

extension BookSettingViewController: CalculatorDelegate {
    func finishCalculate() { // update book budget
        saveData(field: .budget, value: self.bookBudget)
    }
    
    func changeTransactionType(type: TransactionType) {}
    
    func changeAmountValue(amountStr: String) {
        var amount = Double(amountStr) ?? 0
        amount.turnToPositive()
        self.bookBudget = amount
    }
}

extension BookSettingViewController: UITextFieldDelegate {
    // update name text
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            saveData(field: .name, value: text)
        }
        keyboardShown = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardShown = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= nameMaxLength
    }
}
