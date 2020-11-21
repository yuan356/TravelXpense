//
//  AboutViewController.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {

    lazy var versionLabel = UILabel {
        $0.font = MainFontNumeral.medium.with(fontSize: .medium)
        $0.textColor = TXColor.gray.medium
    }
    
    lazy var versionView = UIView {
        let logoLabel = UILabel {
            $0.font = MainFont.medium.with(fontSize: .large)
            $0.textColor = TXColor.gray.light
            $0.text = "TravelXpense"
        }
        
        $0.addSubview(logoLabel)
        logoLabel.anchorToSuperViewCenter()
        $0.addSubview(versionLabel)
        versionLabel.anchorCenterX(to: $0)
        versionLabel.anchorTopTo(to: logoLabel, padding: 15)
        $0.anchorSize(h: 180)
    }
    
    var tableView: AbountTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TXColor.background()

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "v " + appVersion
        }
        
        view.addSubview(versionView)
        versionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        tableView = AbountTableView()
        view.addSubview(tableView.view)
        self.addChild(tableView)
        tableView.view.anchor(top: versionView.bottomAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
    }
 
}

class AbountTableView: GenericTableViewController<AbountCell, String> {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        items = [NSLocalizedString("Website", comment: "Website")]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let url = URL(string: "http://travelxpense.co") {
                let safariController = SFSafariViewController(url: url)
                present(safariController, animated: true, completion: nil)
            }
        }
    }
}

class AbountCell: GenericCell<String> {
    override var item: String! {
        didSet {
            textLabel?.textColor = .white
            textLabel?.font = MainFont.regular.with(fontSize: .medium)
            textLabel?.text = item
        }
    }
    
    override func setupViews() {
        self.backgroundColor = .clear
    }
}
