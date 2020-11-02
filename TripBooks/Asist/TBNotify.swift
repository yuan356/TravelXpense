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
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.7)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.27)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.entranceAnimation = alertEntranceAnimation
        attributes.exitAnimation = alertExitAnimation
        attributes.hapticFeedbackType = .none
        
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
    
    // MARK: showCenterAlert
    static func showCenterAlert(message: String, title: String = "", note: String = "", confirm: Bool = false, okAction: (()->())? = nil ) {
        var attributes = centerFloatAttributes
        let backColor = #colorLiteral(red: 0.2193589807, green: 0.219402343, blue: 0.219353199, alpha: 0.6472870291)
        attributes.screenBackground = .color(color: EKColor.init(backColor))
        let view = UIView()
        view.roundedCorners()
        view.backgroundColor = TBColor.gray.dark
        
        let titleFont = MainFont.medium.with(fontSize: 20)
        let textFont = MainFont.regular.with(fontSize: 17)
        let noteFont = MainFont.regular.with(fontSize: 15)
        let btnFont = MainFont.regular.with(fontSize: .medium)
        
        let MessageView = UIView()

        let messageLabel = UILabel {
            $0.textAlignment = .center
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.font = textFont
            $0.text = message
        }
        
        let vStack = UIStackView()
        vStack.distribution = .fill
        vStack.axis = .vertical
        if title != "" {
            let titleLabel = UILabel {
                $0.textAlignment = .center
                $0.textColor = .white
                $0.font = titleFont
                $0.text = title
                $0.anchorSize(h: 30)
            }
            vStack.addArrangedSubview(titleLabel)
        }
        vStack.addArrangedSubview(messageLabel)
        if note != "" {
            let noteLabel = UILabel {
                $0.textAlignment = .center
                $0.textColor = TBColor.orange.light
                $0.numberOfLines = 0
                $0.font = noteFont
                $0.text = note
                $0.anchorSize(h: 50)
            }
            vStack.addArrangedSubview(noteLabel)
        }

        
        MessageView.addSubview(vStack)
        vStack.fillSuperview(padding: UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 10))
        
        let closeText = confirm ? "Cancel": "Okay"
        let closeTextColor = confirm ?
            EKColor.init(TBColor.orange.light) : EKColor.white
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: btnFont,
            color: closeTextColor
        )
        
        let closeButtonLabel = EKProperty.LabelContent(
            text: closeText,
            style: closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.standardBackground.with(alpha: 0.2)) {
                SwiftEntryKit.dismiss()
            }
        
        let okButtonLabelStyle = EKProperty.LabelStyle(
            font: btnFont,
            color: .white
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "Okay",
            style: okButtonLabelStyle
        )
        
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.standardBackground.with(alpha: 0.2)) {
            okAction?()
        }
        
        
        var buttonsBarContent: EKProperty.ButtonBarContent
        if confirm {
            buttonsBarContent = EKProperty.ButtonBarContent(
                with: closeButton, okButton,
                separatorColor: EKColor.init(TBColor.gray.light),
                expandAnimatedly: true
            )
        } else {
            buttonsBarContent = EKProperty.ButtonBarContent(
                with: closeButton,
                separatorColor: EKColor.init(TBColor.gray.light),
                expandAnimatedly: true
            )
        }
        
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
    
    // MARK: showCalculator
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
        let heightRatio: CGFloat = 0.45
        let height = EKAttributes.PositionConstraints.Edge.ratio(value: heightRatio)
   
        attributes.positionConstraints.size.height = height
        attributes.entryBackground = .color(color: EKColor.init(TBColor.gray.medium))
        
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
        attributes.entryBackground = .color(color: EKColor(TBColor.gray.dark))
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
        attributes.entryBackground = .color(color: EKColor(TBColor.gray.dark))
        let widthConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.8)
        let heightConstraint = EKAttributes.PositionConstraints.Edge.ratio(value: 0.6)
        attributes.positionConstraints.size = .init(width: widthConstraint, height: heightConstraint)
        
        let mediumFont = MainFont.regular.with(fontSize: .medium)
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(
            font: mediumFont,
            color: .white
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
            color: .white
        )
        let okButtonLabel = EKProperty.LabelContent(
            text: "Okay",
            style: okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor.standardBackground.with(alpha: 0.2)) {
            okAction()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: EKColor(TBColor.gray.light),
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
