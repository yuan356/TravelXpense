//
//  BackupViewController.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit


fileprivate let itemHeight: CGFloat = 60
fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let textColor: UIColor = TXColor.gray.light

class BackupViewController: TXViewController {

    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.axis = .vertical
    }
    
    var backupTimestampe: Double? {
        didSet {
            dataTimeLabel.text = TXFunc.convertDoubleTimeToDateStr(timeStamp: backupTimestampe!, fullFormat: true)
        }
    }
    
    lazy var dataTimeLabel = UILabel {
        $0.textColor = textColor
        $0.font = textFont
        $0.textAlignment = .right
    }
    
    lazy var autoUpdateSwitch = UISwitch {
        $0.tintColor = .red
        $0.backgroundColor = TXColor.gray.medium
        $0.layer.cornerRadius = $0.frame.height / 2
        $0.onTintColor = TXColor.system.veronese
        $0.addTarget(self, action: #selector(autoUpdateChange), for: .touchUpInside)
    }
    
    lazy var backupButton = TXButton {
        $0.setTitle(NSLocalizedString("Backup now", comment: "Backup now"), for: .normal)
        $0.backgroundColor = TXColor.system.veronese
        $0.setFont(font: MainFont.medium.with(fontSize: .medium))
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.roundedCorners()
        $0.anchorSize(h: 40, w: 160)
        $0.addTarget(self, action: #selector(updateClicked), for: .touchUpInside)
    }
    
    lazy var restoreButton = TXButton {
        $0.setTitle(NSLocalizedString("Restore", comment: "Restore"), for: .normal)
        $0.backgroundColor = TXColor.orange.light
        $0.setFont(font: MainFont.medium.with(fontSize: .medium))
        $0.setBackgroundColor(color: TXColor.orange.dark, forState: .highlighted)
        $0.roundedCorners()
        $0.anchorSize(h: 40, w: 160)
        $0.addTarget(self, action: #selector(restore), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = TXColor.background()
        setViews()
        
        dataTimeLabel.text = TXFunc.convertDateToDateStr(date: RateService.shared.dataTime, fullFormat: true)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoUpdateRate.rawValue) {
            autoUpdateSwitch.setOn(true, animated: false)
        } else {
            autoUpdateSwitch.setOn(false, animated: false)
        }
        
    }
    
    private func setViews() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: TXNavigationIcon.cloud.rawValue)
        imageView.tintColor = TXColor.gray.medium
        
        self.view.addSubview(imageView)
        imageView.anchorSize(h: 120, w: 120)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil)
        imageView.anchorCenterX(to: view)
        
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, titleWidth: 150, title: NSLocalizedString("Last backup time", comment: "Last backup time"), object: dataTimeLabel))
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, title: NSLocalizedString("Auto backup", comment: "Auto backup"), object: autoUpdateSwitch))
        
        self.view.addSubview(vStackView)
        vStackView.anchor(top: imageView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8))
        
        self.view.addSubview(backupButton)
        backupButton.setAutoresizingToFalse()
        backupButton.anchorCenterX(to: view)
        backupButton.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 20).isActive = true
        
        self.view.addSubview(restoreButton)
        restoreButton.setAutoresizingToFalse()
        restoreButton.anchorCenterX(to: view)
        restoreButton.topAnchor.constraint(equalTo: backupButton.bottomAnchor, constant: 20).isActive = true
    }
    
    @IBAction func updateClicked() {
        showBlockingView()
        FirebaseService.shared.backupSQLite { (result, timestamp) in
            if result == .success {
                self.hideBlockingView()
                if let timestamp = timestamp {
                    self.backupTimestampe = timestamp
                }
            }
        }
    }
    
    @IBAction func restore() {
//        showBlockingView()
        FirebaseService.shared.getBackupLog()
    }
    
    
    @IBAction func autoUpdateChange() {
        let auto = autoUpdateSwitch.isOn
        UserDefaults.standard.set(auto, forKey: UserDefaultsKey.autoUpdateRate.rawValue)
    }
    

    
}
