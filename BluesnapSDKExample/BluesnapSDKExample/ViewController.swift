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
    @IBOutlet weak var fullBillingSwitch: UISwitch!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    // MARK: private properties
    
    fileprivate var bsToken : BSToken?
    fileprivate var paymentRequest = BSPaymentRequest()
 
	// MARK: - UIViewController's methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		registerTapToHideKeyboard()
        
        //Init Kount
        //NSLog("Kount Init");
        //BlueSnapSDK.KountInit();
        
        generateAndSetBsToken()
        listenForBsTokenExpiration()

        resultTextView.text = ""
        
        // Example of using BSImageLibrary
        if let img = BSImageLibrary.getFlag(countryCode: "US") {
            self.flagImage.image = img
        }
 	}
	
	override func viewWillAppear(_ animated: Bool) {
        
		super.viewWillAppear(animated)
		self.navigationController?.isNavigationBarHidden = true
	}
	
	// MARK: - Dismiss keyboard
	
    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
        } else if taxTextField.isFirstResponder {
            taxTextField.resignFirstResponder()
        } else if taxPercentTextField.isFirstResponder {
            taxPercentTextField.resignFirstResponder()
        }
    }

	// MARK: - Actions
	
	@IBAction func convertButtonAction(_ sender: UIButton) {
        
        resultTextView.text = ""
        
        // for debug - supply initial values:
        if fullBillingSwitch.isOn == true {
            if let billingDetails = paymentRequest.getBillingDetails() {
                billingDetails.name = "John Doe"
                billingDetails.address = "333 elm st"
                billingDetails.city = "New York"
                billingDetails.zip = "532464"
                billingDetails.country = "US"
                billingDetails.state = "MA"
                billingDetails.email = "john@gmail.com"
            }
        }
        if withShippingSwitch.isOn {
            if paymentRequest.getShippingDetails() == nil {
                paymentRequest.setShippingDetails(shippingDetails: BSAddressDetails())
            }
            if let shippingDetails = paymentRequest.getShippingDetails() {
                shippingDetails.name = "Mary Doe"
                shippingDetails.address = "333 elm st"
                shippingDetails.city = "New York"
                shippingDetails.country = "US"
                shippingDetails.state = "MA"
                shippingDetails.email = "mary@gmail.com"
            }
        }
        
        // open the purchase screen
        fillPaymentRequest()
        BlueSnapSDK.showCheckoutScreen(
            inNavigationController: self.navigationController,
            animated: true,
            paymentRequest: paymentRequest,
            withShipping: withShippingSwitch.isOn,
            fullBilling: fullBillingSwitch.isOn,
            purchaseFunc: completePurchase)
	}
	
	@IBAction func currencyButtonAction(_ sender: UIButton) {
        
        fillPaymentRequest()
        BlueSnapSDK.showCurrencyList(
            inNavigationController: self.navigationController,
            animated: true,
            selectedCurrencyCode: paymentRequest.getCurrency(),
            updateFunc: updateViewWithNewCurrency)
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
    
    // MARK: private methods
    
    /**
     Here we adjust the checkout details with the latest amounts from the fields on our view.
    */
    private func fillPaymentRequest() {
        
        let amount = (valueTextField.text! as NSString).doubleValue
        let taxPercent = (taxPercentTextField.text! as NSString).doubleValue
        let taxAmount = (taxTextField.text! as NSString).doubleValue + (taxPercent * amount / 100.0)
        
        paymentRequest.setAmountsAndCurrency(amount: amount, taxAmount: taxAmount, currency: paymentRequest.getCurrency())
    }
    
    /**
     This function is called by the change currency screen when the user changes the currency.
     Here we update yhje checkout details and the fields in our view according tp the new currency.
    */
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        paymentRequest.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency!)
        valueTextField.text = String(paymentRequest.getAmount())
        taxTextField.text = String(paymentRequest.getTaxAmount())
        currencyButton.titleLabel?.text = paymentRequest.getCurrency()
    }
    
    /**
     This is the callback we pass to BlueSnap SDK; it will be called when all the shopper details have been
     enetered, and the secured payment details have been successfully submitted to BlueSnap server.
     In a real app, you would send the checkout details to your app server, which then would call BlueSnap API
     to execute the purchase.
     In this sample app we do it client-to-server, but this is not the way to do it in a real app.
    */
    private func completePurchase(paymentRequest: BSPaymentRequest!) {
        
        let demo = DemoTreansactions()
        let result : (success:Bool, data: String?) = demo.createCreditCardTransaction(
            paymentRequest: paymentRequest,
            bsToken: bsToken!)
        logResultDetails(result)
        if (result.success == true) {
            resultTextView.text = "BLS transaction created Successfully!\n\n\(result.data!)"
        } else {
            let errorDesc = result.data ?? ""
            resultTextView.text = "An error occurred trying to create BLS transaction.\n\n\(errorDesc)"
        }
    }
    
    private func logResultDetails(_ result : (success:Bool, data: String?)) {
        
        NSLog("--------------------------------------------------------")
        NSLog("Result success: \(result.success)")
        if let billingDetails = paymentRequest.getBillingDetails() {
            NSLog("Result Data: Name:\(billingDetails.name)")
            if let zip = billingDetails.zip {
                NSLog(" Zip code:\(zip)")
            }
            if self.fullBillingSwitch.isOn {
                NSLog(" Email:\(billingDetails.email ?? "")")
                NSLog(" Street address:\(billingDetails.address ?? "")")
                NSLog(" City:\(billingDetails.city ?? "")")
                NSLog(" Country code:\(billingDetails.country ?? "")")
                NSLog(" State code:\(billingDetails.state ?? "")")
            }
        }
        if let shippingDetails = paymentRequest.getShippingDetails() {
            NSLog("Shipping Data: Name:\(shippingDetails.name)")
            NSLog(" Zip code:\(shippingDetails.zip ?? "")")
            NSLog(" Email:\(shippingDetails.email ?? "")")
            NSLog(" Street address:\(shippingDetails.address ?? "")")
            NSLog(" City:\(shippingDetails.city ?? "")")
            NSLog(" Country code:\(shippingDetails.country ?? "")")
            NSLog(" State code:\(shippingDetails.state ?? "")")
        }
        NSLog("--------------------------------------------------------")
    }
    
    // MARK: BS Token functions
    
    /**
     Create a test BS token and set it in BlueSnapSDK.
     In a real app, you would get the token from your app server.
     */
    func generateAndSetBsToken() {
        
        do {
            bsToken = try BlueSnapSDK.createSandboxTestToken()
            BlueSnapSDK.setBsToken(bsToken: bsToken)
        } catch {
            NSLog("Error: Failed to get BS token")
            fatalError()
        }
        NSLog("Got BS token= \(bsToken!.getTokenStr())")
    }
    
    /**
     Add observer to the token expired event sent by BlueSnap SDK.
    */
    func listenForBsTokenExpiration() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(bsTokenExpired), name: Notification.Name.bsTokenExpirationNotification, object: nil)
    }
    
    /**
     Called by the observer to the token expired event sent by BlueSnap SDK.
     Here we generate and set a new token, so that when the user tries again, the action will succeed.
     */
    func bsTokenExpired() {
        
        NSLog("Got BS token expiration notification!")
        generateAndSetBsToken()
    }
}

