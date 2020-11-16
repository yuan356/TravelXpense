//
//  CategoryDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/7.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let textColor: UIColor = TXColor.gray.light

// height / width
fileprivate let heightForStackItem: CGFloat = 45
fileprivate let heightForCategoryView: CGFloat = 180
fileprivate let heightForColorsView: CGFloat = 90
// padding
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let paddingInVStack: CGFloat = 8

class CategoryDetailViewController: UIViewController {

    var category: Category! {
        didSet {
            setCategoryInfo()
        }
    }
    
    var currentIconCell: IconsCollectionViewCell<String>?
    
    var categoryIconName: String? {
        didSet {
            if let name = categoryIconName {
                iconView.changeImage(imageName: name, colorHex: categoryColor)
            }
        }
    }
    
    var categoryColor: String?
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = spacingInVStack
        $0.axis = .vertical
    }
    
    lazy var titleTextField = UITextField {
        $0.tintColor = .systemBlue
        $0.textAlignment = .right
        $0.font = textFont
        $0.textColor = textColor
        $0.delegate = self
    }
    
    lazy var saveButton = UIButton {
        $0.setTitle(NSLocalizedString("Save", comment: "Save"), for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 18)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(TXColor.gray.medium, for: .highlighted)
        $0.anchorSize(h: 35, w: 55)
        $0.roundedCorners()
        $0.backgroundColor = TXColor.system.blue.medium
        $0.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
    }
    
    lazy var deleteButton = UIButton {
        $0.setTitle(NSLocalizedString("Delete category", comment: "Delete category"), for: .normal)
        $0.roundedCorners()
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
        $0.anchorSize(h: 50)
        $0.setTitleColor(.white, for: .normal)
        $0.isHidden = true
        $0.backgroundColor = TXColor.delete.normal
        $0.setBackgroundColor(color: TXColor.delete.highlighted, forState: .highlighted)
    }
    
    lazy var iconView = IconView()
    
    var categoriesCollectionView: UICollectionView!
    
    lazy var categoriesView = UIView {
        $0.anchorSize(h: heightForCategoryView)
        $0.roundedCorners()
        $0.layer.borderWidth = 1
        $0.layer.borderColor = TXColor.gray.medium.cgColor
    }
    
    var colorsCollectionView: UICollectionView!
    
    lazy var colorsView = UIView {
        $0.anchorSize(h: heightForColorsView)
        $0.roundedCorners()
        $0.layer.borderWidth = 1
        $0.layer.borderColor = TXColor.gray.medium.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        setViews()
    }
    
    private func setViews() {
        let saveBarItem = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = saveBarItem
        setVStackView()
        setCategoryView()
        setColoresView()
        
        self.view.addSubview(deleteButton)
        deleteButton.anchor(top: colorsView.bottomAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
    }
    
    // MARK: setVStackView
    private func setVStackView() {
        var views = [UIView]()
        views.append(EditInfoView(viewheight: heightForStackItem, title: NSLocalizedString("Title", comment: "Title"), object: titleTextField))
        
        let iconBackView = UIView()
        iconBackView.addSubview(iconView)
        iconView.anchorCenterY(to: iconBackView)
        iconView.anchorSuperViewTrailing()
        views.append(EditInfoView(viewheight: heightForStackItem, title: NSLocalizedString("Icon", comment: "Icon"), object: iconBackView))
        
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
        categoriesCollectionView = initCollectionView()
        self.categoriesView.addSubview(categoriesCollectionView)
        categoriesCollectionView.fillSuperview()
        
        view.addSubview(categoriesView)
        categoriesView.anchor(top: vStackView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 0, right:15))

    }
    
    private func initCollectionView(forColor: Bool = false) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = forColor ? 32 : 43
        layout.itemSize = CGSize(width: width, height: width)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if forColor {
            collectionView.register(colorViewCell.self, forCellWithReuseIdentifier: String(describing: colorViewCell.self))
        } else {
            collectionView.register(IconsCollectionViewCell<String>.self, forCellWithReuseIdentifier: String(describing: IconsCollectionViewCell<String>.self))
        }
        
        return collectionView
    }
    
    private func setColoresView() {
        colorsCollectionView = initCollectionView(forColor: true)
        self.colorsView.addSubview(colorsCollectionView)
        colorsCollectionView.fillSuperview()
        
        view.addSubview(colorsView)
        colorsView.anchor(top: categoriesView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 0, right:15))
    }
    
    private func setCategoryInfo() {
        guard let cate = self.category else {
            return
        }
        titleTextField.text = cate.title
        categoryIconName = cate.iconImageName
        iconView.backgroundColor = UIColor(hex: cate.colorHex)
        categoryColor = cate.colorHex
        deleteButton.isHidden = false
    }
    
    // MARK: Save
    @IBAction func saveButtonClicked() {
        guard let title = titleTextField.text,
              title.count <= titleMaxLength else {
            return
        }
        
        guard let iconName = categoryIconName else {
            TXAlert.showCenterAlert(message: NSLocalizedString("You should choose an icon.", comment: "You should choose an icon."))
            return
        }
        
        guard let color = categoryColor else {
            TXAlert.showCenterAlert(message: NSLocalizedString("You should choose a color.", comment: "You should choose a color."))
            return
        }
        
        if let cate = self.category { // update
            CategoryService.shared.updateCategory(id: cate.id, title: title, colorCode: color, iconName: iconName)
        } else { // add
            CategoryService.shared.addNewCategory(title: title, colorCode: color, iconName: iconName)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Delete
    @IBAction func deleteButtonClicked() {
        guard let cate = category else {
            return
        }
        
        // at least one account
        if CategoryService.shared.expenseCache.count == 1 {
            TXAlert.showCenterAlert(message: NSLocalizedString("You need at least one category.", comment: "You need at least one category."))
            return
        }
        
        let count = RecordSevice.shared.getCountFromCategory(categoryId: cate.id)
        let countMsg = NSLocalizedString("This category have", comment: "This category") + " \(count) " + NSLocalizedString("records", comment: "records")
        
        let confirmMsg = NSLocalizedString("Are you sure you want to delete this category?", comment: "category delete confirm")
        let confirmNote = NSLocalizedString("All the records of this category will be delete", comment: "category delete note")
        
        TXAlert.showCenterAlert(message: confirmMsg + "\n" , title: countMsg,  note: confirmNote, confirm: true) {
            CategoryService.shared.deleteCategory(id: cate.id)
            self.navigationController?.popViewController(animated: true)
            TXFeedback.notificationOccur(.warning)
            TXAlert.dismiss()
        }
    }
    
}

fileprivate let titleMaxLength = 100
extension CategoryDetailViewController: UITextFieldDelegate {
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= titleMaxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension CategoryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorsCollectionView {
            return Icons.colorHex.count
        } else  {
            return Icons.categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorsCollectionView {
            if let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: colorViewCell.self), for: indexPath) as? colorViewCell {
                let hex = Icons.colorHex[indexPath.row]
                cell.colorHex = hex
                return cell
            }
        } else {
            if let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: IconsCollectionViewCell<String>.self), for: indexPath) as? IconsCollectionViewCell<String> {
                let iconName = Icons.categories[indexPath.row]
                cell.item = iconName
                cell.setupIconViews(imageName: iconName)
                cell.selectedColor = TXColor.system.veronese
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == colorsCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? colorViewCell {
                iconView.backgroundColor = UIColor(hex: cell.colorHex)
                categoryColor = cell.colorHex
            }
            
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? IconsCollectionViewCell<String> {
                // 若已有選擇的category，且不為同個cell，移除選擇。
                if let currentCell = currentIconCell, currentIconCell != cell {
                    currentCell.itemIsSelected = false
                }
                cell.itemIsSelected = !cell.itemIsSelected
                if cell.itemIsSelected { // selected category
                    currentIconCell = cell
                    categoryIconName = cell.item
                } else { // remove selected
                    currentIconCell = nil
                    categoryIconName = nil
                }
            }
        }
    }
}

class colorViewCell: UICollectionViewCell {
    var colorHex: String! {
        didSet {
            self.contentView.backgroundColor = UIColor(hex: colorHex)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.roundedCorners(radius: 8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
