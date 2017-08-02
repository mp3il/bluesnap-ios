//
//  BSStatesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 27/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSStatesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: puclic properties
    
    internal var selectedCode : String = ""

    // data: state codes and names
    internal var allStates : [(name: String, code: String)] = []
    
    // the callback function that gets called when a state is selected;
    // this is just a default
    internal var updateFunc : (String, String)->Void = {
        code, name in
        NSLog("state \(code):\(name) was selected")
    }
    
    // MARK: private properties
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var filteredStates : [(name: String, code: String)] = []
    fileprivate var groups = [String: [(name: String, code: String)]]()
    fileprivate var groupSections = [String]()

    
    // MARK: Search bar stuff
    
    fileprivate var searchBar : UISearchBar?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchBar = searchBar
        filterStates(searchText)
    }
    
    private func filterStates(_ searchText : String) {
        
        if searchText == "" {
            self.filteredStates = self.allStates
        } else {
            filteredStates = allStates.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
        }
        generateGroups()
        self.tableView.reloadData()
    }
    
    private func getStateIndex(code: String) -> Int? {
        
        for (index, country) in filteredStates.enumerated() {
            if country.code == code {
                return index
            }
        }
        return nil
    }
    
    // UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar : UISearchBar) {
        searchBar.text = ""
        filterStates("")
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
        
        filterStates(searchBar?.text ?? "")

        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
        
        // scroll to selected
        if let indexPath = getIndex(ofValue: selectedCode) {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    
    // Create a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "StateTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSStateTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        let firstLetter = groupSections[indexPath.section]
        if let state = groups[firstLetter]?[indexPath.row] {
            cell.itemNameUILabel.text = state.name
            cell.checkMarkImage.image = nil
            if (state.code == selectedCode) {
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
        
        // find and deselect previous option
        if let indexPath = getIndex(ofValue: selectedCode) {
            selectedCode = ""
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // select current option
        let firstLetter = groupSections[didSelectRowAt.section]
        let state = groups[firstLetter]![didSelectRowAt.row]
        selectedCode = state.code
        self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
        
        // call updateFunc
        updateFunc(selectedCode, state.name)
        
        // go back
        _ = navigationController?.popViewController(animated: true)
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
        
        groups = [String: [(name: String, code: String)]]()
        for state: (name: String, code: String) in filteredStates {
            let name = state.name
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if var stateByFirstLetter = groups[firstLetter] {
                stateByFirstLetter.append(state)
                groups[firstLetter] = stateByFirstLetter
            } else {
                groups[firstLetter] = [state]
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
