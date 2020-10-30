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

enum PickerResult {
    case success
    case failed
}

enum PickerType {
    case account
    case country
    case currency
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
            separatorColor: EKColor.init(TBColor.lightGary),
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
    
    static func showCalculator(on parentController: UIViewController, originalAmount: Double = 0, currencyCode: String, isForBudget: Bool = false) {
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
        var heightRatio: CGFloat = 0.45
        let height = EKAttributes.PositionConstraints.Edge.ratio(value: heightRatio)
   
        attributes.positionConstraints.size.height = height
        attributes.entryBackground = .color(color: EKColor.init(TBColor.lightGary))
        
        let calculatorVC = CalculatorViewController()
        var amount = originalAmount
        amount.turnToPositive()
        calculatorVC.numberOnScreen = amount
        calculatorVC.isForBudget = isForBudget
        calculatorVC.currencyCode = currencyCode
        calculatorVC.delegate = parentController as? CalculatorDelegate
        calculatorVC.viewRatio = heightRatio
        SwiftEntryKit.display(entry: calculatorVC, using: attributes)        
    }
        
    static func showViewController(viewController: UIViewController) {
        var attributes = centerFloatAttributes
        attributes.hapticFeedbackType = .none
        attributes.name = AccountPickerAttributes
        attributes.roundCorners = .all(radius: 10)
        attributes.entryBackground = .color(color: EKColor(TBColor.darkGary))
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.6)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        SwiftEntryKit.display(entry: viewController, using: attributes)
    }
    
    // MARK: showPicker
    static func showPicker(type: PickerType, currentObject: Any? = nil, completion: @escaping ((_ result: PickerResult, _ value: Any?) -> ())) {
        
        var viewController: UIViewController!
        
        var okAction = {}
        
        var attributes = centerFloatAttributes
        attributes.hapticFeedbackType = .none
        attributes.name = AccountPickerAttributes
        attributes.roundCorners = .all(radius: 10)
        attributes.entryBackground = .color(color: EKColor(TBColor.darkGary))
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
                completion(PickerResult.failed, nil)
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
            okAction()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: EKColor(TBColor.lightGary),
            horizontalDistributionThreshold: 2,
            expandAnimatedly: true
        )

        let buttonBarView = EKButtonBarView(with: buttonsBarContent)
        buttonBarView.roundedForButtonBarView()
        
        
        switch type {
        case .account:
            viewController = AccountPickerViewController()
            guard let vc = viewController as? AccountPickerViewController else {
                return
            }
            if let acc = currentObject as? Account {
                vc.currentAccount = acc
            }
            vc.isForPicker = true
            
            // okAction
            okAction = {
                if let acc = vc.currentAccount {
                    SwiftEntryKit.dismiss()
                    completion(PickerResult.success, acc)
                } else {
                    systemNotice(on: viewController, message: "You didn't select a account!")
                }
            }
            
            // add button to vc
            vc.buttonView.addSubview(buttonBarView)
            buttonBarView.fillSuperview()
        case .country:
            viewController = LocalePickerViewController<CountryCell, Country>()
            guard let vc = viewController as? LocalePickerViewController<CountryCell, Country> else {
                return
            }
            vc.currentItem = currentObject
            // okAction
            okAction = {
                if let country = vc.currentItem as? Country {
                    SwiftEntryKit.dismiss()
                    completion(PickerResult.success, country)
                } else {
                    systemNotice(on: viewController, message: "You didn't select a country!")
                }
            }
            
            vc.pickerType = type
            // add button to vc
            vc.buttonView.addSubview(buttonBarView)
            buttonBarView.fillSuperview()
        case .currency:
            viewController = LocalePickerViewController<CurrencyCell, Currency>()
            guard let vc = viewController as? LocalePickerViewController<CurrencyCell, Currency> else {
                return
            }
            vc.currentItem = currentObject
            // okAction
            okAction = {
                if let currency = vc.currentItem as? Currency {
                    SwiftEntryKit.dismiss()
                    completion(PickerResult.success, currency)
                } else {
                    systemNotice(on: viewController, message: "You didn't select a currency!")
                }
            }
            vc.pickerType = type
            // add button to vc
            vc.buttonView.addSubview(buttonBarView)
            buttonBarView.fillSuperview()
        }
        
        SwiftEntryKit.display(entry: viewController, using: attributes)
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
    
    static func isEntryDisplaying(entryName name: String) -> Bool {
        return SwiftEntryKit.isCurrentlyDisplaying(entryNamed: name)
    }
    
    static func systemNotice(on controller: UIViewController, message: String) {
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
