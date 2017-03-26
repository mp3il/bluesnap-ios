//
//  BSCurrencyList.swift
//  BS
//
//

import UIKit

class RatesCurrencyList: UITableViewController {

	// MARK: - Constants
	
	fileprivate let reuseIdentifier = "currencyCellReuseIdentifier"
	
	// MARK: - Public properties
	
	internal var sender: UIButton?
	
	// MARK: - Data
	
	fileprivate var currencyManager = BSCurrencyManager()
	fileprivate var data = Array<BSCurrencyModel!>()
	
	// MARK: - UIViewController's methods
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.clearsSelectionOnViewWillAppear = false
		self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: reuseIdentifier)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Get data
		currencyManager.fetchData {[weak self] (data: [AnyObject]?, error: NSError?) -> Void in
			if error! == nil {
				self!.data.removeAll()
				for item in data! {
					self!.data.append(item as! BSCurrencyModel)
				}
				self!.tableView.reloadData()
			}
		}
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		let currency = data[indexPath.row]
		cell.textLabel?.text = currency?.code
		
		return cell
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let currency = data[indexPath.row]
		sender?.setTitle(currency?.code, for: UIControlState())
		sender?.setTitle(currency?.code, for: UIControlState.highlighted)
		dismiss(animated: true, completion: nil)
	}

}
