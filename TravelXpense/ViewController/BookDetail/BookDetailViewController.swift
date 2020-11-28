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
fileprivate let widthForInputObject: CGFloat = 225

// Font
fileprivate let titleTextFont: UIFont = MainFont.regular.with(fontSize: 18)
fileprivate let inputTextFont: UIFont = MainFont.regular.with(fontSize: 18)
fileprivate let inputTextNumberFont = MainFontNumeral.regular.with(fontSize: .medium)

// Color
fileprivate let backgroundColor = TXColor.gray.dark
fileprivate let inputTextColor: UIColor = TXColor.gray.light

fileprivate enum buttonType: String {
    case country
    case currency
    case startDate
    case endDate
    case account
}

fileprivate let nameMaxLength = 100

class BookDetailViewController: UIViewController {

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
    
    var bookStartDate: Date! {
        didSet {
            if let date = bookStartDate {
                startDateLabel.text = TXFunc.convertDateToDateStr(date: date)
            }
        }
    }
    
    var bookEndDate: Date! {
        didSet {
            if let date = bookEndDate {
                endDateLabel.text = TXFunc.convertDateToDateStr(date: date)
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
        $0.setTitle(NSLocalizedString("Change cover", comment: "Change cover"), for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .small)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = TXColor.system.blue.medium
        $0.setBackgroundColor(color: TXColor.system.blue.light, forState: .highlighted)
        $0.roundedCorners(radius: 5, shadow: true)
    }
    
    lazy var vStackView = UIStackView {
        $0.alignment = .fill
        $0.distribution = .fillEqually
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
    
    lazy var deleteButton = UIButton {
        $0.setTitle(NSLocalizedString("Delete book", comment: "Delete book"), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = MainFont.medium.with(fontSize: .medium)
        $0.setTitleColor(TXColor.gray.medium, for: .highlighted)
        $0.backgroundColor = TXColor.delete.normal
        $0.setBackgroundColor(color: TXColor.delete.highlighted, forState: .highlighted)
        $0.roundedCorners()
        $0.anchorSize(h: 43, w: 170)
        $0.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
    }
    
    @IBAction func deleteButtonClicked() {
        let msg = NSLocalizedString("Are you sure you want to delete this book?", comment: "Are you sure you want to delete this book?")
        let note = NSLocalizedString("All records of this book will be delete!", comment: "All records of this book will be delete!")
        
        TXAlert.showCenterAlert(message: msg, note: note, confirm: true, okAction: {
            TXAlert.dismiss()
            BookService.shared.deleteBook(bookId: self.book.id) {
                self.dismiss(animated: true, completion: nil)
                TXObserved.notifyObservers(notificationName: .bookCellDelete, infoKey: .bookDelete, infoValue: self.book)
            }
        })
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
        let emptyImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = emptyImage
        self.navigationItem.backButtonTitle = ""
        
        setViews()
    }
    
    private func setViews() {
        setImageViews()
        self.view.addSubview(deleteButton)
        deleteButton.anchor(top: nil, bottom: view.bottomAnchor, leading: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        deleteButton.anchorCenterX(to: view)
        
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
        views.append(getInputView(viewTitle: NSLocalizedString("Book name", comment: "Book name"), rowType: .name))
        views.append(getInputView(viewTitle: NSLocalizedString("Country", comment: "Country"), rowType: .country))
        views.append(getInputView(viewTitle: NSLocalizedString("Currency", comment: "Currency"), rowType: .currency))
        views.append(getInputView(viewTitle: NSLocalizedString("Start date", comment: "Start Date"), rowType: .startDate))
        views.append(getInputView(viewTitle: NSLocalizedString("End date", comment: "End Date"), rowType: .endDate))
        views.append(getInputView(viewTitle: NSLocalizedString("Account", comment: "Account"), rowType: .account))
        
        for view in views {
            vStackView.addArrangedSubview(view)
        }
        
        view.addSubview(vStackView)

        vStackView.anchor(top: imageView.bottomAnchor, bottom: deleteButton.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: paddingInContentView, left: paddingInContentView, bottom: paddingInContentView, right: paddingInContentView))
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
            let arrowView = UIImageView()
            arrowView.image = UIImage(named: TXNavigationIcon.arrowRight.rawValue)
            arrowView.anchorSize(h: 16, w: 16)
            arrowView.tintColor = .white
            addInputObjects(to: view, object: arrowView)
            addToolsButton(btnType: .account, to: view)
        }
    }
    
    private func getInputView(viewTitle: String, rowType: SettingCellRow) -> UIView {
        let view = UIView()
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
                TXAlert.showPicker(type: .country, currentObject: bookCountry) { (result, country) in
                    if result == .success, let country = country as? Country {
                        self.bookCountry = country
                        self.saveData(field: .country, value: country)
                        if let currencyCode = IsoCountryCodes.find(key: country.code)?.currency {
                            let currency = Currency(code: currencyCode)
                            self.bookCurrency = currency
                            self.saveData(field: .currency, value: currency)
                        }
                    }
                }
            case .currency:
                TXAlert.showPicker(type: .currency, currentObject: bookCurrency) { (result, currency) in
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
                if let endDate = bookEndDate {
                    datePickerVC.setMaximumDate(endDate)
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
    
    // MARK: Save
    private func saveData(field: BookFieldForUpdate, value: Any) {
        var errorMsg = ""
        var updateValue = value
        
        // check input
        switch field {
        case .name: // limited <= 100
            if let value = updateValue as? String {
                if value.count > nameMaxLength {
                    errorMsg = NSLocalizedString("Book name should be less than 100 characters", comment: "Book name should be less than 100 characters")
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
        case .imageUrl:
            break
        }
        
        if errorMsg == "",
           let value = updateValue as? NSObject {
            book.updateData(field: field, value: value)
            
            if field == .name {
                TXObserved.notifyObservers(notificationName: .bookNameUpdate, infoKey: .bookName, infoValue: value)
            }
            TXObserved.notifyObservers(notificationName: .bookCellUpdate, infoKey: .bookUpdate, infoValue: book)
        } else {
            TXAlert.showCenterAlert(message: errorMsg)
        }
    }
}

// MARK: - extension
// MARK: TBDatePickerDelegate
extension BookDetailViewController: TBDatePickerDelegate {
    func changeDate(buttonIdentifier: String, date: Date) {
        
        let alertTitle = NSLocalizedString("Are you sure you want to change the travel date?", comment: "BookDateChangeConfirm")
        let alertNote = NSLocalizedString("New travel date is shorter than original one, so data will change accordingly", comment: "BookDateRangeAlert")
        if let type = buttonType.init(rawValue: buttonIdentifier) {
            if type == .startDate {
                guard TXFunc.compareDay(date: date, target: bookEndDate) != .orderedDescending else {
                    TXAlert.showCenterAlert(message: NSLocalizedString("Start date should be earlier than end date", comment: "Start date should be earlier than end date"))
                    return
                }
                
                // date > bookStartDate
                if TXFunc.compareDay(date: date, target: bookStartDate) == .orderedDescending {
                    TXAlert.showCenterAlert(message: alertTitle, note: alertNote, confirm: true) {
                        self.bookStartDate = date
                        self.saveData(field: .startDate, value: date)
                        TXAlert.dismiss()
                    }
                } else {
                    bookStartDate = date
                    saveData(field: .startDate, value: date)
                }
                
            } else if type == .endDate {
                guard TXFunc.compareDay(date: date, target: bookStartDate) != .orderedAscending else {
                    TXAlert.showCenterAlert(message: NSLocalizedString("End date should be later than start date", comment: "End date should be later than start date"))
                    return
                }
                // date < bookEndDate
                if TXFunc.compareDay(date: date, target: bookEndDate) == .orderedAscending {
                    TXAlert.showCenterAlert(message: alertTitle, note: alertNote, confirm: true) {
                        self.bookEndDate = date
                        self.saveData(field: .endDate, value: date)
                        TXAlert.dismiss()
                    }
                } else {
                    self.bookEndDate = date
                    self.saveData(field: .endDate, value: date)
                }
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension BookDetailViewController: UITextFieldDelegate {
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
extension BookDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imageView.image = selectedImage
                ImageService.storeToLocal(image: selectedImage, bookId: self.book.id)
                self.saveData(field: .imageUrl, value: "")
                // if store to local, image url is empty
            }
        }
    }
}
