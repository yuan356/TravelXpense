//
//  BookSettingViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/21.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

fileprivate enum SettingCellRow {
    case name
    case country
    case currency
    case startDate
    case endDate
    case account
}

// Padding
fileprivate let paddingInContentView: CGFloat = 10
fileprivate let paddingInVStack: CGFloat = 8
fileprivate let spacingInVStack: CGFloat = 8
fileprivate let heightForStackItem: CGFloat = 50
fileprivate let widthForInputObject: CGFloat = 225

// Font
fileprivate let titleTextFont: UIFont = MainFont.regular.with(fontSize: 18)
fileprivate let inputTextFont: UIFont = MainFont.regular.with(fontSize: 18)
fileprivate let inputTextNumberFont = MainFontNumeral.regular.with(fontSize: .medium)

// Color
fileprivate let backgroundColor = TBColor.darkGary
fileprivate let inputTextColor: UIColor = TBColor.lightGary

fileprivate enum buttonType: String {
    case country
    case currency
    case startDate
    case endDate
    case account
}

fileprivate let nameMaxLength = 100

class BookSettingViewController: UIViewController {

    // MARK: Book Parameters
    var book: Book! {
        didSet {
            if let book = book {
                // MARK: Get book data
                nameTextField.text = book.name
                if book.imageUrl == "" { // get image from file system
                    ImageService.retrieveFromLocal(bookId: book.id, imageView: self.imageView)
                }
                bookStartDate = book.startDate
                bookEndDate = book.endDate
                bookCountry = book.country
                bookCurrency = book.currency
            }
        }
    }
    
