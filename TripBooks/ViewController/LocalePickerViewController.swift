//
//  LocalePickerViewController.swift
//  TripBooks
//
//  Created by 阿遠 on 2020/10/23.
//  Copyright © 2020 yuan. All rights reserved.
//

import UIKit

// color
fileprivate let backgroundColor = TBColor.darkGary

class LocalePickerViewController<T: GenericCell<U>, U>: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var currentItem: Any?
    
    lazy var headerView = UIView()
    lazy var buttonView = UIView()
    
    lazy var searchBar: UISearchBar = UISearchBar()
    
    var countriesList = [Country]()
    var currencyList = [Currency]()
    
    var searchResultList = [Any]()
    
    var tableView: UITableView!
    
    var pickerType: PickerType? = nil
    
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
        countriesList = IsoService.shared.countriesList
        searchResultList = countriesList
        print(searchResultList.count)
    }
    
    private func setViews() {
        self.view.backgroundColor = backgroundColor
        self.view.roundedCorners()
        
        self.view.addSubview(headerView)
        headerView.anchorViewOnTop()
        setHeaderButton()

        if pickerType != nil {
            setButtonView()
        }
        
        self.view.addSubview(tableView)
        let tableViewBottom: NSLayoutYAxisAnchor = (pickerType != nil) ? buttonView.topAnchor : self.view.bottomAnchor
        
        tableView.anchor(top: headerView.bottomAnchor, bottom: tableViewBottom, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor)
    }
    
    private func setHeaderButton() {
        // search bar
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.roundedCorners(roundedType: .top)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.returnKeyType = .default
            textfield.backgroundColor = TBColor.lightGary
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
    
    private func search(by name: String) {
        let result = countriesList.reduce(into: [Country]()) { (result, country) in
            if country.name.contains(name) {
                result.append(country)
            }
        }
        searchResultList = result
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search
        search(by: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

class CountryCell: GenericCell<Country> {
    override var item: Country! {
        didSet {
            textLabel?.text = item.name
        }
    }
}

class CurrencyCell: GenericCell<Currency> {
    override var item: Currency! {
        didSet {
            textLabel?.text = item.code
        }
    }
}
