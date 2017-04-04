//
//  ViewController.swift
//  RatesSwiftExample
//
////

import UIKit
import BluesnapSDK

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	
	// MARK: - Outlets
	
	@IBOutlet weak var currencyButton: UIButton!
	@IBOutlet weak var valueTextField: UITextField!
	@IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var withShippingSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
	
	// MARK: - UIViewController's methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
		self.view.addGestureRecognizer(tap)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.isNavigationBarHidden = true
	}
	
	// MARK: - Dismiss keyboard
	
	func dismissKeyboard() {
		valueTextField.resignFirstResponder()
	}

	// MARK: - Actions
	
	@IBAction func convertButtonAction(_ sender: UIButton) {
		let amount = (valueTextField.text! as NSString).doubleValue
        let tax = (taxTextField.text! as NSString).doubleValue
        BlueSnapSDK.showSummaryScreen(amount,
                taxAmount : tax, currency: (currencyButton.titleLabel?.text)!,
                withShipping: withShippingSwitch.isOn,
                inNavigationController: self.navigationController, animated: true)
	}
	
	@IBAction func currencyButtonAction(_ sender: UIButton) {
		BlueSnapSDK.showCurrencyList(sender, inViewController: self, animated: true)
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}

}

