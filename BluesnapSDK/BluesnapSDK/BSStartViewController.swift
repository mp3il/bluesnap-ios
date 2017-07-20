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

    internal var paymentRequest: BSPaymentRequest!
    internal var fullBilling = false
    internal var withShipping = false
    internal var purchaseFunc: (BSPaymentRequest!) -> Void = {
        paymentRequest in
        print("purchaseFunc should be overridden")
    }

    var paymentSummaryItems: [PKPaymentSummaryItem] = [];

    // MARK: Outlets

    @IBOutlet weak var centeredView: UIView!
    @IBOutlet weak var ccnButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var applePayButton: UIButton!

    // MARK: UIViewController functions

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false

        // Hide/show the applepay 
        let tmpY = self.view.center.y
        if showApplePayButton() {
            orLabel.isHidden = false
            applePayButton.isHidden = false
            centeredView.center.y = tmpY
        } else {
            orLabel.isHidden = true
            applePayButton.isHidden = true
            centeredView.center.y = tmpY - (ccnButton.center.y - centeredView.frame.height / 2)
        }
    }

    // MARK: button functions

    @IBAction func applePayClick(_ sender: Any) {

        let applePaySupported = BlueSnapSDK.applePaySupported(supportedNetworks: BlueSnapSDK.applePaySupportedNetworks)

        if (!applePaySupported.canMakePayments) {
            let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "Not available on this device")
            present(alert, animated: true, completion: nil)
            return;
        }

        if (!applePaySupported.canSetupCards) {
            let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "No cards set")
            present(alert, animated: true, completion: nil)
            return;
        }

        if BSApplePayConfiguration.getIdentifier() == nil {
            let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "Setup error")
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
                    let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "General error")
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    let result: BSResultPaymentDetails = BSResultApplePayDetails()
                    self.paymentRequest.setResultPaymentDetails(resultPaymentDetails: result)
                    _ = self.navigationController?.popViewController(animated: false)
                    // execute callback
                    self.purchaseFunc(self.paymentRequest)
                }
            }
        })

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

    private func showApplePayButton() -> Bool {

        let applePaySupported = BlueSnapSDK.applePaySupported(supportedNetworks: BlueSnapSDK.applePaySupportedNetworks)
        return applePaySupported.canMakePayments
    }
}
