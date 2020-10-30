//
//  AccountDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/29.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit


fileprivate let backgroundColor = TBColor.darkGary

// height / width
fileprivate let heightForStackItem: CGFloat = 50
fileprivate let heightForCategoryView: CGFloat = 180

// padding
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let paddingInVStack: CGFloat = 8

// font
fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let numberFont: UIFont = MainFontNumeral.medium.with(fontSize: .medium)
fileprivate let textColor: UIColor = TBColor.lightGary

class AccountDetailViewController: UIViewController {

    var account: Account! {
        didSet {
            print("setAccountInfo")
            setAccountInfo()
        }
    }
    
    var currentIconCell: IconsCollectionViewCell<String>?
    var accountIconName: String? {
        didSet {
            if let name = accountIconName {
//                let icon = IconView(imageName: name)
                if let icon = iconView as? IconView {
                    icon.changeImage(imageName: name)
                }
                
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.view.backgroundColor = backgroundColor
        setViews()
    }
    
    private func setViews() {
        setVStackView()
        setCategoryView()
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
    }
    
    var budget: Double! = 0.0 {
        didSet {
            budgetLabel.text = TBFunc.convertDoubleToStr(budget!, moneyFormat: true, currencyCode: currencyCode)
        }
    }
    
    lazy var budgetButton = UIButton {
        $0.addTarget(self, action: #selector(openBudgetCalculator), for: .touchUpInside)
    }
    
    lazy var categoriesView = UIView {
        $0.anchorSize(h: heightForCategoryView)
        $0.roundedCorners()
        $0.layer.borderWidth = 1
        $0.layer.borderColor = TBColor.lightGary.cgColor
    }
    
    var categoriesCollectionView: UICollectionView!

    lazy var iconView = IconView()
    
    private func setVStackView() {
        var views = [UIView]()
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Name", object: nameTextField))
        views.append(EditInfoView(viewheight: heightForStackItem, title: "Budget", object: budgetLabel, withButton: budgetButton))
        
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
        categoriesView.anchor(top: vStackView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 8, bottom: 0, right: 8))
    }
    
    private func initCategoriesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()

        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IconsCollectionViewCell<String>.self, forCellWithReuseIdentifier: String(describing: IconsCollectionViewCell<String>.self))
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }
    
    private func setAccountInfo() {
        nameTextField.text = account.name
        budget = account.budget
        accountIconName = account.iconImageName
    }
    
    @IBAction func openBudgetCalculator() {
        print("openBudgetCalculator")
        TBNotify.showCalculator(on: self, originalAmount: budget, currencyCode: currencyCode)
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
    func finishCalculate() { // update book budget
//        saveData(field: .budget, value: self.bookBudget)
    }
    
    func changeTransactionType(type: TransactionType) {}
    
    func changeAmountValue(amountStr: String) {
        var amount = Double(amountStr) ?? 0
        amount.turnToPositive()
        self.budget = amount
    }
}
