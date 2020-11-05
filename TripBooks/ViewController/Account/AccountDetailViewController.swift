//
//  AccountDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/29.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let nameMaxLength = 100

fileprivate let backgroundColor = TBColor.system.background.dark

// height / width
fileprivate let heightForStackItem: CGFloat = 45
fileprivate let heightForCategoryView: CGFloat = 130

// padding
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let paddingInVStack: CGFloat = 8

// font
fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let numberFont: UIFont = MainFontNumeral.medium.with(fontSize: .medium)
fileprivate let textColor: UIColor = TBColor.gray.light

fileprivate enum EditRow {
    case name
    case budget
    case icon
}

class AccountDetailViewController: UIViewController {

    var account: Account? {
        didSet {
            setAccountInfo()
        }
    }
    
    var currentIconCell: IconsCollectionViewCell<String>?
    var accountIconName: String? {
        didSet {
            if let name = accountIconName {
                iconView.changeImage(imageName: name)
            }
        }
    }
    
    var currencyCode: String {
        get {
            if let book = BookService.shared.currentOpenBook {
                return book.currency.code
            }
            return ""
        }
    }
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = spacingInVStack
        $0.axis = .vertical
    }
    
    lazy var nameTextField = UITextField {
        $0.tintColor = .systemBlue
        $0.textAlignment = .right
        $0.font = textFont
        $0.textColor = textColor
    }
    
    lazy var budgetLabel = UILabel {
        $0.textAlignment = .right
        $0.font = numberFont
        $0.textColor = textColor
        $0.text = TBFunc.convertDoubleToStr(0, currencyCode: currencyCode)
    }
    
    var budget: Double! = 0.0 {
        didSet {
            budgetLabel.text = TBFunc.convertDoubleToStr(budget!, currencyCode: currencyCode)
        }
    }
    
    lazy var budgetButton = UIButton {
        $0.addTarget(self, action: #selector(openBudgetCalculator), for: .touchUpInside)
    }
    
    lazy var categoriesView = UIView {
        $0.anchorSize(h: heightForCategoryView)
        $0.roundedCorners()
        $0.layer.borderWidth = 1
        $0.layer.borderColor = TBColor.gray.medium.cgColor
    }
    
    lazy var defaultSwitch = UISwitch {
        $0.tintColor = .red
        $0.backgroundColor = TBColor.gray.medium
        $0.layer.cornerRadius = $0.frame.height / 2
        $0.onTintColor = TBColor.system.veronese

    }
    
    var keyboardShown = false {
        didSet {
            budgetButton.isEnabled = !keyboardShown
        }
    }
    
    var categoriesCollectionView: UICollectionView!

    lazy var iconView = IconView()
    
    lazy var saveButton = UIButton {
        $0.setTitle("Save", for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 18)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(TBColor.gray.medium, for: .highlighted)
        $0.anchorSize(h: 30, w: 55)
        $0.roundedCorners()
        $0.backgroundColor = TBColor.system.blue.medium
        $0.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
    }
    
    lazy var deleteButton = UIButton {
        $0.setTitle("Delete", for: .normal)
        $0.roundedCorners()
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
        $0.anchorSize(h: 50)
        $0.setTitleColor(.white, for: .normal)
        $0.isHidden = true
        $0.backgroundColor = TBColor.delete.normal
        $0.setBackgroundColor(color: TBColor.delete.highlighted, forState: .highlighted)
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        setViews()
    }
    
    private func setViews() {
        let saveBarItem = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = saveBarItem
        setVStackView()
        setCategoryView()
        
        self.view.addSubview(deleteButton)
        deleteButton.anchor(top: categoriesCollectionView.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15))
    }
    
    // MARK: setVStackView
    private func setVStackView() {
        var views = [UIView]()
        nameTextField.delegate = self
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Name", object: nameTextField))
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Budget", object: budgetLabel, withButton: budgetButton))
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Default", object: defaultSwitch))
        
        let iconBackView = UIView()
        iconBackView.addSubview(iconView)
        iconView.anchorCenterY(to: iconBackView)
        iconView.anchorSuperViewTrailing()
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Icon", object: iconBackView))

        for view in views {
            vStackView.addArrangedSubview(view)
        }

        view.addSubview(vStackView)
        let viewCount = CGFloat(views.count)
        let vStackHeight = (heightForStackItem * viewCount)
                            + (paddingInVStack * (viewCount - 1))
        
        let paddingInView: CGFloat = 8
        let bar = view.safeAreaLayoutGuide.topAnchor
        vStackView.anchor(top: bar, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: paddingInView, left: paddingInView, bottom: paddingInView, right: paddingInView), size: CGSize(width: 0, height: vStackHeight))
    }
    
    private func setCategoryView() {
        categoriesCollectionView = initCategoriesCollectionView()
        self.categoriesView.addSubview(categoriesCollectionView)
        categoriesCollectionView.fillSuperview()
        
        view.addSubview(categoriesView)
        categoriesView.anchor(top: vStackView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 0, right:15))
    }
    
    private func initCategoriesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()

        let height = (heightForCategoryView - 20 - 5) / 2
        layout.itemSize = CGSize(width: 50, height: height)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IconsCollectionViewCell<String>.self, forCellWithReuseIdentifier: String(describing: IconsCollectionViewCell<String>.self))
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }
    
    // MARK: Save
    @IBAction func saveButtonClicked() {
        guard let name = nameTextField.text,
              name.count <= nameMaxLength else {
            return
        }
        
        guard let iconName = accountIconName else {
            TBNotify.showCenterAlert(message: "Didn't choose a icon.")
            return
        }

        if let acc = self.account { // update
            acc.update(data: (name, budget, iconName))
            if acc.isDefault != defaultSwitch.isOn { // need to change
                if defaultSwitch.isOn {
                    AccountService.shared.setDefaultAccount(bookId: acc.bookId, accountId: acc.id)
                } else {
                    AccountService.shared.resetDefaultAccount(bookId: acc.bookId, accountId: acc.id)
                }
            }
        } else { // insert
            if let book = BookService.shared.currentOpenBook {
                AccountService.shared.insertNewAccount(bookId: book.id, name: name, budget: budget, iconName: iconName) { (newAcc) in
                    if self.defaultSwitch.isOn {
                        AccountService.shared.setDefaultAccount(bookId: newAcc.bookId, accountId: newAcc.id)
                    }
                }
            }
            
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: delete
    @IBAction func deleteButtonClicked() {
        guard let acc = self.account else {
            return
        }
        
        // at least one account
        if AccountService.shared.cache.count == 1 {
            TBNotify.showCenterAlert(message: "You need at least one account.")
            return
        }
        
        TBNotify.showCenterAlert(message: "Are you sure you want to delete this account?", note: "All the records of this account will be delete!", confirm: true) {
            AccountService.shared.deleteAccount(accountId: acc.id)
            self.navigationController?.popViewController(animated: true)
            TBFeedback.notificationOccur(.warning)
            TBNotify.dismiss()
        }
    }
    
    private func setAccountInfo() {
        guard let acc = self.account else {
            return
        }
        nameTextField.text = acc.name
        budget = acc.budget
        defaultSwitch.setOn(acc.isDefault, animated: false)
        accountIconName = acc.iconImageName
        deleteButton.isHidden = false
    }
    
    @IBAction func openBudgetCalculator() {
        TBNotify.showCalculator(on: self, originalAmount: budget, currencyCode: currencyCode)
    }
}
 
// MARK: extension
extension AccountDetailViewController: UITextFieldDelegate {
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= nameMaxLength
    }
    
    // update name text
    func textFieldDidEndEditing(_ textField: UITextField) {
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
}

extension AccountDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Icons.accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: IconsCollectionViewCell<String>.self), for: indexPath) as? IconsCollectionViewCell<String> {
            let iconName = Icons.accounts[indexPath.row]
            cell.item = iconName
            cell.setupIconViews(imageName: iconName)
            cell.selectedColor = TBColor.system.veronese
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? IconsCollectionViewCell<String> {
            
            // 若已有選擇的category，且不為同個cell，移除選擇。
            if let currentCell = currentIconCell, currentIconCell != cell {
                currentCell.itemIsSelected = false
            }
            cell.itemIsSelected = !cell.itemIsSelected
            if cell.itemIsSelected { // selected category
                currentIconCell = cell
                accountIconName = cell.item
            } else { // remove selected
                currentIconCell = nil
                accountIconName = nil
            }
        }
    }
}

// MARK: CalculatorDelegate
extension AccountDetailViewController: CalculatorDelegate {
    func changeTransactionType(type: TransactionType) {}
    
    func changeAmountValue(amountStr: String) {
        var amount = Double(amountStr) ?? 0
        amount.turnToPositive()
        self.budget = amount
    }
}
