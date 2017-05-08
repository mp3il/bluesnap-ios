//
//  BSStatesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 27/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSStatesViewController : UITableViewController {
    
    // MARK: puclic properties
    
    internal var selectedCode : String = ""
    // data: state codes and names
    internal var states : [String : String] = [:]
    
    // the callback function that gets called when a state is selected;
    // this is just a default
    internal var updateFunc : (String, String)->Void = {
        code, name in
        NSLog("state \(code):\(name) was selected")
    }
    
    // MARK: private properties
    
    // selected state name and index
    fileprivate var selectedName : String = ""
    fileprivate var selectedIndexPath : IndexPath?
    
    // data: state codes and names (matching arrays)
    fileprivate var codes : [String] = []
    fileprivate var names : [String] = []
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for (code, name) in states {
            names.append(name)
            codes.append(code)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
        
        if let index = codes.index(of: self.selectedCode) {
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
        
        return codes.count
    }
    
    // "draw" a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "StateTableViewCell", for: indexPath)
        guard let cell = reusableCell as? BSStateTableViewCell else {
            fatalError("The cell item is not an instancre of the right class")
        }
        let name : String = names[indexPath.row]
        let code : String = codes[indexPath.row]
        cell.itemNameUILabel.text = name
        cell.checkMarkImage.image = nil
        if (code == selectedCode) {
            if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                cell.checkMarkImage.image = image
            }
            selectedIndexPath = indexPath
        }
        return cell
    }
    
    // When a cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCode = codes[indexPath.row]
        selectedName = names[indexPath.row]
        
        // deselect previous option
        if let selectedIndexPath = selectedIndexPath {
            self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
        
        // select current option
        selectedIndexPath = indexPath
        if let selectedIndexPath = selectedIndexPath {
            self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
        
        // call updateFunc
        updateFunc(selectedCode, selectedName)
    }
}
