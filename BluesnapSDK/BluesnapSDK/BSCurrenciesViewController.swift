//
//  BSCurrenciesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 11/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCurrenciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: puclic properties
    
    // The currently selected currency code
    internal var selectedCurrencyCode : String = ""
    // the callback function that gets called when a currency is selected;
    // this ids just a default
    internal var updateFunc : (BSCurrency?, BSCurrency?)->Void = {
        oldCurrency, newCurrency in
        NSLog("Currency \(newCurrency?.getCode() ?? "None") was selected")
    }
    
    
    // MARK: private properties
    
    fileprivate var bsCurrencies : BSCurrencies?
    fileprivate var filteredCurrencies : BSCurrencies?
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: init currencies
    
    /**
     Re-load currencies data if necessary; should be called before displaying the view
     */
    func initCurrencies() -> Bool {
        if let tmp = BSApiManager.getCurrencyRates() {
            bsCurrencies = tmp
            return true
        } else {
            return false
        }
    }
    
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
        
        filterCurrencies(searchBar?.text ?? "")
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
        
        // scroll to selected
        if let index = filteredCurrencies?.getCurrencyIndex(code: selectedCurrencyCode) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    
    // Create a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    // Return # rows to display in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredCurrencies = filteredCurrencies {
            return filteredCurrencies.currencies.count
        } else {
            return 0
        }
    }
    
    //Tells the delegate that the specified row is now selected.
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        
        if let filteredCurrencies = filteredCurrencies, let bsCurrencies = bsCurrencies {
            
            // find and deselect previous option
            let oldBsCurrency : BSCurrency? = bsCurrencies.getCurrencyByCode(code: selectedCurrencyCode)
            if let oldIndex = filteredCurrencies.getCurrencyIndex(code: selectedCurrencyCode) {
                let path = IndexPath(row: oldIndex, section: 0)
                selectedCurrencyCode = ""
                self.tableView.reloadRows(at: [path], with: .none)
            }
            
            // select current option
            let newBsCurrency : BSCurrency = filteredCurrencies.currencies[didSelectRowAt.row]
            selectedCurrencyCode = newBsCurrency.getCode()
            self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
            
            // call updateFunc
            updateFunc(oldBsCurrency, newBsCurrency)
            
            // go back
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
}
