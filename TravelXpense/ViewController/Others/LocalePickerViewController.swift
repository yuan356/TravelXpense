//
//  LocalePickerViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit



class LocalePickerViewController<T: GenericCell<U>, U>: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var currentItem: Any?
    
    lazy var headerView = UIView()
    lazy var buttonView = UIView()
    
    lazy var searchBar: UISearchBar = UISearchBar()
    
    var searchResultList = [Any]()
    
    var tableView: UITableView!
    
    var pickerType: PickerType!
    
    lazy var selectedView = UIView {
        $0.backgroundColor = TXColor.system.blue.light
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setViews()
    }
    
    private func setTableView() {
        tableView = UITableView()
        tableView.register(T.self, forCellReuseIdentifier: String(describing: T.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        if pickerType == .country {
            searchResultList = getAllCountriesList()
        } else if pickerType == .currency {
            searchResultList = getAllCurrencyList()
        }
    }
    
    private func getAllCountriesList() -> [Any] {
        let list = IsoService.shared.allCountries.reduce(into: [Any]()) { (result, info) in
            result.append(Country(code: info.alpha2))
        }
        return list
    }
    
    private func getAllCurrencyList() -> [Any] {
        let strlist = IsoService.shared.allCountries.reduce(into: [String]()) { (result, info) in
            if !result.contains(info.currency) {
                result.append(info.currency)
            }
        }
        
        let list = strlist.map { (code) -> Currency in
            return Currency(code: code)
        }
        
        return list
    }
    
    private func setViews() {
        
        self.view.addSubview(headerView)
        headerView.anchorViewOnTop()
        setHeaderButton()
        setButtonView()
        
        self.view.addSubview(tableView)
        
        tableView.anchor(top: headerView.bottomAnchor, bottom: buttonView.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }
    
    private func setHeaderButton() {
        // search bar
        searchBar.searchBarStyle = .prominent
    
        let placeholder = pickerType == .country ?
            NSLocalizedString("Country name", comment: "Country name") : NSLocalizedString("Country name or currency code", comment: "Country name or currency code")
        
        searchBar.sizeToFit()
        searchBar.searchTextField.leftView?.tintColor = TXColor.gray.dark
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: TXColor.gray.dark])

        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.roundedCorners(roundedType: .top)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.returnKeyType = .search
            textfield.textColor = .black
            textfield.backgroundColor = TXColor.gray.medium
        }
        headerView.addSubview(searchBar)
        searchBar.fillSuperview()
    }
    
    private func setButtonView() {
        self.view.addSubview(buttonView)
        buttonView.anchorViewOnBottom()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T {
            cell.selectedBackgroundView = selectedView
            cell.item = searchResultList[indexPath.row] as? U
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchResultList[indexPath.row]
        currentItem = item
        searchBar.resignFirstResponder()
    }
    
    private func search(by str: String) {
        var result = [Any]()
        if pickerType == .country {
            result = IsoService.shared.allCountries.reduce(into: [Any]()) { (result, info) in
                if info.name.localizedCaseInsensitiveContains(str) || info.alpha3.localizedCaseInsensitiveContains(str) {
                    result.append(Country(code: info.alpha2))
                }
            }
        } else if pickerType == .currency {
            let strlist = IsoService.shared.allCountries.reduce(into: [String]()) { (result, info) in
                if info.name.localizedCaseInsensitiveContains(str) || info.alpha3.localizedCaseInsensitiveContains(str) || info.currency.localizedCaseInsensitiveContains(str) {
                    if !result.contains(info.currency) {
                        result.append(info.currency)
                    }
                }
            }
            result = strlist.map { (code) -> Currency in
                return Currency(code: code)
            }
        }
       
        searchResultList = result
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search
        let text = searchText.trimmingCharacters(in: .whitespaces)
        search(by: text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

class CountryCell: GenericCell<Country> {
    override var item: Country! {
        didSet {
            textLabel?.textColor = .white
            textLabel?.text = item.name
        }
    }
    
    override func setupViews() {
        self.backgroundColor = .clear
    }
}

class CurrencyCell: GenericCell<Currency> {
    override var item: Currency! {
        didSet {
            textLabel?.textColor = .white
            textLabel?.text = String(item.code)
        }
    }
    
    override func setupViews() {
        self.backgroundColor = .clear
    }
}
