//
//  BSPopupMenuViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSPopupMenuViewController : UIViewController {
    
    // MARK: - Public properties
    internal var bsToken : BSToken?
    internal var purchaseData : PurchaseData?
    internal var closeFunc : ()->Void = {
        // this will be overidden by parent screen
        //self.view.removeFromSuperview()
    }
    
    // MARK: private properties
    @IBOutlet var menuView: UIView!
    
    // MARK: Constants
    fileprivate let privacyPolicyURL = "http://home.bluesnap.com/ecommerce/legal/privacy-policy/"
    fileprivate let refundPolicyURL = "http://home.bluesnap.com/ecommerce/legal/refund-policy/"
    fileprivate let termsURL = "http://home.bluesnap.com/ecommerce/legal/terms-and-conditions/"

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.showAnimate()
    }

    
    @IBAction func currencyMenuClick(_ sender: Any) {
        
        if let purchaseData = purchaseData, let bsToken = bsToken {
            BlueSnapSDK.showCurrencyList(
                inNavigationController: self.navigationController,
                animated: true,
                bsToken: bsToken,
                selectedCurrencyCode: purchaseData.getCurrency(),
                updateFunc: updateViewWithNewCurrency)
            self.closeFunc()
        }
    }
    
    @IBAction func cancelMenuClick(_ sender: Any) {
        
        self.removeAnimate()
    }
    
    
    func showAnimate()
    {
        let menuHeight = menuView.frame.height
        menuView.frame.origin.y = menuHeight
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn,
            animations: {
                self.menuView.frame.origin.y = 0
            }, completion: {_ in }
        )
    }
    
    func removeAnimate()
    {
        let menuHeight = menuView.frame.height
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut,
            animations: {
                self.menuView.frame.origin.y = menuHeight
            }, completion: {_ in
                //self.view.removeFromSuperview()
                self.closeFunc()
            }
        )

    }
    
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        purchaseData!.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if navigating to the web view - set the right URL
        if let id = segue.identifier {
            var url : String?
            if id == "webViewPrivacyPolicy" {
                url = privacyPolicyURL
            } else if id == "webViewRefundPolicy" {
                url = refundPolicyURL
            } else if id == "webViewTerms" {
                url = termsURL
            }
            if let url = url {
                let controller = segue.destination as! BSWebViewController
                controller.url = url
            }
            self.closeFunc()
        }
    }

}
