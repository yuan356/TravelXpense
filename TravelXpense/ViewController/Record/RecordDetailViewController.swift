//
//  RecordDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate enum RecordDetailCellRow {
    case amount
    case title
    case account
    case date
    case note
}

fileprivate enum ToolType: String {
    case amount
    case date
    case account
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let paddingInCategoriesCollectionView: CGFloat = 5

// Height
fileprivate let heightForCheckButton: CGFloat = 25
fileprivate let heightForCategoryView: CGFloat = 164

//  detail
fileprivate let heightForDetailView: CGFloat = 40
fileprivate let heightForAmountView: CGFloat = 80
fileprivate let heightForNoteView: CGFloat = 150

fileprivate let textViewPlaceholderColor = TXColor.gray.light

fileprivate let textFont = MainFont.regular.with(fontSize: .medium)
fileprivate let inputTextColor: UIColor = .white
// cornerRadius
private let cornerRadius: CGFloat = 10

private let categoryCell = "CategoryCell"

/**
    Insert / update record
    # (Insert) Necessary setting when init:
        1. book
        2. recordDate
        3.originalDate
    # (Update) Necessary setting when init:
        1. book
        2. record
 */

class RecordDetailViewController: UIViewController {
    
    // MARK: Necessary setting when init
    var book: Book!
    
    // MARK: parameter for record(save, edit)
    var record: Record? = nil {
        didSet {
            if let record = record {
                // start calculate at positive number
                var initValue = record.amount
                initValue.turnToPositive()
                self.recordAmount = initValue
                self.amountLabel.text = TXFunc.convertDoubleToStr(recordAmount, moneyFormat: false)
                self.titleTextField.text = record.title
                self.recordDate = record.date
                self.originalDate = record.date
                self.recoredCategory = record.category
                self.recordAccount = record.account
                if record.note != "" {
                    noteTextView.text = record.note
                }
            }
        }
    }
    
    var recordDate: Date? {
        didSet {
            self.dateLabel.text = TXFunc.convertDateToDateStr(date: recordDate!)
        }
    }
    
    var originalDate: Date!
    
    var recoredCategory: Category?
    
    var recordAccount: Account? {
        didSet {
            accountLabel.text = recordAccount?.name
        }
    }
    
    var recordAmount: Double = 0
    
    var currentCategoryCell: IconsCollectionViewCell<Category>?
    
    var categories: [Category] {
        return CategoryService.shared.expenseCategories
    }
    
    // TODO: transactionIsExpense
    var transactionIsExpense: Bool = true
    
    // View
    lazy var headerView = UIView {
        let cancelBtn = TXNavigationIcon.cancel.getButton()
        $0.addSubview(cancelBtn)
        cancelBtn.anchorButtonToHeader(position: .left)
        cancelBtn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        let okayBtn = TXNavigationIcon.check.getButton()
        $0.addSubview(okayBtn)
        okayBtn.anchorButtonToHeader(position: .right)
        okayBtn.addTarget(self, action: #selector(saveButtonClicked(_:)), for: .touchUpInside)
    }
    
    lazy var contentView = UIView()
    
    lazy var amountView = UIView {
        $0.backgroundColor = TXColor.system.blue.medium
        $0.anchorSize(h: heightForAmountView)
        $0.roundedCorners(radius: cornerRadius)
    }
    
    lazy var amountLabel = UILabel {
        $0.font = MainFontNumeral.regular.with(fontSize: 40)
        $0.text = "0"
        $0.textColor = .white
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
    }
    
    lazy var categoriesView = UIView {
        $0.anchorSize(h: heightForCategoryView)
        $0.layer.cornerRadius = cornerRadius
    }
    
    var categoriesCollectionView: UICollectionView!
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = spacingInVStack
        $0.axis = .vertical
        $0.anchorSize(h: (heightForDetailView * 2) + spacingInVStack)
    }
    
    lazy var titleTextField = UITextField {
        let msg = NSLocalizedString("recordTitle", comment: "recordTitle")
        $0.attributedPlaceholder = NSAttributedString(string: msg, attributes: [NSAttributedString.Key.foregroundColor: textViewPlaceholderColor])
        $0.font = textFont
        $0.textColor = inputTextColor
        $0.textAlignment = .left
    }
    
    lazy var dateLabel = UILabel {
        $0.font = MainFontNumeral.regular.with(fontSize: .medium)
        $0.textColor = inputTextColor
        $0.textAlignment = .center
    }
        
    lazy var datePickButton = UIButton {
        $0.restorationIdentifier = ToolType.date.rawValue
        $0.addTarget(self, action: #selector(openTools(_:)), for: .touchUpInside)
    }
    
    lazy var accountLabel = UILabel {
        $0.font = textFont
        $0.textColor = inputTextColor
        $0.textAlignment = .center
    }
    
    lazy var accountPickButton = UIButton {
        $0.restorationIdentifier = ToolType.account.rawValue
        $0.addTarget(self, action: #selector(openTools(_:)), for: .touchUpInside)
    }
    
    lazy var noteTextView = UITextView {
        $0.backgroundColor = .clear
        $0.font = MainFont.regular.with(fontSize: 18)
        $0.textAlignment = .left
        $0.text = NSLocalizedString("Note", comment: "Note")
    }
    
    lazy var doneButton = UIButton {
        $0.backgroundColor = TXColor.system.veronese
        $0.setTitle(NSLocalizedString("Done", comment: "Done"), for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 20)
        $0.tintColor = .white
        $0.setTitleColor(.lightGray, for: .highlighted)
        $0.addTarget(self, action: #selector(saveButtonClicked(_:)), for: .touchUpInside)
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.anchorSize(h: 50)
        $0.roundedCorners(radius: cornerRadius)
    }
    
    var currentTextField: UITextField?
    
    var currentTextView: UITextView?
    
    var isKeyboardShown: Bool = false {
        didSet {
            datePickButton.isEnabled = !isKeyboardShown
            accountPickButton.isEnabled = !isKeyboardShown
        }
    }
    
    @IBAction func doneButtonOnTap(_ sender: UIButton) {
        sender.backgroundColor = .white
    }


    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        setContentViewAndHeader()
        
        setAmountView()
        
        setCategoryView()
        
        setVStackView()
        
        self.contentView.addSubview(doneButton)
        
        setNoteView()
        
        setDoneButton()
        
        // 鍵盤的生命週期
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardWillShow),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil)
                
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardWillHide),
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        TBNotify.showCalculator(on: self, originalAmount: recordAmount, currencyCode: book.currency.code)
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        TXAlert.dismiss(name: CalculatorAttributes)
    }
    
    
    // MARK: Keyboard Observer
    @objc func keyboardWillShow(notification: NSNotification) {
        guard !isKeyboardShown else {
            return
        }
        isKeyboardShown = true
        
        // get keyboardSize
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            // if keyboard size is not available for some reason, dont do anything
            return
          }

          var shouldMoveViewUp = false
        
          // if active text field is not nil
          if noteTextView.isFirstResponder {
            let bottomOfTextField = noteTextView.convert(noteTextView.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height

          // if the bottom of Textfield is below the top of keyboard, move up
            if bottomOfTextField > topOfKeyboard {
               shouldMoveViewUp = true
            }
          } else if let activeItem = currentTextField {
              let bottomOfTextField = activeItem.convert(activeItem.bounds, to: self.view).maxY;
              let topOfKeyboard = self.view.frame.height - keyboardSize.height

            // if the bottom of Textfield is below the top of keyboard, move up
              if bottomOfTextField > topOfKeyboard {
                 shouldMoveViewUp = true
              }
          }
        
          if (shouldMoveViewUp) {
             self.view.frame.origin.y = 0 - keyboardSize.height
          }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        isKeyboardShown = false
        let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
        let duration = TimeInterval(truncating: keyboardAnimationDetail[UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber)

        UIView.animate(
            withDuration: duration,
            animations: { () -> Void in
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.view.frame.origin.y)
            }
        )
//        self.view.frame.origin.y = 0
    }

    // MARK: - Detail View Setting
    /// add contentView & HeaderView to self.view
    private func setContentViewAndHeader() {
        self.view.addSubview(headerView)
        headerView.anchorViewOnTop()
        
        self.view.addSubview(contentView)
        contentView.anchor(top: headerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }

    /// add amountVuew & amountTextField to contentView
    private func setAmountView() {
        contentView.addSubview(amountView)
        amountView.anchor(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        
        amountView.addSubview(amountLabel)
        amountLabel.fillSuperview(padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))
        
        let calculatorButton = UIButton()
        calculatorButton.restorationIdentifier = ToolType.amount.rawValue
        calculatorButton.addTarget(self, action: #selector(openTools(_:)), for: .touchUpInside)
        amountView.addSubview(calculatorButton)
        calculatorButton.fillSuperview()
    }
    
    // MARK: categoryView
    /// add categoriesView to contentView & setting
    private func setCategoryView() {
        self.contentView.addSubview(categoriesView)
        categoriesView.anchor(top: amountView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView + 2, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        
        categoriesCollectionView = initCategoriesCollectionView()
        self.categoriesView.addSubview(categoriesCollectionView)
        categoriesCollectionView.fillSuperview()
    }
    
    /// categoriesCollectionView setting
    private func initCategoriesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let pd = paddingInCategoriesCollectionView
        let heightForCollection = heightForCategoryView - (pd * 2)
        let height = (heightForCollection - pd) / 2
        let widthIconView = (UIScreen.main.bounds.width - (pd * 4) - paddingInContentView * 2) / 3
        layout.itemSize = CGSize(width: widthIconView, height: height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = pd
        layout.minimumInteritemSpacing = pd
        layout.sectionInset = UIEdgeInsets(top: pd, left: pd, bottom: 0, right: pd)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IconsCollectionViewCell<Category>.self, forCellWithReuseIdentifier: categoryCell)
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }
    
    // MARK: vStackView
    /// add vStackView to contentView & setting
    private func setVStackView() {
        contentView.addSubview(vStackView)
        vStackView.anchor(top: categoriesView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))

        let titleView = UIView()
        titleView.anchorSize(h: heightForDetailView)
        setDetailView(to: titleView, type: .title)

        let accountView = UIView()
        setDetailView(to: accountView, type: .account)
        
        let dateView = UIView()
        setDetailView(to: dateView, type: .date)
        
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.alignment = .fill
        hStackView.spacing = paddingInContentView
        hStackView.addArrangedSubview(dateView)
        hStackView.addArrangedSubview(accountView)
        hStackView.anchorSize(h: heightForDetailView)
        
        vStackView.addArrangedSubview(titleView)
        vStackView.addArrangedSubview(hStackView)
    }
    
    /// add a View to contentView for noteTextView
    func setNoteView() {
        let noteView = UIView()
        setDetailView(to: noteView, type: .note)
        contentView.addSubview(noteView)
        noteView.anchor(top: vStackView.bottomAnchor, bottom: doneButton.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView + 10, right: paddingInContentView))
        noteView.addSubview(noteTextView)
        noteTextView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
        
    // MARK: setDetailView
    /// 各 detail 的細節設定(加入lineView)
    private func setDetailView(to view: UIView, type: RecordDetailCellRow) {
        
        let lineView = UIView()
        lineView.backgroundColor = TXColor.gray.medium
        lineView.anchorSize(h: 1)
        
        view.addSubview(lineView)
        let linePd: CGFloat = 10
        lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: linePd, bottom: 0, right: linePd))
        
        let pdInDetail: CGFloat = 15
        switch type {
        case .amount:
            break
        case .title:
            view.addSubview(titleTextField)
            titleTextField.delegate = self
            titleTextField.anchor(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: pdInDetail, bottom: 0, right: pdInDetail))
        case .account:
            view.addSubview(accountLabel)
            accountLabel.fillSuperview()
            view.addSubview(accountPickButton)
            accountPickButton.anchorToSuperViewCenter()
            accountPickButton.anchorSize(to: accountLabel)
            break
        case .note:
            noteTextView.delegate = self
            if let record = record, record.note != "" {
                noteTextView.textColor = .white
            } else {
                noteTextView.textColor = textViewPlaceholderColor
            }
                
            currentTextView = noteTextView
            break
        case .date:
            view.addSubview(dateLabel)
            dateLabel.fillSuperview()
            view.addSubview(datePickButton)
            datePickButton.anchorToSuperViewCenter()
            datePickButton.anchorSize(to: dateLabel)
            break
        }
    }
    
    /// done button setting
    private func setDoneButton() {
        doneButton.anchor(top: nil, bottom: self.contentView.safeAreaLayoutGuide.bottomAnchor, leading: self.contentView.leadingAnchor, trailing: self.contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: paddingInContentView, bottom: paddingInContentView + 10, right: paddingInContentView))
        doneButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
    }
    
    /// return a line View
    private func getLineView() -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = .white
        lineView.anchorSize(h: 1)
        return lineView
    }
    
    // MARK: - open tools
    /// open a datepicker
    @IBAction func openTools(_ sender: UIButton) {
        if let identifier = sender.restorationIdentifier {
            switch ToolType.init(rawValue: identifier) {
            case .amount:
                TXAlert.showCalculator(on: self, originalAmount: recordAmount, currencyCode: book.currency.code)
            case .date:
                let datePickerVC = TBdatePickerViewController()
                if let date = self.recordDate {
                    datePickerVC.setDate(date: date)
                }
                datePickerVC.setMinimumDate(book.startDate)
                datePickerVC.setMaximumDate(book.endDate)
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .account:
                TXAlert.showPicker(type: .account, currentObject: recordAccount) { (result, account) in
                    if result == CompletionResult.success, let acc = account as? Account {
                        self.recordAccount = acc
                    }
                }
            case .none:
                break
            }
        }
    }
    
    @IBAction func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Save
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let checkResult = checkInput()
        guard checkResult == nil else {
            TXAlert.showCenterAlert(message: checkResult!)
            return
        }
        
        guard let category = self.recoredCategory,
              let amountText = amountLabel.text,
              let amount = Double(amountText),
              let date = self.recordDate,
              let account = self.recordAccount else {
            return
        }

        recordAmount = amount
        if transactionIsExpense {
            recordAmount.turnToNegative()
        } else {
            recordAmount.turnToPositive()
        }
        let title: String? = titleTextField.text?.trimmingCharacters(in: .whitespaces)
        var note: String? = noteTextView.text.trimmingCharacters(in: .whitespaces)
        
        if noteTextView.textColor == textViewPlaceholderColor {
            note = ""
        }
        
        var needToReloadTable = false
        if let record = self.record { // update
            RecordSevice.shared.updateRecord(id: record.id, title: title, amount: recordAmount, note: note, date: date.timeIntervalSince1970, bookId: book.id, categoryId: category.id, accountId: account.id)
            
            needToReloadTable = true
        } else { // insert
            RecordSevice.shared.addNewRecord(title: title, amount: recordAmount, note: note, date: date.timeIntervalSince1970, bookId: book.id, categoryId: category.id, accountId: account.id)
            
            needToReloadTable = TXFunc.compareDateOnly(date1: date, date2: self.originalDate)
        }
        
        // didn't change the date, current record table need to update.
        // notify the recordTable observer
        if needToReloadTable {
            TXObserved.notifyObservers(notificationName: .recordTableUpdate, infoKey: nil, infoValue: nil)
        }
        
        TXFeedback.notificationOccur(.success)
        dismiss(animated: true, completion: nil)
        
    }
    
    private func checkInput() -> String? {
        
        // amount
        guard let amountText = amountLabel.text?.trimmingCharacters(in: .whitespaces),
              amountText != ""  else {
            return NSLocalizedString("Please enter amount", comment: "Please enter amount")
        }
        
        guard let _ = Double(amountText) else {
            return NSLocalizedString("Amount is wrong format", comment: "Amount is wrong format")
        }
        
        // title
        if let title = titleTextField.text {
            if title.count > 100 {
                return NSLocalizedString("Title should be less than 100 characters", comment: "TTitle should be less than 100 characters")
            }
        }
        
        // category
        if self.recoredCategory == nil {
            return NSLocalizedString("Please choose a category", comment: "Please choose a category")
        }
        
        // date
        if self.recordDate == nil {
            return NSLocalizedString("Please choose a date", comment: "Please choose a date")
        }
        
        // account
        if self.recordAccount == nil {
            return NSLocalizedString("Please choose an account", comment: "Please choose an account")
        }
        
        // note
        if let note = noteTextView.text {
            if note.count > 500 {
                return NSLocalizedString("Note should be less than 500 characters", comment: "Note should be less than 500 characters")
            }
        }
        
        return nil
    }
}

