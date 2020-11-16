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
    
    lazy var updateButton = TXButton {
        $0.setTitle(NSLocalizedString("Backup now", comment: "Backup now"), for: .normal)
        $0.backgroundColor = TXColor.system.veronese
        $0.setFont(font: MainFont.medium.with(fontSize: .medium))
        $0.setBackgroundColor(color: TXColor.system.veroneseDrak, forState: .highlighted)
        $0.roundedCorners()
        $0.anchorSize(h: 43, w: 170)
        $0.addTarget(self, action: #selector(updateClicked), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = TXColor.background()
        setViews()
        
        dataTimeLabel.text = TXFunc.convertDateToDateStr(date: RateService.shared.dataTime, full: true)
        
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
        
        self.view.addSubview(updateButton)
        updateButton.setAutoresizingToFalse()
        updateButton.anchorCenterX(to: view)
        updateButton.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 20).isActive = true
    }
    
    @IBAction func updateClicked() {
        // 確保已登入
        guard let user = AuthService.currentUser else {
            return
        }
        let userUId = user.uid
        print(userUId)
        
        // 產生一個貼文的唯一ID 並準備backuplog Database 的參照
        let backupLogRef = FirebaseService.shared.BACKUPLOG_DB_REF.child("\(userUId)")

        let dbFileUrl = URL(fileURLWithPath: DBManager.shared.pathToDatabase)
        let storgeRef = FirebaseService.shared.DBFILE_STORAGE_REF.child("\(userUId).sqlite")
        
        let uploadTask = storgeRef.putFile(from: dbFileUrl, metadata: nil) { metadata, error in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            print("Error1")
            return
          }
            
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
            print("size: ", size)
          // You can also access to download URL after upload.
            storgeRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
                print("Error2")
              return
            }
                
            // store the backup log to database
            let fileUrl = downloadURL.absoluteString
            let timestamp = Date().timeIntervalSince1970
            let log: [String : Any] = ["backupUrl" : fileUrl, "timestamp" : timestamp]
            backupLogRef.setValue(log)
            print("downloadURL: ", downloadURL)
          }
        }
        
        uploadTask.observe(.success) { (snapshot) in // 執行上傳成功後的操作
            print(snapshot)
        }
    }
    
    
    @IBAction func autoUpdateChange() {
        let auto = autoUpdateSwitch.isOn
        UserDefaults.standard.set(auto, forKey: UserDefaultsKey.autoUpdateRate.rawValue)
    }
    
}
