//
//  RecordDetailViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

let headerHeight: CGFloat = 60
let checkButtonHeight: CGFloat = 30

class RecordDetailViewController: UIViewController {

    var record: Record?
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.anchorSize(height: headerHeight)
        
        let checkButton = UIButton()
        checkButton.setImage(UIImage(named: "check"), for: .normal)
        view.addSubview(checkButton)
        checkButton.anchor(top: view.topAnchor, bottom: nil, leading: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 15))
        checkButton.anchorSize(height: checkButtonHeight)
        checkButton.widthAnchor.constraint(equalTo: checkButton.heightAnchor).isActive = true
        checkButton.addTarget(self, action: #selector(saveButtonClicked(_:)), for: .touchUpInside)
        
        return view
    }()
    
    let detailTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.addSubview(headerView)
        headerView.anchor(top: self.view.topAnchor, bottom: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        
        self.view.addSubview(detailTableView)
        detailTableView.anchor(top: headerView.bottomAnchor, bottom: self.view.bottomAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
        detailTableView.dataSource = self
        detailTableView.delegate = self
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        print("saveButtonClicked")
    }

}


extension RecordDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordDetailCellRow.value(.LAST)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = RecordDetailCellRow.init(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = RecordDetailCell.createCell(type: rowType)

        return cell
    }
    
    
}
