//
//  SettingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/6.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

enum SetRows: Int {
    case category = 0
    case currency
    case exchangeRate
    case backup
    case about
    case LAST
    
    func value() -> Int {
        return rawValue
    }
    
    func str() -> String {
        switch self {
        case .currency:
            return NSLocalizedString("Currency", comment: "Currency")
        case .category:
            return NSLocalizedString("Category", comment: "Category")
        case .exchangeRate:
            return NSLocalizedString("Exchange Rate", comment: "Exchange Rate")
        case .backup:
            return NSLocalizedString("Backup", comment: "Backup")
        case .about:
            return NSLocalizedString("About", comment: "About")
        case .LAST:
            return ""
        }
    }
}

class SettingViewController: GenericTableViewController<settingCell, SetRows> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        self.navigationItem.title = NSLocalizedString("Setting", comment: "Setting")
        
        items = [SetRows.category, SetRows.currency, SetRows.exchangeRate,
                 SetRows.backup, SetRows.about]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    var myCurrnecy: Currency? {
        return RateService.shared.myCurrency
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = SetRows.init(rawValue: indexPath.row)
        switch row {
        case .category:
            self.navigationController?.pushViewController(CategorySettingViewController(), animated: true)
        case .currency:
            TXAlert.showPicker(type: .currency, currentObject: myCurrnecy) { (result, currency) in
                if result == .success, let currency = currency as? Currency {
                    RateService.shared.setMyCurrency(code: currency.code)
                    let cell = tableView.cellForRow(at: indexPath) as! settingCell
                    cell.detailLabel.text = currency.code
                }
            }
        case .exchangeRate:
            self.navigationController?.pushViewController(ExchangeRateViewController(), animated: true)
        case .backup:
            self.navigationController?.pushViewController(BackupViewController(), animated: true)
        default: break
        }
    }
    
    lazy var clearView = UIView {
        $0.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? settingCell {
            if SetRows.init(rawValue: indexPath.row) == .currency {
                cell.arrowView.isHidden = true
                if let currency = self.myCurrnecy {
                    cell.detailLabel.text = currency.code
                }
                cell.selectedBackgroundView = clearView
            }
            return cell
        }
        return cell
    }
    
}

class settingCell: GenericCell<SetRows> {
    
    lazy var detailLabel = UILabel {
        $0.textColor = TXColor.gray.light
        $0.font = MainFont.regular.with(fontSize: .medium)
    }
    
    override var item: SetRows! {
        didSet {
            textLabel?.textColor = .white
            textLabel?.text = item.str()
        }
    }
    
    override func setupViews() {
        self.backgroundColor = .clear
        self.addRightArrow()
        textLabel?.font = MainFont.regular.with(fontSize: .medium)
        
        self.addSubview(detailLabel)
        detailLabel.anchorCenterY(to: self)
        detailLabel.anchorSuperViewTrailing(padding: 15)
    }
}
