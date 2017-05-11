//
//  BSCurrencviesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 13/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCurrenciesViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: puclic properties
    
    // BS token for API call to load currency rates
    internal var bsToken: BSToken?
    // The currently selected currency code
    internal var selectedCurrencyCode : String = ""
    // the callback function that gets called when a currency is selected;
    // this ids just a default
    internal var updateFunc : (BSCurrency?, BSCurrency?)->Void = {
        oldCurrency, newCurrency in
        NSLog("Currency \(newCurrency?.getCode()) was selected")
    }


    // MARK: private properties
    
    fileprivate var bsCurrencies : BSCurrencies?
    fileprivate var filteredCurrencies : BSCurrencies?
    
    
    // MARK: Search bar stuff
    
    fileprivate var searchBar : UISearchBar?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchBar = searchBar
        filterCurrencies(searchText)
    }

    private func filterCurrencies(_ searchText : String) {
        
        if searchText == "" {
            self.filteredCurrencies = self.bsCurrencies
        } else if let bsCurrencies = self.bsCurrencies {
            let filtered = bsCurrencies.currencies.filter{(x) -> Bool in (x.name.lowercased().range(of:searchText.lowercased())) != nil }
            filteredCurrencies = BSCurrencies(currencies: filtered)
        } else {
            filteredCurrencies = BSCurrencies(currencies: [])
        }
        self.tableView.reloadData()
    }
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Re-load currencies data if necessary
        if let bsToken = bsToken {
            bsCurrencies = BSApiManager.getCurrencyRates(bsToken: bsToken)
        }
        if let searchBar = self.searchBar {
            filterCurrencies(searchBar.text ?? "")
        } else {
            filteredCurrencies = bsCurrencies
        }
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false

        // scroll to selected
        if let index = filteredCurrencies?.getCurrencyIndex(code: selectedCurrencyCode) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // return #rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredCurrencies = filteredCurrencies {
            return filteredCurrencies.currencies.count
        } else {
            return 0
        }
    }
    
    // "draw" a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSCurrencyTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        if let bsCurrency = filteredCurrencies?.currencies[indexPath.row] {
            cell.CurrencyUILabel.text = bsCurrency.getName() + " " + bsCurrency.getCode()
            cell.checkMarkImage.image = nil
            if (bsCurrency.getCode() == selectedCurrencyCode) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImage.image = image
                }
            }
        }
        return cell
    }
    
    // When a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let filteredCurrencies = filteredCurrencies, let bsCurrencies = bsCurrencies {
            
            // find and deselect previous option
            let oldBsCurrency : BSCurrency? = bsCurrencies.getCurrencyByCode(code: selectedCurrencyCode)
            if let oldIndex = filteredCurrencies.getCurrencyIndex(code: selectedCurrencyCode) {
                let path = IndexPath(row: oldIndex, section: 0)
                selectedCurrencyCode = ""
                self.tableView.reloadRows(at: [path], with: .none)
            }
            
            // select current option
            let newBsCurrency : BSCurrency = filteredCurrencies.currencies[indexPath.row]
            selectedCurrencyCode = newBsCurrency.getCode()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        
            // call updateFunc
            updateFunc(oldBsCurrency, newBsCurrency)
        }
    }
    
}