    var bookStartDate: Date? {
        didSet {
            if let date = bookStartDate {
                startDateLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    var bookEndDate: Date? {
        didSet {
            if let date = bookEndDate {
                endDateLabel.text = TBFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    var bookCountry: Country? {
        didSet {
            countryLabel.text = bookCountry?.name
        }
    }
    
    var bookCurrency: Currency? {
        didSet {
            currencyLabel.text = bookCurrency?.code
        }
    }

    
    var keyboardShown = false {
        didSet {
            countryBtn.isEnabled = !keyboardShown
            currencyBtn.isEnabled = !keyboardShown
            startDateBtn.isEnabled = !keyboardShown
            endDateBtn.isEnabled = !keyboardShown
            budgetBtn.isEnabled = !keyboardShown
        }
    }
            
    
    // MARK: Views
    lazy var imageView = UIImageView {
        $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 0.45).isActive = true
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    lazy var imagePickerBtn = UIButton {
        $0.anchorSize(h: 30, w: 95)
        $0.setTitle("Change cover", for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .small)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = TBColor.darkGary
        $0.setBackgroundColor(color: TBColor.lightGary, forState: .highlighted)
        $0.roundedCorners(radius: 5, shadow: true)
    }
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = spacingInVStack
        $0.axis = .vertical
    }

    // MARK: Objects
    lazy var nameTextField = UITextField {
        $0.tintColor = .systemBlue
        $0.textAlignment = .right
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var countryLabel = UILabel {
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var currencyLabel = UILabel {
        $0.font = inputTextFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var startDateLabel = UILabel {
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var endDateLabel = UILabel {
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.textAlignment = .right
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var budgetLabel = UILabel {
        $0.textAlignment = .right
        $0.font = inputTextNumberFont
        $0.textColor = inputTextColor
        $0.anchorSize(w: widthForInputObject)
    }
    
    lazy var countryBtn = UIButton()
    lazy var currencyBtn = UIButton()
    lazy var startDateBtn = UIButton()
    lazy var endDateBtn = UIButton()
    lazy var budgetBtn = UIButton()
    lazy var accountBtn = UIButton()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        setViews()
    }
    
    private func setViews() {
        setImageViews()
        setVStackView()
    }
    
    // MARK: setImageViews
    private func setImageViews() {
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        view.addSubview(imagePickerBtn)
        imagePickerBtn.setAutoresizingToFalse()
        imagePickerBtn.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8).isActive = true
        imagePickerBtn.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8).isActive = true
        imagePickerBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    }
    
    // MARK: vStackView
    /// add vStackView to contentView & setting
    private func setVStackView() {
        var views = [UIView]()
        views.append(getInputView(viewTitle: "Book name", rowType: .name))
        views.append(getInputView(viewTitle: "Country", rowType: .country))
        views.append(getInputView(viewTitle: "Currency", rowType: .currency))
        views.append(getInputView(viewTitle: "Start Date", rowType: .startDate))
        views.append(getInputView(viewTitle: "End Date", rowType: .endDate))
        views.append(getInputView(viewTitle: "Account", rowType: .account))
        
        for view in views {
            vStackView.addArrangedSubview(view)
        }
        
        view.addSubview(vStackView)
        let viewCount = CGFloat(views.count)
        let vStackHeight = (heightForStackItem * viewCount)
                            + (paddingInVStack * (viewCount - 1))
        
        vStackView.anchor(top: imageView.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView), size: CGSize(width: 0, height: vStackHeight))
    }
    
    // MARK: set detail
    private func setDetailView(title: String, to view: UIView, type: SettingCellRow) {
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = titleTextFont
        titleLabel.textColor = .white
        view.addSubview(titleLabel)
        titleLabel.anchorSuperViewLeading(padding: paddingInVStack)
        titleLabel.anchorCenterY(to: view)
        
        switch type {
        case .name:
            addInputObjects(to: view, object: nameTextField)
            nameTextField.delegate = self
        case .country:
            addInputObjects(to: view, object: countryLabel)
            addToolsButton(btnType: .country, to: view)
        case .currency:
            addInputObjects(to: view, object: currencyLabel)
            addToolsButton(btnType: .currency, to: view)
        case .startDate:
            addInputObjects(to: view, object: startDateLabel)
            addToolsButton(btnType: .startDate, to: view)
        case .endDate:
            addInputObjects(to: view, object: endDateLabel)
            addToolsButton(btnType: .endDate, to: view)
        case .account:
            addToolsButton(btnType: .account, to: view)
        }
    }
    
    private func getInputView(viewTitle: String, rowType: SettingCellRow) -> UIView {
        let view = UIView()
        view.anchorSize(h: heightForStackItem)
        setDetailView(title: viewTitle, to: view, type: rowType)
        return view
    }
    
    private func addInputObjects(to view: UIView, object: UIView) {
        view.addSubview(object)
        object.anchorSuperViewTrailing(padding: paddingInVStack)
        object.anchorCenterY(to: view)
    }
    
    
    private func addToolsButton(btnType: buttonType, to container: UIView) {
        var button: UIButton?
        switch btnType {
        case .country:
            button = countryBtn
        case .currency:
            button = currencyBtn
        case .startDate:
            button = startDateBtn
        case .endDate:
            button = endDateBtn
        case .account:
            button = accountBtn
        }
     
        guard let btn = button else {
            return
        }
        
        container.addSubview(btn)
        btn.anchorSize(to: container)
        btn.anchorCenterX(to: container)
        btn.anchorCenterY(to: container)
        btn.restorationIdentifier = btnType.rawValue
        btn.addTarget(self, action: #selector(openTools(_:)), for: .touchUpInside)
    }
    
    // MARK: open Tools
    @IBAction func openTools(_ sender: UIButton) {
        if let id = sender.restorationIdentifier,
           let type = buttonType.init(rawValue: id) {
            switch type {
            case .country:
                TBNotify.showPicker(type: .country, currentObject: bookCountry) { (result, country) in
                    if result == .success, let country = country as? Country {
                        self.bookCountry = country
                        self.saveData(field: .country, value: country)
                    }
                }
            case .currency:
                TBNotify.showPicker(type: .currency, currentObject: bookCurrency) { (result, currency) in
                    if result == .success, let currency = currency as? Currency {
                        self.bookCurrency = currency
                        self.saveData(field: .currency, value: currency)
                    }
                }
            case .startDate:
                let datePickerVC = TBdatePickerViewController()
                if let date = bookStartDate {
                    datePickerVC.setDate(date: date)
                }
                datePickerVC.buttonIdentifier = type.rawValue
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .endDate:
                let datePickerVC = TBdatePickerViewController()
                if let date = bookEndDate {
                    datePickerVC.setDate(date: date)
                }
                if let startDate = bookStartDate {
                    datePickerVC.setMinimumDate(startDate)
                }
                datePickerVC.buttonIdentifier = type.rawValue
                datePickerVC.delegate = self
                datePickerVC.show(on: self)
            case .account:
                let vc = AccountPickerViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: openImagePicker
    @IBAction func openImagePicker() {
        print("openImagePicker")
        let photoSourceRequestController = UIAlertController(title: "", message: " Choose your image source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler : { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
        present(photoSourceRequestController, animated: true, completion: nil)
        
    }
    
    // MARK: Save
    private func saveData(field: BookFieldForUpdate, value: Any) {
        var errorMsg = ""
        var updateValue = value
        
        // check input
        switch field {
        case .name: // limited <= 100
            if let value = updateValue as? String {
                if value.count > nameMaxLength {
                    errorMsg = "Book name should less than \(nameMaxLength)."
                }
            }
        case .country:
            if let country = value as? Country {
                updateValue = country.code
            }
        case .currency:
            if let currency = value as? Currency {
                updateValue = currency.code
            }
        case .startDate:
            break
        case .endDate:
            break
        }
        
        if errorMsg == "",
           let value = updateValue as? NSObject {
            book.updateData(field: field, value: value)
        } else {
            TBNotify.showCenterAlert(message: errorMsg)
        }
    }
}

// MARK: - extension
// MARK: TBDatePickerDelegate
extension BookSettingViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        if let type = buttonType.init(rawValue: buttonIdentifier) {
            if type == .startDate {
                bookStartDate = date
                saveData(field: .startDate, value: date)
            } else if type == .endDate {
                bookEndDate = date
                saveData(field: .endDate, value: date)
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension BookSettingViewController: UITextFieldDelegate {
    // update name text
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            saveData(field: .name, value: text)
        }
        keyboardShown = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardShown = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 輸入字數限制
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= nameMaxLength
    }
}

// MARK: ImagePicker
extension BookSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView.image = selectedImage
                ImageService.storeToLocal(image: selectedImage, bookId: self.book.id)
                // if store to local, image url is empty
            }
        }
    }
}
