//
//  Notice.swift
//  SwiftEntryKitTest
//
//  Created by 阿遠 on 2020/10/12.
//

import UIKit
import SwiftEntryKit

enum NoticeType {
    case topToast
    case centerAlert
    case accountPicker
}

enum Result {
    case success
    case failed
}

let AccountPickerAttributes = "AccountPickerAttributes"
let CalculatorAttributes = "CalculatorAttributes"

struct TBNotify {
        
    static let alertEntranceAnimation: EKAttributes.Animation = {
        let animation: EKAttributes.Animation = .init(
            scale: .init(
                from: 0.8,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 0.8, initialVelocity: 0)
            ),
            fade: .init(
                from: 0,
                to: 1,
                duration: 0.3
            )
        )
        return animation
    }()
    
    static let alertExitAnimation: EKAttributes.Animation = {
        let animation: EKAttributes.Animation = .init(
            scale: .init(
                from: 1,
                to: 0.4,
                duration: 0.3,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            fade: .init(
                from: 1,
                to: 0,
                duration: 0.2
            )
        )
        return animation
    }()
    
    static var topToastAttributes: EKAttributes = {
        var attributes = EKAttributes.topToast
        attributes.entryBackground = .color(color: .white)
        attributes.displayDuration = .infinity
        
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 10, offset: .init(width: 5, height: 5)))
        attributes.roundCorners = .all(radius: 10)
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.9)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.3)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.popBehavior = .animated(animation: .translation)
        let edgeWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        return attributes
    }()
    
    static var centerFloatAttributes: EKAttributes = {
        var attributes = EKAttributes.centerFloat
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.65)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.25)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.entranceAnimation = alertEntranceAnimation
        attributes.exitAnimation = alertExitAnimation
        
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 5
            )
        )
        let edgeWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        
        return attributes
    }()
    
    

    
    
//
//    static func show(_ noticeType: NoticeType, completion: ((_ result: Result, _ value: Any?) -> ())? = nil) {
//        let view = UIView()
////        view.layer.cornerRadius = 10
//        view.backgroundColor = .white
//        switch noticeType {
//        case .topToast:
//            SwiftEntryKit.display(entry: view, using: topToastAttributes)
//            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
//                UIView.animate(withDuration: 0.2) {
//                    view.backgroundColor = .systemPink
//                }
//            }
//            _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
//                UIView.animate(withDuration: 0.2) {
//                    SwiftEntryKit.dismiss()
//                }
//            }
//            break
//        case .centerAlert:
//            SwiftEntryKit.display(entry: view, using: centerFloatAttributes)
//            break
//        case .accountPicker:
//            showAccountPicker { (result, account) in
//                completion?(result, account)
//            }
//        }
//    }
    

    static func showCenterAlert(message: String) {
        let attributes = centerFloatAttributes
        let view = UIView()
        view.roundedCorners()
        view.backgroundColor = TBColor.darkGary
        
        let MessageView = UIView()
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        MessageView.addSubview(messageLabel)
        messageLabel.fillSuperview(padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(fontSize: .medium),
            color: .standardContent
        )
        
        let closeButtonLabel = EKProperty.LabelContent(
            text: "Okay",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.standardBackground.with(alpha: 0.2)) {
                SwiftEntryKit.dismiss()
            }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton,
            separatorColor: EKColor.init(TBColor.gary),
            expandAnimatedly: true
        )
        let buttonBarView = EKButtonBarView(with: buttonsBarContent)
        
        view.addSubview(MessageView)
        view.addSubview(buttonBarView)
        MessageView.anchorSuperViewTop()
        MessageView.anchorSuperViewLeading()
        MessageView.anchorSuperViewTrailing()
        buttonBarView.anchorViewOnBottom()
        buttonBarView.roundedForButtonBarView()
        buttonBarView.topAnchor.constraint(equalTo: MessageView.bottomAnchor).isActive = true
        
        SwiftEntryKit.display(entry: view, using: attributes)
    }
    
    static func showCalculator(on parentController: UIViewController) {
        guard !SwiftEntryKit.isCurrentlyDisplaying(entryNamed: CalculatorAttributes) else {
            return
        }
        var attributes = EKAttributes.bottomToast
        attributes.name = CalculatorAttributes
        attributes.entranceAnimation = alertEntranceAnimation
        attributes.exitAnimation = alertExitAnimation
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        let heightRatio: CGFloat = 0.5
        let height = EKAttributes.PositionConstraints.Edge.ratio(value: heightRatio)
        attributes.positionConstraints.size.height = height
        attributes.entryBackground = .color(color: EKColor.init(TBColor.gary))
        let calculatorVC = CalculatorViewController()
        if let vc = parentController as? RecordDetailViewController {
            // start calculate at positive number
            var originValue = vc.recordAmount
            originValue.turnToPositive()
            calculatorVC.numberOnScreen = originValue
            calculatorVC.delegate = parentController as? CalculatorDelegate
        }
        calculatorVC.viewRatio = heightRatio
        SwiftEntryKit.display(entry: calculatorVC, using: attributes)        
    }
        
    static func showAccountPicker(currentAccount: Account? = nil, completion: @escaping ((_ result: Result, _ Account: Account?) -> ())) {
        let accountPickerVC = AccountPickerViewController()
        accountPickerVC.currentAccount = currentAccount
        accountPickerVC.isForPicker = true
        var attributes = centerFloatAttributes
        attributes.hapticFeedbackType = .none
        attributes.name = AccountPickerAttributes
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.6)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        
        let mediumFont = MainFont.regular.with(fontSize: .medium)
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: mediumFont,
            color: .standardContent
        )
        let closeButtonLabel = EKProperty.LabelContent(
            text: "Cancel",
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.standardBackground.with(alpha: 0.2)) {
                SwiftEntryKit.dismiss()
                completion(Result.failed, nil)
            }
        
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: mediumFont,
            color: EKColor.black
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "Okay",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.init(TBColor.darkGary)) {
            if let acc = accountPickerVC.currentAccount {
                SwiftEntryKit.dismiss()
                completion(Result.success, acc)
            } else {
                systemNotice(on: accountPickerVC, message: "You didn't select a account!")
            }
            
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: EKColor(TBColor.darkGary),
            horizontalDistributionThreshold: 2,
            expandAnimatedly: true
        )

        let buttonBarView = EKButtonBarView(with: buttonsBarContent)
        buttonBarView.roundedForButtonBarView()
        accountPickerVC.buttonView.addSubview(buttonBarView)
        buttonBarView.fillSuperview()
        SwiftEntryKit.display(entry: accountPickerVC, using: attributes)
    }

    static func dismiss(name: String? = nil) {
        if let name = name {
            if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: name) {
                SwiftEntryKit.dismiss(.specific(entryName: name))
            }
        } else {
            SwiftEntryKit.dismiss()
        }
    }
    
    static private func systemNotice(on controller: UIViewController, message: String) {
        let alertController = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction.init(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}

extension EKButtonBarView {
    func roundedForButtonBarView(radius: CGFloat = 10, shadow: Bool = false) {
        self.roundedCorners(radius: radius, shadow: shadow, roundedType: .bottom)
        self.clipsToBounds = true
    }
}
