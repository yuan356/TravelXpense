//
//  BackupViewController.swift
//  TravelXpense
//
//  Created by 阿遠 on 2020/11/16.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit
import Network

fileprivate let itemHeight: CGFloat = 60
fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let textColor: UIColor = TXColor.gray.light

class BackupViewController: TXViewController {

    let monitor = NWPathMonitor()
    
    var networkConnected = true
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.axis = .vertical
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
        $0.addTarget(self, action: #selector(backupClicked), for: .touchUpInside)
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
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoBackup.rawValue) {
            autoUpdateSwitch.setOn(true, animated: false)
        } else {
            autoUpdateSwitch.setOn(false, animated: false)
        }
        
        if let timestamp = BackupService.shared.backupTimestamp {
           let dateStr = TXFunc.convertDoubleToDateStr(timeStamp: timestamp, fullFormat: true)
            dataTimeLabel.text = dateStr
        } else {
            restoreButton.isHidden = true
        }
        
        monitor.pathUpdateHandler = { path in
              self.networkConnected = path.status == .satisfied
           }
        monitor.start(queue: DispatchQueue.global())
        
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
    
    @IBAction func backupClicked() {
        guard networkConnected else {
            TXAlert.showCenterAlert(message: NSLocalizedString("Network error", comment: "Network error"))
            return
        }
        
        TXAlert.showCenterAlert(message: NSLocalizedString("Are you sure you want to back up current data?", comment: "Are you sure you want to back up current data?"), note: NSLocalizedString("Old backup will be overridden", comment: "Old backup will be overridden"), confirm: true) {
            TXAlert.dismiss()
            self.showBlockingView()
            BackupService.shared.backupSQLite { (result) in
                self.hideBlockingView()
                if result == .success {
                    if let timestamp = BackupService.shared.backupTimestamp {
                       let dateStr = TXFunc.convertDoubleToDateStr(timeStamp: timestamp, fullFormat: true)
                        self.dataTimeLabel.text = dateStr
                        self.restoreButton.isHidden = false
                        TXAlert.showTopAlert(message: NSLocalizedString("Backup completed", comment: "Backup completed"))
                    }
                }
            }
        }
    }
    
    @IBAction func restore() {
        
        guard networkConnected else {
            TXAlert.showCenterAlert(message: NSLocalizedString("Network error", comment: "Network error"))
            return
        }
        
        TXAlert.showCenterAlert(message: NSLocalizedString("Are you sure you want to restore the backup?", comment: "Are you sure you want to restore the backup?"), note: NSLocalizedString("Old data will be deleted, please confirm", comment: "Old data will be deleted, please confirm"), confirm: true) {
                TXAlert.dismiss()
                self.showBlockingView()
                BackupService.shared.restoreBackup { (result) in
                    TXObserved.notifyObservers(notificationName: .bookTableReload, infoKey: nil, infoValue: nil)
                    self.hideBlockingView()
                    if result == .success {
                        TXAlert.showTopAlert(message: NSLocalizedString("Restore completed", comment: "Restore completed"))
                    }
                }
        }
    }
    
    
    @IBAction func autoUpdateChange() {
        let auto = autoUpdateSwitch.isOn
        UserDefaults.standard.set(auto, forKey: UserDefaultsKey.autoBackup.rawValue)
    }
}
