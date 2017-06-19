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

    // MARK: - Public properties
    
    internal var checkoutDetails : BSCheckoutDetails!
    internal var fullBilling = false
    internal var purchaseFunc: (BSCheckoutDetails!)->Void = {
        checkoutDetails in
        print("purchaseFunc should be overridden")
    }

    static let supportedNetworks: [PKPaymentNetwork] = [
            .amex,
            .discover,
            .masterCard,
            .visa
    ]
    
    var paymentSummaryItems:[PKPaymentSummaryItem] = [];
    
    class func applePaySupported() -> (canMakePayments: Bool, canSetupCards: Bool) {
        if #available(iOS 10, *) {
            
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks));
        } else {
            return (canMakePayments: false, canSetupCards: false)
        }
    }

    // MARK: UIViewController functions


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
    }
    
    // MARK: button functions
    
    @IBAction func applePayClick(_ sender: Any) {
        if (!BSStartViewController.applePaySupported().canMakePayments) {
            let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "Not available on this device")
            present(alert, animated: true, completion: nil)
            return;
        }

        if (!BSStartViewController.applePaySupported().canSetupCards) {
            let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "No cards set")
            present(alert, animated: true, completion: nil)
            return;
        }
        payPressed(sender)

    }
    
    @IBAction func ccDetailsClick(_ sender: Any) {
        
        animateToPaymentScreen(completion: { animate in
        _ = BSViewsManager.showCCDetailsScreen(inNavigationController: self.navigationController, animated: animate, checkoutDetails: self.checkoutDetails, fullBilling: self.fullBilling, purchaseFunc: self.purchaseFunc)
        })
    }
    
    // Mark: private functions
    
    private func animateToPaymentScreen(completion: ((Bool) -> Void)!) {
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        completion(false)
    }

}
