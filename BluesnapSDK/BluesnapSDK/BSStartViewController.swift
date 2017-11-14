//
//  StartViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit
import PassKit

class BSStartViewController: UIViewController {

    // MARK: - private properties

    internal var supportedPaymentMethods: [String]?

    var paymentSummaryItems: [PKPaymentSummaryItem] = [];
    internal var activityIndicator : UIActivityIndicatorView?
    internal var payPalPurchaseDetails: BSPayPalSdkResult!
    internal var existingCardViews : [BSExistingCcUIView] = []
    internal var showPayPal : Bool = false
    internal var showApplePay : Bool = false

    // MARK: Outlets

    @IBOutlet weak var centeredView: UIView!
    @IBOutlet weak var ccnButton: BSPaymentTypeView!
    @IBOutlet weak var applePayButton: BSPaymentTypeView!
    @IBOutlet weak var payPalButton: BSPaymentTypeView!

    // MARK: init
    
    func initScreen() {
        
        self.supportedPaymentMethods = BSApiManager.supportedPaymentMethods
    }
    
    // MARK: UIViewController functions

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false

        // Hide/show the buttons and position them automatically
        showPayPal = BSApiManager.isSupportedPaymentMethod(paymentType: BSPaymentType.PayPal, supportedPaymentMethods: supportedPaymentMethods)
        showApplePay = BlueSnapSDK.applePaySupported(supportedPaymentMethods: supportedPaymentMethods, supportedNetworks: BlueSnapSDK.applePaySupportedNetworks).canMakePayments
        //self.hideShowElements()
        
