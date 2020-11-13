//
//  GenericTableViewController.swift
//  LBTASimpleListControllers
//
//  Created by Brian Voong on 1/29/18.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import UIKit

class GenericCell<U>: UITableViewCell {
    
    var item: U!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {}
    
    let arrowView = UIImageView()
    
    /// size h: 16, w: 16, tailing: 8
    func addRightArrow() {
        arrowView.image = UIImage(named: TBNavigationIcon.arrowRight.rawValue)
        arrowView.anchorSize(h: 16, w: 16)
        arrowView.tintColor = .white
        self.contentView.addSubview(arrowView)
        arrowView.anchorCenterY(to: contentView)
        arrowView.anchorSuperViewTrailing(padding: 8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GenericTableViewController<T: GenericCell<U>, U>: UITableViewController {
    
    var items = [U]()
    
    lazy var selectedView = UIView {
        $0.backgroundColor = TBColor.system.blue.light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reuseIdentifier = NSStringFromClass(T.self)
        tableView.register(T.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = NSStringFromClass(T.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
        cell.item = items[indexPath.row]
        cell.selectedBackgroundView = selectedView
        return cell
    }
}
