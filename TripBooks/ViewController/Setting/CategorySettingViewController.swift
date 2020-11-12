//
//  CategorySettingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/6.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

class CategorySettingViewController: UIViewController {
        
    lazy var controlBar = UIView {
        $0.anchorSize(h: 50)
    }
    
    lazy var selectedView = UIView {
        $0.backgroundColor = TBColor.system.blue.light
    }
    
    lazy var expenseTB = UITableView()
        
    var categories: [Category] = CategoryService.shared.expenseCategories
    
    lazy var addButton: UIButton = {
        let btn = TBNavigationIcon.plus.getButton()
        btn.anchorSize(h: 23, w: 23)
        btn.addTarget(self, action: #selector(addAccountClicked), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.background()
        
        // navigationItem
        self.navigationItem.backButtonTitle = ""
        let addBarItem = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = addBarItem
        
//        self.view.addSubview(controlBar)
//        controlBar.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
//        setSegmentedControl()
        setTableView()
    }
    
    private func setTableView() {
        expenseTB.backgroundColor = .clear
        expenseTB.delegate = self
        expenseTB.dataSource = self
        expenseTB.register(CategoryCell.self, forCellReuseIdentifier: String(describing: CategoryCell.self))
        
        self.view.addSubview(expenseTB)
        expenseTB.fillSuperview()
    }
    
//    private func setSegmentedControl() {
//        let items = ["Expense", "Income"]
//        let customSC = UISegmentedControl(items: items)
//        controlBar.addSubview(customSC)
//        customSC.anchorToSuperViewCenter()
//        customSC.backgroundColor = TBColor.system.blue.light
//        customSC.selectedSegmentIndex = 0
//        customSC.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        categories = CategoryService.shared.expenseCategories
        expenseTB.reloadData()
    }

    
    @IBAction func addAccountClicked() {
        let vc = CategoryDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    @IBAction func changePage(_ control: UISegmentedControl) {
//        switch (control.selectedSegmentIndex) {
//              case 0:
//                expenseTB.isHidden = false
//                incomeTB.isHidden = true
//              case 1:
//                expenseTB.isHidden = true
//                incomeTB.isHidden = false
//              default: break
//           }
//    }
}

extension CategorySettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryCell.self), for: indexPath) as? CategoryCell {
            cell.item = categories[indexPath.row]
            cell.selectedBackgroundView = selectedView
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CategoryDetailViewController()
        vc.category = categories[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class CategoryCell: GenericInfoCell<Category> {
    override var item: Category! {
        didSet {
            titleLabel.text = item.title
        }
    }
    
    override func setViewsDetail() {
        super.setViewsDetail()
        self.addRightArrow()
        titleLabel.textColor = .white
    }
    
    override func setIconImage() {
        iconImageName = item.iconImageName
        iconColorHex = item.colorHex
        super.setIconImage()
    }
}
