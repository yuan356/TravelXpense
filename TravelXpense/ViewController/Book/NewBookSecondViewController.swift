//
//  NewBookViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/11/5.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate let titleFont = MainFont.regular.with(fontSize: 26)
fileprivate let textFont = MainFont.regular.with(fontSize: 22)
fileprivate let titleColor: UIColor = .white
fileprivate let inputColor = TXColor.gray.light

fileprivate let titleHeight: CGFloat = 70
fileprivate let itemHeight: CGFloat = 30

class NewBookSecondViewController: NewBookViewController {
    
    var country: Country? {
        didSet {
            countryLabel.text = country?.name
        }
    }

    var currency: Currency? {
        didSet {
            currencyLabel.text = currency?.code
        }
    }
    
    lazy var countryLabel = UILabel {
        $0.textColor = inputColor
        $0.font = textFont
        $0.textAlignment = .center
    }
    
    lazy var currencyLabel = UILabel {
        $0.textColor = inputColor
        $0.font = textFont
        $0.textAlignment = .center
    }
    
    lazy var countryPickerBtn = UIButton {
        $0.addSubview(countryLabel)
        countryLabel.anchorToSuperViewCenter()
        countryLabel.anchorSize(to: $0)
        $0.restorationIdentifier = "country"
        $0.addTarget(self, action: #selector(openPicker(_:)), for: .touchUpInside)
    }
    
    lazy var currecnyPickerBtn = UIButton {
        $0.addSubview(currencyLabel)
        currencyLabel.anchorToSuperViewCenter()
        currencyLabel.anchorSize(to: $0)
        $0.restorationIdentifier = "currency"
        $0.addTarget(self, action: #selector(openPicker(_:)), for: .touchUpInside)
    }
    
    lazy var imagePickerBtn = UIButton {
        $0.setTitle(NSLocalizedString("Upload", comment: "Upload"), for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = TXColor.system.blue.medium
        $0.setBackgroundColor(color: TXColor.system.blue.light, forState: .highlighted)
        $0.roundedCorners(radius: 5, shadow: true)
        $0.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        $0.anchorSize(h: 35, w: 80)
    }
    
    lazy var imageView = UIImageView {
        $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 0.45).isActive = true
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = TXColor.gray.light
        $0.roundedCorners()
        $0.clipsToBounds = true
    }
    
    lazy var vStack = UIStackView {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = TXColor.background()
        setVStack()
        
    }
    
    private func setVStack() {
        let countryDesc = UILabel {
            $0.textColor = titleColor
            $0.font = titleFont
            $0.text = NSLocalizedString("Choose a country", comment: "Choose a country")
            $0.anchorSize(h: titleHeight)
        }
        
        let currencyDesc = UILabel {
            $0.textColor = titleColor
            $0.font = titleFont
            $0.text = NSLocalizedString("Choose a currency", comment: "Choose a currency")
            $0.anchorSize(h: titleHeight)
        }
        
        let coverDesc = UILabel {
            $0.textColor = titleColor
            $0.font = MainFont.regular.with(fontSize: 20)
            $0.text = NSLocalizedString("Optional: Upload a cover image", comment: "Optional: Upload a cover image")
            $0.anchorSize(h: titleHeight)
        }
        
        vStack.addArrangedSubview(countryDesc)
        vStack.addArrangedSubview(getView(obj: countryPickerBtn))
        vStack.addArrangedSubview(currencyDesc)
        vStack.addArrangedSubview(getView(obj: currecnyPickerBtn))
        vStack.addArrangedSubview(coverDesc)
        vStack.addArrangedSubview(imageView)
        
        self.view.addSubview(vStack)
        vStack.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 35, left: 20, bottom: 0, right: 20))
        
        view.addSubview(imagePickerBtn)
        imagePickerBtn.setAutoresizingToFalse()
        imagePickerBtn.anchorCenterY(to: imageView)
        imagePickerBtn.anchorCenterX(to: imageView)

    }
    
    private func getView(obj: UIView, lineWithObj: UIView? = nil) -> UIView {
        let view = UIView()
        view.anchorSize(h: itemHeight)
        let lineView = UIView {
            $0.anchorSize(h: 1)
            $0.backgroundColor = TXColor.gray.medium
        }
        view.addSubview(lineView)
        
        
        view.addSubview(obj)
        if let withObj = lineWithObj {
            lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: withObj.leadingAnchor, trailing: withObj.trailingAnchor)
        } else {
            lineView.anchor(top: nil, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        }
        obj.anchor(top: view.topAnchor, bottom: lineView.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        return view
    }
    
    @IBAction func openPicker(_ sender: UIButton) {
        if let id = sender.restorationIdentifier {
            if id == "country" {
                TXAlert.showPicker(type: .country, currentObject: self.country) { (result, country) in
                    if result == .success, let country = country as? Country {
                        self.country = country
                        guard let pageVC = self.parent as? NewBookPageViewController else {
                            return
                        }
                        pageVC.bookCountry = country

                        if let currencyCode = IsoCountryCodes.find(key: country.code)?.currency {
                            let currency = Currency(code: currencyCode)
                            self.currency = currency
                            pageVC.bookCurrency = currency
                        }
                    }
                }
            } else {
                TXAlert.showPicker(type: .currency, currentObject: currency) { (result, currency) in
                    if result == .success, let currency = currency as? Currency {
                        self.currency = currency
                        if let pageVC = self.parent as? NewBookPageViewController {
                            pageVC.bookCurrency = currency
                        }
                    }
                }
            }
        }
    }
    
    // MARK: openImagePicker
    @IBAction func openImagePicker() {
        let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your image source", comment: "Choose your image source"), preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler : { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
        present(photoSourceRequestController, animated: true, completion: nil)
    }
}

// MARK: ImagePicker
extension NewBookSecondViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView.image = selectedImage
                if let pageVC = self.parent as? NewBookPageViewController {
                    pageVC.bookImage = selectedImage
                }
            }
        }
    }
}
