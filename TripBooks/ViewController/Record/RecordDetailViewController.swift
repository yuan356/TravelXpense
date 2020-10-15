//
//  RecordDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate enum RecordDetailCellRow: Int {
    case amount = 0
    case title
    case category
    case account
    case date
    case note
}

fileprivate enum pickerType: String {
    case date
    case account
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let spacingInVStack: CGFloat = 8
let paddingInCategoriesCollectionView: CGFloat = 5

// Height
fileprivate let heightForCheckButton: CGFloat = 25
fileprivate let heightForCategoryView: CGFloat = 164

//  detail
fileprivate let heightForDetailView: CGFloat = 40
fileprivate let heightForAmountView: CGFloat = 80
fileprivate let heightForNoteView: CGFloat = 150

fileprivate let textViewPlaceholderColor = TBColor.gary

// cornerRadius
private let cornerRadius: CGFloat = 10

private let categoryCell = "CategoryCell"

class RecordDetailViewController: UIViewController {
    
    var book: Book!
    
    // MARK: parameter for record(save, edit)
    var record: Record? = nil {
        didSet {
            if let record = record {
                self.recordDate = record.date
                self.recoredCategory = record.category
                
            }
        }
    }
    
    var recordDate: Date? {
        didSet {
            self.dateLabel.text = TBfunc.convertDateToDateStr(date: recordDate!)
        }
    }
    
    var recoredCategory: Category?
    
    var recordAccount: Account? {
        didSet {
            accountLabel.text = recordAccount?.name
        }
    }
    
    var currentCategoryCell: CategoriesCollectionViewCell? = nil
    
    var categories: [Category] {
        return CategoryService.shared.categories
    }
    
    // View
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        
        let checkButton = TBButton.check.getButton()
        view.addSubview(checkButton)
        checkButton.anchorButtonToHeader(position: .right)
        checkButton.addTarget(self, action: #selector(saveButtonClicked(_:)), for: .touchUpInside)
        
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let amountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#CCE2FF")
        view.anchorSize(height: heightForAmountView)
        view.roundedCorners(radius: cornerRadius)
        return view
    }()
    
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = MainFont.regular.with(fontSize: .large)
//        textField.font = UIFont.systemFont(ofSize: 30)
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        return textField
    }()
    
    let categoriesView: UIView = {
        let view = UIView()
        view.anchorSize(height: heightForCategoryView)
        view.layer.cornerRadius = cornerRadius
        return view
    }()
    
    var categoriesCollectionView: UICollectionView!
    
    let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = spacingInVStack
        stackView.axis = .vertical
        stackView.anchorSize(height: (heightForDetailView * 2) + spacingInVStack)
        return stackView
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: textViewPlaceholderColor])
        textField.font = MainFont.regular.with(fontSize: .medium)
        textField.textAlignment = .left
        return textField
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
        
    let datePickButton: UIButton = {
        let button = UIButton()
        button.restorationIdentifier = pickerType.date.rawValue
        button.addTarget(self, action: #selector(openPicker(_:)), for: .touchUpInside)
        return button
    }()
    
    let accountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    let accountPickButton: UIButton = {
        let button = UIButton()
        button.restorationIdentifier = pickerType.account.rawValue
        button.addTarget(self, action: #selector(openPicker(_:)), for: .touchUpInside)
        return button
    }()
    
    let noteTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textAlignment = .left
        textView.text = "Type your notes here..."
        return textView
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = TBColor.shamrockGreen.light
        button.setTitle("DONE", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setBackgroundColor(color: TBColor.shamrockGreen.dark, forState: .highlighted)
        button.anchorSize(height: 50)
        button.roundedCorners(radius: cornerRadius)
        return button
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setContentViewAndHeader()
        
        setAmountTextField()
        
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
          if noteTextView.isFirstResponder, let activeItem = currentTextView {

              let bottomOfTextField = activeItem.convert(activeItem.bounds, to: self.view).maxY;
            
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

          if(shouldMoveViewUp) {
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
        self.view.backgroundColor = .darkGray
        self.view.addSubview(headerView)
        headerView.anchorViewOnTop()
        
        self.view.addSubview(contentView)
        contentView.anchor(top: headerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }

    /// add amountVuew & amountTextField to contentView
    private func setAmountTextField() {
        contentView.addSubview(amountView)
        amountView.anchor(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        
        amountView.addSubview(amountTextField)
        amountTextField.fillSuperview(padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))
    }
    
    // MARK: categoryView
    /// add categoriesView to contentView & setting
    private func setCategoryView() {
        self.contentView.addSubview(categoriesView)
        categoriesView.anchor(top: amountView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        
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
        collectionView.backgroundColor = .darkGray
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CategoriesCollectionViewCell.self, forCellWithReuseIdentifier: categoryCell)
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
        titleView.anchorSize(height: heightForDetailView)
        setDetailView(name: "Title", to: titleView, type: .title)

        let accountView = UIView()
        setDetailView(name: "Account", to: accountView, type: .account)
        
        let dateView = UIView()
        dateView.anchorSize(height: heightForDetailView)
        setDetailView(name: "Date", to: dateView, type: .date)
        
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.alignment = .fill
        hStackView.spacing = paddingInContentView
        hStackView.addArrangedSubview(dateView)
        hStackView.addArrangedSubview(accountView)
        hStackView.anchorSize(height: heightForDetailView)
        
        vStackView.addArrangedSubview(titleView)
        vStackView.addArrangedSubview(hStackView)
    }
    
    /// add a View to contentView for noteTextView
    func setNoteView() {
        let noteView = UIView()
        setDetailView(name: "Note", to: noteView, type: .note)
        contentView.addSubview(noteView)
        noteView.anchor(top: vStackView.bottomAnchor, bottom: doneButton.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView + 10, right: paddingInContentView))
        noteView.addSubview(noteTextView)
        noteTextView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    /// 各 detail 的細節設定(加入lineView)
    private func setDetailView(name: String, to view: UIView, type: RecordDetailCellRow) {
        
        let lineView = UIView()
        lineView.backgroundColor = .white
        lineView.anchorSize(height: 1)
        
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
        case .category:
            break
        case .account:
            view.addSubview(accountLabel)
            accountLabel.fillSuperview()
            view.addSubview(accountPickButton)
            accountPickButton.anchorToSuperViewCenter()
            accountPickButton.anchorSize(to: accountLabel)
            break
        case .note:
            noteTextView.delegate = self
            noteTextView.textColor = textViewPlaceholderColor
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
        lineView.anchorSize(height: 1)
        return lineView
    }
    
    // MARK: - Button clicked event
    /// open a datepicker
    @IBAction func openPicker(_ sender: UIButton) {
        if let identifier = sender.restorationIdentifier {
            switch pickerType.init(rawValue: identifier) {
            case .date:
                let datePickerVC = TBdatePickerViewController()
                if let date = self.recordDate {
                    datePickerVC.setDate(date: date)
                }
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .account:
                TBNotifyCenter.showAccountPicker { (result, account) in
                    if result == Result.success, let acc = account {
                        self.recordAccount = acc
                    }
                }
            case .none:
                break
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        print("saveButtonClicked")
        let checkResult = checkInput()
        guard checkResult == nil else {
            TBNotifyCenter.showCenterAlert(message: checkResult!)
            return
        }
        
        guard let amountText = amountTextField.text?.trimmingCharacters(in: .whitespaces),
              let amount = Double(amountText),
              let category = self.recoredCategory,
              let date = self.recordDate,
              let account = self.recordAccount else {
            return
        }
        
        let title: String? = titleTextField.text?.trimmingCharacters(in: .whitespaces)
        let note: String? = noteTextView.text.trimmingCharacters(in: .whitespaces)
        
//        print("""
//            amount: \(amount)
//            title: \(title)
//            date: \(date)
//            category: \(category.title)
//            note: \(note)
//            """)
        
        RecordSevice.shared.addNewBook(title: title, amount: amount, note: note, date: date.timeIntervalSince1970, bookId: book.id, categoryId: category.id, accountId: account.id) { (newRecord) in
            print("NEW: \(newRecord.amount)")
        }
        
        
        
    }
    
    private func checkInput() -> String? {
        
        // amount
        guard let amountText = amountTextField.text?.trimmingCharacters(in: .whitespaces),
              amountText != ""  else {
            return "amountTextField text is empty."
        }

        // TODO: check number in calculator
//        guard amountText.isNumber, let amount = Double(amountText) else {
//            return "amountTextField wrong format."
//        }
        
        // category
        if self.recoredCategory == nil {
            return "recordCategory didnt set."
        }
        
        // date
        if self.recordDate == nil {
            return "recordDate didnt set."
        }
        
        // account
        if self.recordAccount == nil {
            return "recordAccount didnt set."
        }
        
        return nil
    }
    
    
}

// MARK: - Extension
// MARK: TBDatePickerDelegate
extension RecordDetailViewController: TBDatePickerDelegate {
    func changeDate(identifier: String, date: Date) {
        self.recordDate = date
    }
}

extension RecordDetailViewController: CalculatorDelegate {
    func changeTransactionType() {
        print("changeTransactionType")
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
            textView.textColor = .lightGray
            textView.text = "Type your notes here..."
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension RecordDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as? CategoriesCollectionViewCell {
            if indexPath.row < CategoryService.shared.categories.count {
                cell.category = CategoryService.shared.categories[indexPath.row]
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoriesCollectionViewCell {
            
            // 若已有選擇的category，且不為同個cell，移除選擇。
            if let currentCell = currentCategoryCell, currentCategoryCell != cell {
                currentCell.categoryIsSelected = false
            }
            
            cell.categoryIsSelected = !cell.categoryIsSelected
            if cell.categoryIsSelected { // selected category
                currentCategoryCell = cell
                recoredCategory = cell.category
            } else { // remove selected
                currentCategoryCell = nil
                recoredCategory = nil
            }
        }
        
    }
}
