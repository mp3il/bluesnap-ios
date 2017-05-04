//
//  ViewController.swift
//  RatesSwiftExample
//
////

import UIKit
import BluesnapSDK

class ViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet weak var currencyButton: UIButton!
	@IBOutlet weak var valueTextField: UITextField!
	@IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var withShippingSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var taxPercentTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    // MARK: private properties
    
    fileprivate var bsToken : BSToken?
    fileprivate var purchaseData = PurchaseData()
 
	// MARK: - UIViewController's methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
		self.view.addGestureRecognizer(tap)
        
        NSLog("Kount Init");
        //Init Kount
        BlueSnapSDK.KountInit();
        
        // get BS token!
        bsToken = BlueSnapSDK.getSandboxTestToken()
        NSLog("Got BS token= \(bsToken!.getTokenStr())")
        resultTextView.text = ""
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
        
        resultTextView.text = ""
        
        // open the purchase screen
        fillPurchaseData()
        BlueSnapSDK.showPurchaseScreen(
            inNavigationController: self.navigationController,
            animated: true,
            bsToken: bsToken!,
            purchaseData: purchaseData,
            withShipping: withShippingSwitch.isOn,
            purchaseFunc: completePurchase)
	}
	
	@IBAction func currencyButtonAction(_ sender: UIButton) {
        
        fillPurchaseData()
        BlueSnapSDK.showCurrencyList(
            inNavigationController: self.navigationController,
            animated: true,
            bsToken: bsToken,
            selectedCurrencyCode: purchaseData.getCurrency(),
            updateFunc: updateViewWithNewCurrency)
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
    
    // MARK: private methods
    private func fillPurchaseData() {
        
        purchaseData.setAmount(amount: (valueTextField.text! as NSString).doubleValue)
        purchaseData.setTaxAmount(taxAmount: (taxTextField.text! as NSString).doubleValue)
        purchaseData.setTaxPercent(taxPercent: (taxPercentTextField.text! as NSString).doubleValue)
        purchaseData.setCurrency(currency: (currencyButton.titleLabel?.text)!)
    }
    
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        purchaseData.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency!)
        valueTextField.text = String(purchaseData.getAmount())
        taxTextField.text = String(purchaseData.getTaxAmount())
        currencyButton.titleLabel?.text = purchaseData.getCurrency()
    }
    
    private func completePurchase(purchaseData: PurchaseData!) {
        print("Here we should call the server to complete the transaction with BlueSnap")
        
        let demo = DemoTreansactions()
        let result : (success:Bool, data: String?) = demo.createCreditCardTransaction(
            paymentDetails: purchaseData,
            bsToken: bsToken!)
        if (result.success == true) {
            resultTextView.text = "BLS transaction created Successfully!\n\n\(result.data!)"
        } else {
            let errorDesc = result.data ?? ""
            resultTextView.text = "An error occurred trying to create BLS transaction.\n\n\(errorDesc)"
        }
    }
}

