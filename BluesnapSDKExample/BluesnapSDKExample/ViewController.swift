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
    fileprivate var paymentDetails = BSPaymentDetails()
 
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
        fillPaymentDetails()
        BlueSnapSDK.showPurchaseScreen(
            inNavigationController: self.navigationController,
            animated: true,
            bsToken: bsToken!,
            paymentDetails: paymentDetails,
            withShipping: withShippingSwitch.isOn,
            purchaseFunc: completePurchase)
	}
	
	@IBAction func currencyButtonAction(_ sender: UIButton) {
        
        fillPaymentDetails()
        BlueSnapSDK.showCurrencyList(
            inNavigationController: self.navigationController,
            animated: true,
            bsToken: bsToken,
            selectedCurrencyCode: paymentDetails.getCurrency(),
            updateFunc: updateViewWithNewCurrency)
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
    
    // MARK: private methods
    private func fillPaymentDetails() {
        
        let amount = (valueTextField.text! as NSString).doubleValue
        let taxPercent = (taxPercentTextField.text! as NSString).doubleValue
        let taxAmount = (taxTextField.text! as NSString).doubleValue + (taxPercent * amount / 100.0)
        
        paymentDetails.setAmountsAndCurrency(amount: amount, taxAmount: taxAmount, currency: (currencyButton.titleLabel?.text)!)
    }
    
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        print("before change currency: currency=\(paymentDetails.getCurrency()), amount = \(paymentDetails.getAmount())")
        paymentDetails.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency!)
        print("after change currency: currency=\(paymentDetails.getCurrency()), amount = \(paymentDetails.getAmount())")
        valueTextField.text = String(paymentDetails.getAmount())
        taxTextField.text = String(paymentDetails.getTaxAmount())
        currencyButton.titleLabel?.text = paymentDetails.getCurrency()
    }
    
    private func completePurchase(paymentDetails: BSPaymentDetails!) {
        print("Here we should call the server to complete the transaction with BlueSnap")
        
        let demo = DemoTreansactions()
        let result : (success:Bool, data: String?) = demo.createCreditCardTransaction(
            paymentDetails: paymentDetails,
            bsToken: bsToken!)
        if (result.success == true) {
            resultTextView.text = "BLS transaction created Successfully!\n\n\(result.data!)"
        } else {
            let errorDesc = result.data ?? ""
            resultTextView.text = "An error occurred trying to create BLS transaction.\n\n\(errorDesc)"
        }
    }
}

