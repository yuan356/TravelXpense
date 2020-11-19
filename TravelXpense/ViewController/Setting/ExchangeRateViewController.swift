//
//  ExchangeRateViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/10.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let itemHeight: CGFloat = 60
fileprivate let textFont: UIFont = MainFont.regular.with(fontSize: .medium)
fileprivate let textColor: UIColor = TXColor.gray.light

class ExchangeRateViewController: TXViewController {

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
        $0.setTitle(NSLocalizedString("Update now", comment: "Update now"), for: .normal)
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
        
        dataTimeLabel.text = TXFunc.convertDateToDateStr(date: RateService.shared.dataTime, fullFormat: true)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoUpdateRate.rawValue) {
            autoUpdateSwitch.setOn(true, animated: false)
        } else {
            autoUpdateSwitch.setOn(false, animated: false)
        }
    }

    private func setViews() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: TXNavigationIcon.exchange.rawValue)
        imageView.tintColor = TXColor.gray.medium
        
        self.view.addSubview(imageView)
        imageView.anchorSize(h: 130, w: 130)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil)
        imageView.anchorCenterX(to: view)
        
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, title: NSLocalizedString("Update time", comment: "Update time"), object: dataTimeLabel))
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, title: NSLocalizedString("Auto update", comment: "Auto update"), object: autoUpdateSwitch))
        
        self.view.addSubview(vStackView)
        vStackView.anchor(top: imageView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8))
        
        self.view.addSubview(updateButton)
        updateButton.setAutoresizingToFalse()
        updateButton.anchorCenterX(to: view)
        updateButton.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 20).isActive = true
    }
    
    @IBAction func updateClicked() {
        showBlockingView()
        RateService.shared.getNewData {
            DispatchQueue.main.async {
                self.hideBlockingView()
                self.dataTimeLabel.text = TXFunc.convertDateToDateStr(date: RateService.shared.dataTime, fullFormat: true)
                TXAlert.showTopAlert(message: NSLocalizedString("Update succeed", comment: "Update succeed"))
            }
        }
    }
    
    @IBAction func autoUpdateChange() {
        let auto = autoUpdateSwitch.isOn
        UserDefaults.standard.set(auto, forKey: UserDefaultsKey.autoUpdateRate.rawValue)
    }
    
    
}