// MARK: - Extension
// MARK: TBDatePickerDelegate
extension RecordDetailViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        self.recordDate = date
    }
}

extension RecordDetailViewController: CalculatorDelegate {
    func changeTransactionType(type: TransactionType) {
//        print("change to : \(type)")
    }
    
    func changeAmountValue(amountStr: String) {
        amountLabel.text = amountStr
    }
}

// MARK: UITextFieldDelegate, UITextViewDelegate
extension RecordDetailViewController: UITextFieldDelegate, UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        datePickButton.isEnabled = false
        self.currentTextField = textField
    }
    
    // when user click 'done' or dismiss the keyboard
     func textFieldDidEndEditing(_ textField: UITextField) {
       self.currentTextField = nil
     }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == textViewPlaceholderColor && textView.isFirstResponder {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = textViewPlaceholderColor
            textView.text = NSLocalizedString("Note", comment: "Note")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//     輸入字數限制 textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 100
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    // 輸入字數限制 textView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 500
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= maxLength
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension RecordDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as? IconsCollectionViewCell<Category> {
            if indexPath.row < CategoryService.shared.expenseCategories.count {
                let cate = CategoryService.shared.expenseCategories[indexPath.row]
                cell.setupIconViews(imageName: cate.iconImageName, title: cate.title, colorHex: cate.colorHex)
                cell.item = cate
                if cate.id == recoredCategory?.id {
                    cell.itemIsSelected = true
                    currentCategoryCell = cell
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? IconsCollectionViewCell<Category> {
            
            // 若已有選擇的category，且不為同個cell，移除選擇。
            if let currentCell = currentCategoryCell, currentCategoryCell != cell {
                currentCell.itemIsSelected = false
            }
            
            cell.itemIsSelected = !cell.itemIsSelected
            if cell.itemIsSelected { // selected category
                currentCategoryCell = cell
                recoredCategory = cell.item
            } else { // remove selected
                currentCategoryCell = nil
                recoredCategory = nil
            }
        }
    }
}
