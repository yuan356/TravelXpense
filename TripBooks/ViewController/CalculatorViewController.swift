//
//  CalculatorViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/15.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

protocol CalculatorDelegate: AnyObject {
    func changeTransactionType(type: TransactionType)
    func changeAmountValue(amount: String)
}

enum OperationType: String {
    case add
    case subtract
    case multiply
    case divide
    case none
}

enum TransactionType: String {
    case Expense
    case Income
}

fileprivate let typeBtnId = "type"
fileprivate let clearBtnId = "clear"
fileprivate let pointBtnId = "point"
fileprivate let okayBtnId = "okay"

class CalculatorViewController: UIViewController {

    weak var delegate: CalculatorDelegate?
    
    private var buttonHeight: CGFloat = 0
    
    var viewRatio: CGFloat! {
        didSet {
            buttonHeight = UIScreen.main.bounds.height * viewRatio! * 0.2
        }
    }
    
    private var buttons = [String: UIButton]()
    private var operationButtons = [OperationType: UIButton]()
    private var amountText: String = "" {
        didSet {
            amountText = checkAmountTextLength(amountText)
            self.delegate?.changeAmountValue(amount: amountText)
        }
    }
    
    private var currentOperationBtn: UIButton? = nil {
        didSet {
            if currentOperationBtn != nil {
                UIView.animate(withDuration: 0.2) {
                    self.currentOperationBtn?.backgroundColor = TBColor.darkGary
                }
            }
        }
        willSet {
            UIView.animate(withDuration: 0.2) {
                self.currentOperationBtn?.backgroundColor = .clear
            }
        }
    }
    
    // calculator
    var numberOnScreen: Double = 0 // 稍後要存目前畫面上的數字，目前是 0。
    private var previousNumber: Double = 0 // 要存的運算之前畫面上的數字。
    private var performingMath = false { // 記錄目前是不是在運算過程中。
        didSet {
            if performingMath {
                buttons[okayBtnId]!.setTitle("=", for: .normal)
            } else {
                buttons[okayBtnId]!.setTitle("OK", for: .normal)
                currentOperationBtn = nil
            }
        }
    }
    
    private var operation: OperationType = .none // 一開始什麼運算都還沒執行，所以設定是 none。
    private var resetNumber = true {
        didSet {
            if resetNumber {
                havePoint = false
            }
        }
    }
    
    private var havePoint = false // 是否已有小數點
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    @IBAction func numberTapped(_ sender: UIButton) {
        TBFeedback.buttonOccur()
        guard let inputNum = sender.restorationIdentifier else {
            return
        }
        
        if inputNum == pointBtnId {
            if havePoint { // 若已有小數點,忽略。
                return
            }
        }
        
        if amountText == "0" || resetNumber {
            if inputNum == pointBtnId {
                amountText = "0."
                havePoint = true
            } else {
                amountText = inputNum
            }
            resetNumber = false
        } else {
            if inputNum == pointBtnId {
                amountText +=  "."
                havePoint = true
            } else {
                amountText += inputNum
            }
        }

        let number = Double(amountText) ?? 0
        numberOnScreen = checkAmountLimited(number)
    
    }
    
    @IBAction func tapOperation(_ sender: UIButton) {
        TBFeedback.buttonOccur()
        guard let operationId = sender.restorationIdentifier,
              let operationType = OperationType.init(rawValue: operationId) else {
            return
        }

        currentOperationBtn = sender
        operation = operationType
        performingMath = true
        previousNumber = numberOnScreen
        resetNumber = true
    }
    
    @IBAction func clearTapped() {
        TBFeedback.buttonOccur()
        amountText = ""
        numberOnScreen = 0
        previousNumber = 0
        performingMath = false
        operation = .none
        resetNumber = true
    }
    
