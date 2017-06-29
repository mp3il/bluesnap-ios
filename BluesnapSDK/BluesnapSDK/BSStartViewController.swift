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

    // MARK: - internal properties
    
    internal var paymentRequest : BSPaymentRequest!
    internal var fullBilling = false
    internal var purchaseFunc: (BSPaymentRequest!)->Void = {
        paymentRequest in
        print("purchaseFunc should be overridden")
    }
    static let supportedNetworks: [PKPaymentNetwork] = [
            .amex,
            .discover,
            .masterCard,
            .visa
    ]
    
    var paymentSummaryItems:[PKPaymentSummaryItem] = [];
    
    // MARK: Outlets
    
    @IBOutlet weak var centeredView: UIView!
    @IBOutlet weak var ccnButton: UIButton!
    
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
        _ = BSViewsManager.showCCDetailsScreen(inNavigationController: self.navigationController, animated: animate, paymentRequest: self.paymentRequest, fullBilling: self.fullBilling, purchaseFunc: self.purchaseFunc)
        })
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
    
    class func applePaySupported() -> (canMakePayments: Bool, canSetupCards: Bool) {
        if #available(iOS 10, *) {
            
            return (PKPaymentAuthorizationController.canMakePayments(),
                    PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks));
        } else {
            return (canMakePayments: false, canSetupCards: false)
        }
    }


}
