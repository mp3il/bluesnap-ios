//
//  BSStatesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 27/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSStatesViewController : BSBaseListController {
    
    // MARK: puclic properties
    
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
    fileprivate var filteredItems : [(name: String, code: String)] = []
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: init
    
    func initStates(selectedCode: String!, allStates : [(name: String, code: String)], updateFunc : @escaping (String, String)->Void) {
        self.allStates = allStates
        self.updateFunc = updateFunc
        
        for state in allStates {
            if state.code == selectedCode {
                self.selectedItem = state
                break
            }
        }
    }

    // MARK: Override functions of BSBaseListController
    
    override func doFilter(_ searchText : String) {
        
        if searchText == "" {
            self.filteredItems = self.allStates
        } else {
            filteredItems = allStates.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
        }
        generateGroups()
        self.tableView.reloadData()
    }
    
    override func getMySearchBar() -> UISearchBar? {
        return self.searchBar
    }
    
    override func setMySearchBar(_ searchBar : UISearchBar) {
        self.searchBar = searchBar
    }
    
    override func getMyTableView() -> UITableView? {
        return self.tableView
    }
    
    override func selectItem(newItem: (name: String, code: String)) {
        updateFunc(newItem.code, newItem.name)
    }
    
    override func createTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "StateTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSStateTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        let firstLetter = groupSections[indexPath.section]
        if let state = groups[firstLetter]?[indexPath.row] {
            cell.itemNameUILabel.text = state.name
            cell.checkMarkImage.image = nil
            if (state.code == selectedItem.code) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImage.image = image
                }
            } else {
                cell.checkMarkImage.image = nil
            }
        }
        return cell
    }
    
    // MARK: private functions
    
    private func generateGroups() {
        
        groups = [String: [(name: String, code: String)]]()
        for state: (name: String, code: String) in filteredItems {
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
    
    
}
