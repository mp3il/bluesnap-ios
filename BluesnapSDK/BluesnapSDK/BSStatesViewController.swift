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
            filteredStates = allStates.filter{(x) -> Bool in (x.name.lowercased().range(of:searchText.lowercased())) != nil }
        }
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
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        filterStates(searchBar?.text ?? "")

        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
        
        if let index = getStateIndex(code: self.selectedCode) {
            let indexPath = IndexPath(row: index, section: 0)
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
        let state = filteredStates[indexPath.row]
        cell.itemNameUILabel.text = state.name
        cell.checkMarkImage.image = nil
        if (state.code == selectedCode) {
            if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                cell.checkMarkImage.image = image
            }
        }
        return cell
    }
    
    // Return # rows to display in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredStates.count
    }
    
    //Tells the delegate that the specified row is now selected.
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        
        // find and deselect previous option
        if let oldIndex = self.getStateIndex(code: selectedCode) {
            let path = IndexPath(row: oldIndex, section: 0)
            selectedCode = ""
            self.tableView.reloadRows(at: [path], with: .none)
        }
        
        // select current option
        let state = filteredStates[didSelectRowAt.row]
        selectedCode = state.code
        self.tableView.reloadRows(at: [didSelectRowAt], with: .none)
        
        // call updateFunc
        updateFunc(selectedCode, state.name)
        
        // go back
        _ = navigationController?.popViewController(animated: true)
    }

}
