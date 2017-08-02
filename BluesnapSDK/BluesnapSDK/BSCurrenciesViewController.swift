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
    fileprivate var groups = [String: [BSCurrency]]()
    fileprivate var groupSections = [String]()

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
            let filtered = bsCurrencies.currencies.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
            filteredCurrencies = BSCurrencies(currencies: filtered)
        } else {
            filteredCurrencies = BSCurrencies(currencies: [])
        }
        generateGroups()
        self.tableView.reloadData()
    }
    
    // UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar : UISearchBar) {
        searchBar.text = ""
        filterCurrencies("")
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
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
        if let indexPath = getIndex(ofValue: selectedCurrencyCode) {
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
        let firstLetter = groupSections[indexPath.section]
        if let bsCurrency = groups[firstLetter]?[indexPath.row] {
            cell.CurrencyUILabel.text = bsCurrency.getName() + " " + bsCurrency.getCode()
            cell.checkMarkImage.image = nil
            if (bsCurrency.getCode() == selectedCurrencyCode) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImage.image = image
                }
            } else {
                cell.checkMarkImage.image = nil
            }
        }
        return cell
    }
    
    // Return # rows to display in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let firstLetter = groupSections[section]
        if let valuesOfSection = groups[firstLetter] {
            return valuesOfSection.count
        } else {
            return 0
        }
    }
    
    //Tells the delegate that the specified row is now selected.
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        
        if let bsCurrencies = bsCurrencies {
            
            // find and deselect previous option
            let oldBsCurrency : BSCurrency? = bsCurrencies.getCurrencyByCode(code: selectedCurrencyCode)
            if let indexPath = getIndex(ofValue: selectedCurrencyCode) {
                selectedCurrencyCode = ""
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            // select current option
            let firstLetter = groupSections[didSelectRowAt.section]
            let newBsCurrency : BSCurrency = groups[firstLetter]![didSelectRowAt.row]
            selectedCurrencyCode = newBsCurrency.getCode()
            self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
            
            // call updateFunc
            updateFunc(oldBsCurrency, newBsCurrency)
            
            // lose focus on search bar
            if let searchBar = self.searchBar {
                searchBar.resignFirstResponder()
            }

            // go back
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupSections[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return groupSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    // MARK: group sections and index
    
    
    func generateGroups() {
        
        groups = [String: [BSCurrency]]()
        for currency: BSCurrency in (filteredCurrencies?.currencies)! {
            let name = currency.getName() ?? " "
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if var currenciesByFirstLetter = groups[firstLetter] {
                currenciesByFirstLetter.append(currency)
                groups[firstLetter] = currenciesByFirstLetter
            } else {
                groups[firstLetter] = [currency]
            }
        }
        groupSections = [String](groups.keys)
        groupSections = groupSections.sorted()
    }
    
    func getIndex(ofValue: String) -> IndexPath? {
        
        if ofValue.characters.count > 0 {
            let firstLetter = "\(ofValue[ofValue.startIndex])".uppercased()
            if let section = groups[firstLetter] {
                var index = 0
                for currency: BSCurrency in section {
                    if currency.getCode() == ofValue {
                        let row = groupSections.index(of: firstLetter)
                        let indexPath = IndexPath(row: index, section: row!)
                        return indexPath
                    }
                    index = index + 1
                }
            }
        }
        return nil
    }
}
