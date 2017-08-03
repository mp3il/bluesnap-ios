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
    fileprivate var groups = [String: [(name: String, code: String)]]()
    fileprivate var groupSections = [String]()

    @IBOutlet weak var searchBar: UISearchBar!
    
    let SECTION_HEADER_LABEL_HEIGHT: CGFloat = 15
    let SECTION_HEADER_MARGIN: CGFloat = 5

    // MARK: Search bar stuff
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchBar = searchBar
        filterCountries(searchText)
    }
    
    private func filterCountries(_ searchText : String) {
        
        if searchText == "" {
            self.filteredCountries = self.countries
        } else {
            filteredCountries = countries.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
        }
        generateGroups()
        self.tableView.reloadData()
    }
    

    
    // UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar : UISearchBar) {
        searchBar.text = ""
        filterCountries("")
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
        
        // Get country data
        if let manager = countryManager {
            let countryCodes = manager.getCountryCodes()
            for countryCode in countryCodes {
                if let countryName = manager.getCountryName(countryCode: countryCode) {
                    countries.append((name: countryName, code: countryCode))
                }
            }
        }
        
        // add thin border below the searchBar
        let border = CALayer()
        border.frame = CGRect(x: 0, y: searchBar.frame.height-1, width: searchBar.frame.width, height: 0.5)
        border.backgroundColor = UIColor.lightGray.cgColor
        searchBar.layer.addSublayer(border)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        filterCountries(searchBar?.text ?? "")
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
        
        // scroll to selected
        if let indexPath = getIndex(ofValue: selectedCountryCode) {
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
        
        let firstLetter = groupSections[indexPath.section]
        if let country = groups[firstLetter]?[indexPath.row] {
            cell.itemNameUILabel.text = country.name
            cell.checkMarkImageView.image = nil
            if (country.code == selectedCountryCode) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImageView.image = image
                }
            }
            // load the flag image
            cell.flagImageView.image = nil
            if let image = BSViewsManager.getImage(imageName: country.code.uppercased()) {
                cell.flagImageView.image = image
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
        
        // find and deselect previous option
        if let indexPath = getIndex(ofValue: selectedCountryCode) {
            selectedCountryCode = ""
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }

        // select current option
        let firstLetter = groupSections[didSelectRowAt.section]
        let country = groups[firstLetter]![didSelectRowAt.row]
        selectedCountryCode = country.code
        self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
        
        // call updateFunc
        updateFunc(selectedCountryCode, country.name)
        
        // go back
        _ = navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupSections.count
    }
        
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return groupSections
    }
    
    // return height of section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_LABEL_HEIGHT + 2*SECTION_HEADER_MARGIN
    }
    
    // return height of section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // create a section cell
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect(x: 0, y: SECTION_HEADER_MARGIN, width: self.view.frame.width, height: SECTION_HEADER_LABEL_HEIGHT))
        label.text = groupSections[section]
        label.font.withSize(SECTION_HEADER_LABEL_HEIGHT)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SECTION_HEADER_LABEL_HEIGHT + 2*SECTION_HEADER_MARGIN))
        view.addSubview(label)
        
        return view
    }

    // MARK: group sections and index
    
    
    func generateGroups() {
        
        groups = [String: [(name: String, code: String)]]()
        for country: (name: String, code: String) in filteredCountries {
            let name = country.name
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if var countriesByFirstLetter = groups[firstLetter] {
                countriesByFirstLetter.append(country)
                groups[firstLetter] = countriesByFirstLetter
            } else {
                groups[firstLetter] = [country]
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
                for country: (name: String, code: String) in section {
                    if country.code == ofValue {
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
