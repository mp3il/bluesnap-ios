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

    var initialData : BSInitialData!
    internal var purchaseFunc: (BSBasePaymentRequest!) -> Void = {
        paymentRequest in
        print("purchaseFunc should be overridden")
    }

    var paymentSummaryItems: [PKPaymentSummaryItem] = [];
    internal var activityIndicator : UIActivityIndicatorView?
    internal var payPalPaymentRequest: BSPayPalPaymentRequest!

    // MARK: Outlets

    @IBOutlet weak var centeredView: UIView!
    @IBOutlet weak var ccnButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var or2Label: UILabel!
    @IBOutlet weak var payPalButton: UIButton!

    // MARK: init
    
    func initScreen(initialData: BSInitialData!, purchaseFunc: @escaping (BSBasePaymentRequest!) -> Void) {
        
        self.initialData = initialData
        self.purchaseFunc = purchaseFunc
    }
    
    // MARK: UIViewController functions

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false

        // Hide/show the buttons and position them automatically
        
        let showPayPal = showPayPalButton()
        let showApplePay = showApplePayButton()
        let numSections = (showPayPal && showApplePay) ? 3 : (!showPayPal && !showApplePay) ? 1 : 2
        let sectionY : CGFloat = (centeredView.frame.height / CGFloat(numSections+1)).rounded()
        
        if showApplePay {
            orLabel.isHidden = false
            applePayButton.isHidden = false
            applePayButton.center.y = sectionY
            orLabel.center.y = (sectionY*1.5).rounded()
            ccnButton.center.y = sectionY*2
        } else {
            orLabel.isHidden = true
            applePayButton.isHidden = true
        }
        if showPayPal {
            or2Label.isHidden = false
            payPalButton.isHidden = false
            if showApplePay {
                or2Label.center.y = (sectionY*2.5).rounded()
                payPalButton.center.y = sectionY*3
            } else {
                or2Label.center.y = (sectionY*1.5).rounded()
                payPalButton.center.y = sectionY*2
            }
        } else {
            or2Label.isHidden = true
            payPalButton.isHidden = true
        }
        
        // Localize strings
        let localizedOr = BSLocalizedStrings.getString(BSLocalizedString.Label_Or)
        orLabel.text = localizedOr
        or2Label.text = localizedOr
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Payment_Type)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopActivityIndicator()
    }

    // MARK: button functions

    @IBAction func applePayClick(_ sender: Any) {

        let applePaySupported = BlueSnapSDK.applePaySupported(supportedNetworks: BlueSnapSDK.applePaySupportedNetworks)

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
                    let applePayPaymentRequest = BSApplePayPaymentRequest(initialData: self.initialData)
                    self.purchaseFunc(applePayPaymentRequest)
                }
            }
        })

    }

    @IBAction func ccDetailsClick(_ sender: Any) {

        let backItem = UIBarButtonItem()
        backItem.title = BSLocalizedStrings.getString(BSLocalizedString.Navigate_Back_to_payment_type_screen)
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed

        animateToPaymentScreen(completion: { animate in
            _ = BSViewsManager.showCCDetailsScreen(inNavigationController: self.navigationController, animated: animate, initialData: self.initialData, purchaseFunc: self.purchaseFunc)
        })
    }
    
    @IBAction func payPalClicked(_ sender: Any) {
        
        payPalPaymentRequest = BSPayPalPaymentRequest(initialData: initialData)
        
        DispatchQueue.main.async {
            self.startActivityIndicator()
        }
        
        DispatchQueue.main.async {
            BSApiManager.createPayPalToken(paymentRequest: self.payPalPaymentRequest, withShipping: self.initialData.withShipping, completion: { resultToken, resultError in
                
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

    private func animateToPaymentScreen(completion: ((Bool) -> Void)!) {

        let moveUpBy = self.centeredView.frame.minY + self.ccnButton.frame.minY - 48
        UIView.animate(withDuration: 0.3, animations: {
            self.centeredView.center.y = self.centeredView.center.y - moveUpBy
        }, completion: { animate in
            completion(false)
            self.centeredView.center.y = self.centeredView.center.y + moveUpBy
        })
    }

    private func showApplePayButton() -> Bool {

        let applePaySupported = BlueSnapSDK.applePaySupported(supportedNetworks: BlueSnapSDK.applePaySupportedNetworks)
        return applePaySupported.canMakePayments
    }
    
    private func showPayPalButton() -> Bool {
        
        if BSApiManager.isSupportedPaymentMethod(BSPaymentType.PayPal) {
            return true
        }
        return false
    }
    
    private func paypalUrlListener(url: String) -> Bool {
        
        if BSPaypalHandler.isPayPalProceedUrl(url: url) {
            // paypal success!
            
            BSPaypalHandler.parsePayPalResultDetails(url: url, paymentRequest: self.payPalPaymentRequest)
            
            // return to merchant screen
            if let viewControllers = navigationController?.viewControllers {
                let merchantControllerIndex = viewControllers.count - 3
                _ = navigationController?.popToViewController(viewControllers[merchantControllerIndex], animated: false)
            }
            
            // execute callback
            self.purchaseFunc(self.payPalPaymentRequest)
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
}
