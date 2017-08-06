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
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var fullBillingSwitch: UISwitch!
    
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
        setApplePayIdentifier()
        listenForBsTokenExpiration()

        resultTextView.text = ""
        
        // Example of using BSImageLibrary
        //if let img = BSImageLibrary.getFlag(countryCode: "US") {
        //}
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
        }
    }

	// MARK: - Actions
	
	@IBAction func convertButtonAction(_ sender: UIButton) {
        
        resultTextView.text = ""
        
        // If you have the shopper details, you can supply initial values like this:
        //setInitialShopperDetails()
        
        // Override the navigation name, so that the next screen navigation item will say "Cancel"
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem

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
            updateFunc: updateViewWithNewCurrency,
            errorFunc: { self.showErrorAlert(message: "Failed to display currency List, please try again") })
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
    
    // MARK: private methods
    
    /**
        If you have the shopper details, you can supply initial values to the BlueSnap purchasde flow.
        This is just an exmaple with hard-coded values.
        You can supply partial data as you have it.
    */
    private func setInitialShopperDetails() {
        
        if let billingDetails = paymentRequest.getBillingDetails() {
            billingDetails.name = "John Doe"
            billingDetails.address = "333 elm st"
            billingDetails.city = "New York"
            billingDetails.zip = "532464"
            billingDetails.country = "US"
            billingDetails.state = "MA"
            billingDetails.email = "john@gmail.com"
        }
        if withShippingSwitch.isOn {
            if paymentRequest.getShippingDetails() == nil {
                paymentRequest.setShippingDetails(shippingDetails: BSShippingAddressDetails())
            }
            if let shippingDetails = paymentRequest.getShippingDetails() {
                shippingDetails.name = "Mary Doe"
                shippingDetails.address = "333 elm st"
                shippingDetails.city = "New York"
                shippingDetails.country = "US"
                shippingDetails.state = "MA"
            }
        }
    }
    
    /**
     Show error pop-up
     */
    private func showErrorAlert(message: String) {
        let alert = createErrorAlert(title: "Oops", message: message)
        present(alert, animated: true, completion: nil)
    }

    private func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }

    /**
     Here we adjust the checkout details with the latest amounts from the fields on our view.
    */
    private func fillPaymentRequest() {
        
        let amount = (valueTextField.text! as NSString).doubleValue
        let taxAmount = (taxTextField.text! as NSString).doubleValue
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
        
        if let resultPaymentDetails = paymentRequest.getResultPaymentDetails() {
            if resultPaymentDetails.paymentType == BSPaymentType.CreditCard {
                if let ccDetails = resultPaymentDetails as? BSResultCcDetails {
                    print("CC Issuing country: \(ccDetails.ccIssuingCountry ?? "")")
                    print("CC type: \(ccDetails.ccType ?? "")")
                    print("CC last 4 digits: \(ccDetails.last4Digits ?? "")")
                }
            }
        }
        let demo = DemoTreansactions()
        var result: (success: Bool, data: String?) = (false, nil)


        if paymentRequest.getResultPaymentDetails() is BSResultCcDetails {
            result = demo.createCreditCardTransaction(
                    paymentRequest: paymentRequest,
                    bsToken: bsToken!)
            logResultDetails(result, paymentRequest: paymentRequest)

        } else if paymentRequest.getResultPaymentDetails() is BSResultApplePayDetails {

            result = demo.createApplePayTransaction(paymentRequest: paymentRequest,
                    bsToken: bsToken!)
            logResultDetails(result, paymentRequest: paymentRequest)
        }

        if result.success == true {
            NSLog("BLS transaction created Successfully!\n\n\(result.data!)")
            showThankYouScreen(errorText: nil)
        } else {
            let errorText = result.data ?? ""
            NSLog("An error occurred trying to create BLS transaction.\n\n\(errorText)")
            showThankYouScreen(errorText: errorText)
        }
    }
    
    
    private func showThankYouScreen(errorText: String?) {
        
        // Show thank you screen (ThankYouViewController)
        if let thankYouScreen = storyboard?.instantiateViewController(withIdentifier: "ThankYouViewController") as? ThankYouViewController {
            thankYouScreen.errorText = errorText
            self.navigationController?.pushViewController(thankYouScreen, animated: true)
        } else {
            resultTextView.text = "An error occurred trying to show the Thank You screen."
        }
    }
    
    private func logResultDetails(_ result : (success:Bool, data: String?), paymentRequest: BSPaymentRequest!) {
        
        NSLog("--------------------------------------------------------")
        NSLog("Result success: \(result.success)")
        
        NSLog(" amount=\(paymentRequest.getAmount() ?? 0.0)")
        NSLog(" tax=\(paymentRequest.getTaxAmount() ?? 0.0)")
        NSLog(" currency=\(paymentRequest.getCurrency() ?? "")")
        
        if let billingDetails = paymentRequest.getBillingDetails() {
            NSLog("Result Data: Name:\(billingDetails.name ?? "")")
            if let zip = billingDetails.zip {
                NSLog(" Zip code:\(zip)")
            }
            if let email = billingDetails.email {
                NSLog(" Email:\(email)")
            }
            if self.fullBillingSwitch.isOn {
                NSLog(" Street address:\(billingDetails.address ?? "")")
                NSLog(" City:\(billingDetails.city ?? "")")
                NSLog(" Country code:\(billingDetails.country ?? "")")
                NSLog(" State code:\(billingDetails.state ?? "")")
            }
        }
        
        if let shippingDetails = paymentRequest.getShippingDetails() {
            NSLog("Shipping Data: Name:\(shippingDetails.name ?? "")")
            NSLog(" Phone:\(shippingDetails.phone ?? "")")
            NSLog(" Zip code:\(shippingDetails.zip ?? "")")
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
            //// simulate expired token for first time
            //let simulateTokenExpired = bsToken == nil
            bsToken = try BlueSnapSDK.createSandboxTestToken()
            //if simulateTokenExpired {
            //    bsToken = BSToken(tokenStr: "5e2e3f50e287eab0ba20dc1712cf0f64589c585724b99c87693a3326e28b1a3f_", serverUrl: bsToken?.getServerUrl())
            //}
            BlueSnapSDK.setBsToken(bsToken: bsToken)
        } catch {
            NSLog("Error: Failed to get BS token")
            fatalError()
        }
        NSLog("Got BS token= \(bsToken!.getTokenStr())")
    }

    func setApplePayIdentifier() {
        BlueSnapSDK.setApplePayMerchantIdentifier(merchantId: "merchant.com.example.bluesnap")
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

