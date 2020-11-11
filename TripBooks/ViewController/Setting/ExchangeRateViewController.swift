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
fileprivate let textColor: UIColor = TBColor.gray.light

class ExchangeRateViewController: UIViewController {

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
        $0.backgroundColor = TBColor.gray.medium
        $0.layer.cornerRadius = $0.frame.height / 2
        $0.onTintColor = TBColor.system.veronese
        $0.addTarget(self, action: #selector(autoUpdateChange), for: .touchUpInside)
    }
    
    lazy var updateButton = UIButton {
        $0.setTitle("Update now", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.setTitleColor(TBColor.gray.medium, for: .highlighted)
        $0.backgroundColor = TBColor.system.veronese
        $0.roundedCorners()
        $0.anchorSize(h: 43, w: 170)
        $0.addTarget(self, action: #selector(updateClicked), for: .touchUpInside)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TBColor.background()
        setViews()
        
        dataTimeLabel.text = TBFunc.convertDateToDateStr(date: RateService.shared.dataTime, full: true)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.autoUpdateRate.rawValue) {
            autoUpdateSwitch.setOn(true, animated: false)
        } else {
            autoUpdateSwitch.setOn(false, animated: false)
        }
    }

    private func setViews() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: TBNavigationIcon.exchange.rawValue)
        imageView.tintColor = .white
        
        self.view.addSubview(imageView)
        imageView.anchorSize(h: 150, w: 150)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil)
        imageView.anchorCenterX(to: view)
        
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, title: "Data  time", object: dataTimeLabel))
        vStackView.addArrangedSubview(EditInfoView(viewheight: itemHeight, title: "Auto update", object: autoUpdateSwitch))
        
        self.view.addSubview(vStackView)
        vStackView.anchor(top: imageView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8))
        
        self.view.addSubview(updateButton)
        updateButton.setAutoresizingToFalse()
        updateButton.anchorCenterX(to: view)
        updateButton.topAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 20).isActive = true
    }
    var blockingViewController: BlockingViewController?
    @IBAction func updateClicked() {
        showBlockingView()
        RateService.shared.getNewData {
            DispatchQueue.main.async {
                self.hideBlockingView()
                self.dataTimeLabel.text = TBFunc.convertDateToDateStr(date: RateService.shared.dataTime, full: true)
            }
        }
    }
    
    @IBAction func autoUpdateChange() {
        let auto = autoUpdateSwitch.isOn
        UserDefaults.standard.set(auto, forKey: UserDefaultsKey.autoUpdateRate.rawValue)
    }
    
    func showBlockingView() {
        self.blockingViewController = BlockingViewController()
        if let controller = self.blockingViewController {
            self.view.addSubview(controller.view)
            controller.view.fillSuperview()
            self.addChild(controller)
            UIView.animate(withDuration: 0.3) {
                controller.showView()
            }
        }
    }
    
    func hideBlockingView() {
        if let controller = self.blockingViewController {
            UIView.animate(withDuration: 0.3, animations: {
                controller.hideView()
            }) { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.blockingViewController = nil
            }
        }
    }
}