    @IBAction func changeTransactionTapped(_ sender: UIButton) {
        TBFeedback.notificationOccur(.warning)
        if let title = sender.title(for: .normal),
           var type = TransactionType.init(rawValue: title) {
            switch type {
            case .Expense:
                type = TransactionType.Income
            case .Income:
                type = TransactionType.Expense
            }
            sender.setTitle(type.rawValue, for: .normal)
            self.delegate?.changeTransactionType(type: type)
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        TBFeedback.notificationOccur(.success)
        if sender.title(for: .normal) == "OK" { // finish
            numberOnScreen = checkAmountLimited(numberOnScreen)
            amountText = TBFunc.convertDoubleToStr(numberOnScreen, moneyFormat: false)
            TBNotify.dismiss(name: CalculatorAttributes)
            return
        }
        if performingMath {
            switch operation {
            case .add:
                numberOnScreen = previousNumber + numberOnScreen
            case .subtract:
                numberOnScreen =  previousNumber - numberOnScreen
            case .multiply:
                numberOnScreen = previousNumber * numberOnScreen
            case .divide:
                numberOnScreen = (numberOnScreen == 0) ? 0 : previousNumber / numberOnScreen
            case .none:
                numberOnScreen = 0
            }
            
            numberOnScreen = checkAmountLimited(numberOnScreen)
            amountText = TBFunc.convertDoubleToStr(numberOnScreen, moneyFormat: false)
        }
        
        performingMath = false
        resetNumber = true
    }
    
    private func setViews() {
        
        setButton()
        
        let hStackView_1 = UIStackView()
        let hStackView_1_2 = UIStackView()
        hStackView_1.axis = .horizontal
        hStackView_1.distribution = .fillEqually
        let typeBtn = buttons[typeBtnId]!
        hStackView_1.addArrangedSubview(typeBtn)
        hStackView_1.addArrangedSubview(hStackView_1_2)
             
        hStackView_1_2.axis = .horizontal
        hStackView_1_2.distribution = .fillEqually
        hStackView_1_2.addArrangedSubview(buttons[clearBtnId]!)
        hStackView_1_2.addArrangedSubview(operationButtons[.add]!)
        
        let hStackView_2 = UIStackView()
        hStackView_2.axis = .horizontal
        hStackView_2.distribution = .fillEqually
        hStackView_2.addArrangedSubview(buttons["7"]!)
        hStackView_2.addArrangedSubview(buttons["8"]!)
        hStackView_2.addArrangedSubview(buttons["9"]!)
        hStackView_2.addArrangedSubview(operationButtons[.subtract]!)
        
        let hStackView_3 = UIStackView()
        hStackView_3.axis = .horizontal
        hStackView_3.distribution = .fillEqually
        hStackView_3.addArrangedSubview(buttons["4"]!)
        hStackView_3.addArrangedSubview(buttons["5"]!)
        hStackView_3.addArrangedSubview(buttons["6"]!)
        hStackView_3.addArrangedSubview(operationButtons[.multiply]!)
        
        let hStackView_4 = UIStackView()
        hStackView_4.axis = .horizontal
        hStackView_4.distribution = .fillEqually
        hStackView_4.addArrangedSubview(buttons["1"]!)
        hStackView_4.addArrangedSubview(buttons["2"]!)
        hStackView_4.addArrangedSubview(buttons["3"]!)
        hStackView_4.addArrangedSubview(operationButtons[.divide]!)
        
        let hStackView_5 = UIStackView()
        let hStackView_5_2 = UIStackView()
        hStackView_5.axis = .horizontal
        hStackView_5.distribution = .fillEqually
        hStackView_5.addArrangedSubview(buttons["0"]!)
        hStackView_5.addArrangedSubview(hStackView_5_2)
        
        hStackView_5_2.axis = .horizontal
        hStackView_5_2.distribution = .fillEqually
        hStackView_5_2.addArrangedSubview(buttons[pointBtnId]!)
        hStackView_5_2.addArrangedSubview(buttons[okayBtnId]!)
        
        let mainvStackView = UIStackView()
        mainvStackView.axis = .vertical
        mainvStackView.distribution = .fillEqually
        mainvStackView.addArrangedSubview(hStackView_1)
        mainvStackView.addArrangedSubview(hStackView_2)
        mainvStackView.addArrangedSubview(hStackView_3)
        mainvStackView.addArrangedSubview(hStackView_4)
        mainvStackView.addArrangedSubview(hStackView_5)
        
        
        self.view.addSubview(mainvStackView)
        mainvStackView.fillSuperview()
    }
    
    var buttonView = [String: UIView]()
    
    private func setButton() {
        let btnColor: UIColor = .white
        let btnColorHighLighted: UIColor = .darkGray
        let numberFont = MainFontNumeral.regular.with(fontSize: 28)
        let wordsFont = MainFontNumeral.medium.with(fontSize: 28)
        let signFontLarge = MainFontNumeral.medium.with(fontSize: 30)
        
        // numbers
        for i in (0...9) {
            let numBtn = UIButton()
            let numStr = "\(i)"
            numBtn.setTitle(numStr, for: .normal)
            numBtn.titleLabel?.font = numberFont
            numBtn.setBackgroundColor(color: .darkGray, forState: .highlighted)
            buttons[numStr] = numBtn
            numBtn.restorationIdentifier = numStr
            numBtn.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
        }
        
        let dotBtn = UIButton()
        dotBtn.titleLabel?.font = signFontLarge
        dotBtn.setTitle(".", for: .normal)
        dotBtn.restorationIdentifier = pointBtnId
        dotBtn.addTarget(self, action: #selector(numberTapped(_:)), for: .touchUpInside)
        buttons[pointBtnId] = dotBtn
        
        let typeBtn = UIButton()
        let typeTitle = TransactionType.Expense.rawValue // defalut type
        typeBtn.titleLabel?.font = wordsFont
        typeBtn.setTitle(typeTitle, for: .normal)
        typeBtn.restorationIdentifier = typeBtnId
        typeBtn.addTarget(self, action: #selector(changeTransactionTapped(_:)), for: .touchUpInside)
        buttons[typeBtnId] = typeBtn
        
        let clearBtn = UIButton()
        let clearBtnTitle = "C"
        clearBtn.titleLabel?.font = wordsFont
        clearBtn.setTitle(clearBtnTitle, for: .normal)
        clearBtn.restorationIdentifier = clearBtnId
        clearBtn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        buttons[clearBtnId] = clearBtn
        
        let okayBtn = UIButton()
        let okayBtnTitle = "OK"
        okayBtn.titleLabel?.font = wordsFont
        okayBtn.setTitle(okayBtnTitle, for: .normal)
        okayBtn.restorationIdentifier = okayBtnId
        okayBtn.addTarget(self, action: #selector(doneBtnTapped(_:)), for: .touchUpInside)
        buttons[okayBtnId] = okayBtn
        
        for btn in buttons.values {
            btn.setTitleColor(btnColor, for: .normal)
            btn.setTitleColor(btnColorHighLighted, for: .highlighted)
        }
        
        // operation
        let addBtn = UIButton()
        addBtn.restorationIdentifier = OperationType.add.rawValue
        addBtn.setTitle("+", for: .normal)
        
        let subtractBtn = UIButton()
        subtractBtn.restorationIdentifier = OperationType.subtract.rawValue
        subtractBtn.setTitle("−", for: .normal)
        
        let multiplyBtn = UIButton()
        multiplyBtn.restorationIdentifier = OperationType.multiply.rawValue
        multiplyBtn.setTitle("×", for: .normal)
        
        let divideBtn = UIButton()
        divideBtn.restorationIdentifier = OperationType.divide.rawValue
        divideBtn.setTitle("÷", for: .normal)
        
        operationButtons[.add] = addBtn
        operationButtons[.subtract] = subtractBtn
        operationButtons[.multiply] = multiplyBtn
        operationButtons[.divide] = divideBtn
        
        for btn in operationButtons.values {
            btn.setTitleColor(btnColor, for: .normal)
            btn.setTitleColor(btnColorHighLighted, for: .highlighted)
            btn.titleLabel?.font = signFontLarge
            btn.addTarget(self, action: #selector(tapOperation(_:)), for: .touchUpInside)
        }
    }
    
    private func checkAmountTextLength(_ amountText: String) -> String {
        if amountText.count >= 13 {
            if String(amountText.prefix(1)) == "-" {
                let text = String(amountText.prefix(14))
                return text
            }
            let text = String(amountText.prefix(13))
            return text
        }
        return amountText
    }
    
    private func checkAmountLimited(_ amount: Double) -> Double {
        var value = amount
        value = min(value, amountMaxValue)
        value = max(value, amountMinValue)
        value = value.rounding(toDecimal: 6)
        return value
    }
}