        // Localize strings
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Type)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopActivityIndicator()
    }

    // MARK: button functions

    @IBAction func applePayClick(_ sender: Any) {

        let applePaySupported = BlueSnapSDK.applePaySupported(supportedPaymentMethods: supportedPaymentMethods, supportedNetworks: BlueSnapSDK.applePaySupportedNetworks)

        if (!applePaySupported.canMakePayments) {
            let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Apple_Pay, message: BSLocalizedString.Error_Not_available_on_this_device)
            present(alert, animated: true, completion: nil)
            return;
        }

        if (!applePaySupported.canSetupCards) {
            let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Apple_Pay, message: BSLocalizedString.Error_No_cards_set)
            present(alert, animated: true, completion: nil)
            return;
        }

        if BSApplePayConfiguration.getIdentifier() == nil {
            let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Apple_Pay, message: BSLocalizedString.Error_Setup_error)
            NSLog("Missing merchant identifier for apple pay")
            present(alert, animated: true, completion: nil)
            return;
        }


        applePayPressed(sender, completion: { (error) in
            DispatchQueue.main.async {
                if error == BSErrors.applePayCanceled {
                    NSLog("Apple Pay operation canceled")
                    return
                } else if error != nil {
                    let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_Apple_Pay, message: BSLocalizedString.Error_General_ApplePay_error)
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    _ = self.navigationController?.popViewController(animated: false)
                    // execute callback
                    let applePayPurchaseDetails = BSApplePaySdkResult(sdkRequest: BlueSnapSDK.sdkRequest!)
                    BlueSnapSDK.sdkRequest?.purchaseFunc(applePayPurchaseDetails)
                }
            }
        })

    }

    @IBAction func ccDetailsClick(_ sender: Any) {

        let backItem = UIBarButtonItem()
        backItem.title = BSLocalizedStrings.getString(BSLocalizedString.Navigate_Back_to_payment_type_screen)
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed

        animateToPaymentScreen(startY: self.ccnButton.frame.minY, completion: { animate in
            _ = BSViewsManager.showCCDetailsScreen(existingCcPurchaseDetails: nil, inNavigationController: self.navigationController, animated: animate)
        })
    }
    
    @IBAction func payPalClicked(_ sender: Any) {
        
        payPalPurchaseDetails = BSPayPalSdkResult(sdkRequest: BlueSnapSDK.sdkRequest!)
        
        DispatchQueue.main.async {
            self.startActivityIndicator()
        }
        
        DispatchQueue.main.async {
            BSApiManager.createPayPalToken(purchaseDetails: self.payPalPurchaseDetails, withShipping: BlueSnapSDK.sdkRequest!.withShipping, completion: { resultToken, resultError in
                
                if let resultToken = resultToken {
                    self.stopActivityIndicator()
                    DispatchQueue.main.async {
                        BSViewsManager.showBrowserScreen(inNavigationController: self.navigationController, url: resultToken, shouldGoToUrlFunc: self.paypalUrlListener)
                    }
                } else {
                    let errMsg = resultError == .paypalUnsupportedCurrency ? BSLocalizedString.Error_PayPal_Currency_Not_Supported : BSLocalizedString.Error_General_PayPal_error
                    let alert = BSViewsManager.createErrorAlert(title: BSLocalizedString.Error_Title_PayPal, message: errMsg)
                    self.stopActivityIndicator()
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    

    // Mark: private functions

    
    private func hideShowElements() {
        
        var existingCreditCards: [BSCreditCardInfo] = []
        if let shopper = BSApiManager.shopper {
            existingCreditCards = shopper.existingCreditCards
        }
        let numSections = existingCreditCards.count +
            ((showPayPal && showApplePay) ? 3 : (!showPayPal && !showApplePay) ? 1 : 2)
        var sectionNum : CGFloat = 0
        let sectionY : CGFloat = (centeredView.frame.height / CGFloat(numSections+1)).rounded()
        
        if showApplePay {
            applePayButton.isHidden = false
            sectionNum = sectionNum + 1
            applePayButton.center.y = sectionY * sectionNum
        } else {
            
            applePayButton.isHidden = true
        }
        sectionNum = sectionNum + 1
        ccnButton.center.y = sectionY * sectionNum

        if showPayPal {
            sectionNum = sectionNum + 1
            payPalButton.isHidden = false
            payPalButton.center.y = sectionY * sectionNum
        } else {
            payPalButton.isHidden = true
        }
        
        let newCcRect = self.ccnButton.frame
        
        if existingCreditCards.count > 0 && existingCardViews.count == 0 {
            var tag : Int = 0
            for existingCreditCard in existingCreditCards {
                let cardView = BSExistingCcUIView()
                self.centeredView.addSubview(cardView)
                cardView.frame = CGRect(x: newCcRect.minX, y: newCcRect.minY, width: newCcRect.width, height: newCcRect.height)
                sectionNum = sectionNum + 1
                cardView.center.y = sectionY * sectionNum
                cardView.setCc(
                    ccType: existingCreditCard.creditCard.ccType ?? "",
                    last4Digits: existingCreditCard.creditCard.last4Digits ?? "",
                    expiration: existingCreditCard.creditCard.getExpiration())
                cardView.resizeElements()
                cardView.addTarget(self, action: #selector(BSStartViewController.existingCCTouchUpInside(_:)), for: .touchUpInside)
                cardView.tag = tag
                cardView.isAccessibilityElement = true
                let accessibilityIdentifier = "existingCc\(tag)"
                cardView.accessibilityIdentifier = accessibilityIdentifier
                cardView.isUserInteractionEnabled = true
                cardView.accessibilityTraits = UIAccessibilityTraitButton
                tag = tag + 1
            }
        }
    }
    
    func existingCCTouchUpInside(_ sender: Any) {
        
        if let existingCcUIView = sender as? BSExistingCcUIView, let existingCreditCards = BSApiManager.shopper?.existingCreditCards {
            let ccIdx = existingCcUIView.tag
            let cc = existingCreditCards[ccIdx]
            animateToPaymentScreen(startY: existingCcUIView.frame.minY, completion: { animate in
                
                let purchaseDetails = BSExistingCcSdkResult(sdkRequest: BlueSnapSDK.sdkRequest!, shopper: BSApiManager.shopper, existingCcDetails: cc)
                _ = BSViewsManager.showExistingCCDetailsScreen(purchaseDetails: purchaseDetails, inNavigationController: self.navigationController, animated: animate)
            })
        }
        
    }
    
    private func animateToPaymentScreen(startY: CGFloat, completion: ((Bool) -> Void)!) {

        let moveUpBy = self.centeredView.frame.minY + startY - 48
        UIView.animate(withDuration: 0.3, animations: {
            self.centeredView.center.y = self.centeredView.center.y - moveUpBy
        }, completion: { animate in
            completion(false)
            self.centeredView.center.y = self.centeredView.center.y + moveUpBy
        })
    }

    
    private func paypalUrlListener(url: String) -> Bool {
        
        if BSPaypalHandler.isPayPalProceedUrl(url: url) {
            // paypal success!
            
            BSPaypalHandler.parsePayPalResultDetails(url: url, purchaseDetails: self.payPalPurchaseDetails)
            
            // return to merchant screen
            if let viewControllers = navigationController?.viewControllers {
                let merchantControllerIndex = viewControllers.count - 3
                _ = navigationController?.popToViewController(viewControllers[merchantControllerIndex], animated: false)
            }
            
            // execute callback
            BlueSnapSDK.sdkRequest?.purchaseFunc(self.payPalPurchaseDetails)
            return false
            
        } else if BSPaypalHandler.isPayPalCancelUrl(url: url) {
            // PayPal cancel URL detected - close web screen
            _ = navigationController?.popViewController(animated: false)
            return false
            
        }
        return true
    }
    
    // MARK: Prevent rotation, support only Portrait mode
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    // Activity indicator
    
    func startActivityIndicator() {
        
        if self.activityIndicator == nil {
            activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        }
        BSViewsManager.startActivityIndicator(activityIndicator: activityIndicator!, blockEvents: true)
    }

    func stopActivityIndicator() {
        if let activityIndicator = activityIndicator {
            BSViewsManager.stopActivityIndicator(activityIndicator: activityIndicator)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.hideShowElements()
    }
}
