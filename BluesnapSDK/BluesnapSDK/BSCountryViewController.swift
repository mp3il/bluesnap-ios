//
//  BSCountryViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 23/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSCountryViewController : UITableViewController {
    
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
    
    // data: country codes and names (matching arrays)
    fileprivate var countryCodes : [String] = []
    fileprivate var countryNames : [String] = []
    
    // selected country name and index
    fileprivate var selectedCountryName : String = ""
    fileprivate var selectedCountryIndexPath : IndexPath?
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get country data
        if let manager = countryManager {
            countryCodes = manager.getCountryCodes()
            for countryCode in countryCodes {
                if let countryName = manager.getCountryName(countryCode: countryCode) {
                    countryNames.append(countryName)
                } else {
                    countryNames.append("Unbknown")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
    }
    
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // return #rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.countryCodes.count
    }
    
    // "draw" a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSCountryTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        let countryName : String = countryNames[indexPath.row]
        let countryCode : String = countryCodes[indexPath.row]
        cell.itemNameUILabel.text = countryName
        if (countryCode == selectedCountryCode) {
            cell.isCurrentUILabel.text = "V"
            selectedCountryIndexPath = indexPath
        } else {
            cell.isCurrentUILabel.text = ""
        }
        return cell
    }
    
    // When a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCountryCode = countryCodes[indexPath.row]
        selectedCountryName = countryNames[indexPath.row]
        
        // deselect previous option
        if let selectedCountryIndexPath = selectedCountryIndexPath {
            self.tableView.reloadRows(at: [selectedCountryIndexPath], with: .none)
        }
        
        // select current option
        selectedCountryIndexPath = indexPath
        if let selectedCountryIndexPath = selectedCountryIndexPath {
            self.tableView.reloadRows(at: [selectedCountryIndexPath], with: .none)
        }
        
        // call updateFunc
        updateFunc(selectedCountryCode, selectedCountryName)
    }
}
