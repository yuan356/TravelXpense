//
//  RecordDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum RecordDetailCellRow: Int {
    case amount = 0
    case title
    case category
    case account
    case date
    case note
    case LAST
    
    static func value(_ value: RecordDetailCellRow) -> Int {
        return value.rawValue
    }
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let paddingInCategoriesCollectionView: CGFloat = 8
fileprivate let spacingInVStack: CGFloat = 8

// Height
fileprivate let heightForHeader: CGFloat = 50
fileprivate let heightForCheckButton: CGFloat = 25
fileprivate let collectionViewCellWidth: CGFloat = 60
fileprivate let collectionViewCellHeight: CGFloat = 60
// let heightForDetailCell: CGFloat = 60
fileprivate let heightForCategoryView: CGFloat = 144

//  detail
fileprivate let heightForDetailView: CGFloat = 45
fileprivate let heightForAmountView: CGFloat = 80
fileprivate let heightForNoteView: CGFloat = 150

// cornerRadius
private let cornerRadius: CGFloat = 10

private let categoryCell = "CategoryCell"

class RecordDetailViewController: UIViewController {

    var record: Record?
    
    var recordDay: Date?
    
    var categories: [Category] {
        return CategoryService.shared.categories
    }
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.anchorSize(height: heightForHeader)
        
        let checkButton = UIButton()
        checkButton.setImage(UIImage(named: "check"), for: .normal)
        view.addSubview(checkButton)
        checkButton.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 15))
        checkButton.anchorSize(height: heightForCheckButton)
        checkButton.widthAnchor.constraint(equalTo: checkButton.heightAnchor).isActive = true
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
        textField.font = UIFont.systemFont(ofSize: 30)
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        return textField
    }()
    
    let categoriesView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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
        stackView.anchorSize(height: (heightForDetailView * 2) + heightForNoteView + (spacingInVStack * 3))
        return stackView
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textAlignment = .right
        return textField
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    let noteTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.textAlignment = .right
        return textField
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#3F9E64")
        button.setTitle("DONE", for: .normal)
        button.tintColor = .white
        button.anchorSize(height: 50)
        button.roundedCorners(radius: cornerRadius)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setContentViewAndHeader()
        
        setAmountTextField()
        
        setCategoryView()
        
        setVStackView()
        
        self.contentView.addSubview(doneButton)
        doneButton.anchor(top: nil, bottom: self.contentView.safeAreaLayoutGuide.bottomAnchor, leading: self.contentView.leadingAnchor, trailing: self.contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))
        doneButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        print("saveButtonClicked")
    }
    
    private func setContentViewAndHeader() {
        self.view.backgroundColor = .darkGray
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(contentView)
        contentView.anchor(top: headerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }

    private func setAmountTextField() {
        contentView.addSubview(amountView)
        amountView.anchor(top: contentView.topAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        
        amountView.addSubview(amountTextField)
        amountTextField.fillSuperview(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    // MARK: categoryView setting
    private func setCategoryView() {
        self.contentView.addSubview(categoriesView)
        categoriesView.anchor(top: amountView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))
        
        categoriesCollectionView = initCategoriesCollectionView()
        self.categoriesView.addSubview(categoriesCollectionView)
        categoriesCollectionView.fillSuperview()

    }
    
    private func initCategoriesCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let pd = paddingInCategoriesCollectionView
        let width = UIScreen.main.bounds.width - (paddingInContentView + pd) * 2
        layout.itemSize = CGSize(width: width, height: 120)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = pd * 2
        layout.sectionInset = UIEdgeInsets(top: pd, left: pd, bottom: pd, right: pd)
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .darkGray
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CategoriesCollectionViewCell.self, forCellWithReuseIdentifier: categoryCell)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .red
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }
    
    // MARK: vStackView setting
    private func setVStackView() {
        contentView.addSubview(vStackView)
        vStackView.anchor(top: categoriesView.bottomAnchor, bottom: nil, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: 0, right: paddingInContentView))
        

        let titleView = UIView()
        titleView.backgroundColor = .lightGray
        titleView.anchorSize(height: heightForDetailView)
        setDetailView(name: "Title", to: titleView, type: .title)
        titleView.roundedCorners(radius: cornerRadius)

        let accountView = UIView()
        accountView.backgroundColor = .lightGray
        setDetailView(name: "Account", to: accountView, type: .account)
        accountView.roundedCorners(radius: cornerRadius)
        
        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.alignment = .fill
        hStackView.spacing = 10
        hStackView.addArrangedSubview(titleView)
        hStackView.addArrangedSubview(accountView)
        hStackView.anchorSize(height: heightForDetailView)
        
        let dateView = UIView()
        dateView.backgroundColor = .lightGray
        dateView.anchorSize(height: heightForDetailView)
        setDetailView(name: "Date", to: dateView, type: .date)
        dateView.roundedCorners(radius: cornerRadius)
        
        let noteView = UIView()
        noteView.backgroundColor = .lightGray
        setDetailView(name: "Note", to: noteView, type: .note)
        noteView.roundedCorners(radius: cornerRadius)
        
//        vStackView.addArrangedSubview(titleView)
//        vStackView.addArrangedSubview(getLineView())
        // ---
//        vStackView.addArrangedSubview(accountView)
//        vStackView.addArrangedSubview(getLineView())
        
        vStackView.addArrangedSubview(hStackView)
        // ---
        vStackView.addArrangedSubview(dateView)
//        vStackView.addArrangedSubview(getLineView())
        // ---
        vStackView.addArrangedSubview(noteView)
        
//        accountView.anchorSize(to: titleView)
//        dateView.anchorSize(to: titleView)
        noteView.anchorSize(height: heightForNoteView)
    }
    
    private func setDetailView(name: String, to view: UIView, type: RecordDetailCellRow) {
        var constraints = [NSLayoutConstraint]()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        view.addSubview(nameLabel)
        nameLabel.setAutoresizingToFalse()
        constraints.append(nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8))
        
        
        switch type {
        case .amount:
            break
        case .title:
            view.addSubview(titleTextField)
            titleTextField.delegate = self
            titleTextField.anchor(top: view.topAnchor, bottom: view.bottomAnchor, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
            constraints.append(titleTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 20))
        case .category:
            break
        case .account:
            break
        case .note:
            noteTextField.delegate = self
            break
        case .date:
            view.addSubview(dateLabel)
            if let date = self.recordDay {
                dateLabel.text = Func.convertDateToDateStr(date: date)
            }
            dateLabel.anchor(top: view.topAnchor, bottom: view.bottomAnchor, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
            constraints.append(dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 20))
            break
        case .LAST:
            break
        }
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func getLineView() -> UIView {
        let lineView = UIView()
        lineView.anchorSize(height: 1)
        lineView.backgroundColor = .darkGray
        return lineView
    }
    
}

extension RecordDetailViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
}



extension RecordDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let num = self.categories.count / 6
        let remain = self.categories.count % 6
        return num + (remain == 0 ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as? CategoriesCollectionViewCell {
            cell.num = indexPath.row
//            cell.categories = Array(self.categories[0...1])
            return cell
        }
        return UICollectionViewCell()
    }
}
