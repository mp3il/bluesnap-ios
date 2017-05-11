//
//  BSCountryViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSCountryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: puclic properties
    
    internal var selectedCountryCode : String = ""
    
    // the callback function that gets called when a country is selected;
    // this is just a default
    internal var updateFunc : (String, String)->Void = {
        countryCode, countryName in
        NSLog("Country \(countryCode):\(countryName) was selected")
    }

    internal var countryManager : BSCountryManager!
    
    
    // MARK: private properties
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var countries : [(name: String, code: String)] = []
    fileprivate var filteredCountries : [(name: String, code: String)] = []
    fileprivate var selectedCountryName : String = ""

    
    // MARK: Search bar stuff
    
    fileprivate var searchBar : UISearchBar?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchBar = searchBar
        filterCountries(searchText)
    }
    
    private func filterCountries(_ searchText : String) {
        
        if searchText == "" {
            self.filteredCountries = self.countries
        } else {
            filteredCountries = countries.filter{(x) -> Bool in (x.name.lowercased().range(of:searchText.lowercased())) != nil }
        }
        self.tableView.reloadData()
    }
    
    private func getCountryIndex(code: String) -> Int? {
        
        for (index, country) in filteredCountries.enumerated() {
            if country.code == code {
                return index
            }
        }
        return nil
    }
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get country data
        if let manager = countryManager {
            let countryCodes = manager.getCountryCodes()
            for countryCode in countryCodes {
                if let countryName = manager.getCountryName(countryCode: countryCode) {
                    countries.append((name: countryName, code: countryCode))
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        filterCountries(searchBar?.text ?? "")
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
        
        if let index = getCountryIndex(code: self.selectedCountryCode) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    
    // Create a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSCountryTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        let country = self.filteredCountries[indexPath.row]
        cell.itemNameUILabel.text = country.name
        cell.checkMarkImageView.image = nil
        if (country.code == selectedCountryCode) {
            if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                cell.checkMarkImageView.image = image
            }
        }
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: country.code.uppercased()) {
            cell.flagUIButton.imageView?.image = image
        }
        return cell
    }
    
    // Return # rows to display in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredCountries.count
    }
    
    //Tells the delegate that the specified row is now selected.
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        
        // find and deselect previous option
        if let oldIndex = self.getCountryIndex(code: selectedCountryCode) {
            let path = IndexPath(row: oldIndex, section: 0)
            selectedCountryCode = ""
            self.tableView.reloadRows(at: [path], with: .none)
        }

        // select current option
        let country = filteredCountries[didSelectRowAt.row]
        selectedCountryCode = country.code
        selectedCountryName = country.name
        self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
        
        // call updateFunc
        updateFunc(selectedCountryCode, selectedCountryName)
    }
    
}
