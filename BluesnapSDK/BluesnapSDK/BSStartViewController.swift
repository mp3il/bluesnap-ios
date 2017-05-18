//
//  StartViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 17/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSStartViewController: UIViewController {

    // MARK: - Public properties
    
    internal var paymentDetails : BSPaymentDetails!
    internal var fullBilling = false
    internal var bsToken: BSToken!
    internal var purchaseFunc: (BSPaymentDetails!)->Void = {
        paymentDetails in
        print("purchaseFunc should be overridden")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func applePayClick(_ sender: Any) {
        
        let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "Not yet implemented")
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ccDetailsClick(_ sender: Any) {
        
        _ = BSViewsManager.showCCDetailsScreen(inNavigationController: self.navigationController, animated: true, bsToken: bsToken, paymentDetails: paymentDetails, fullBilling: fullBilling, purchaseFunc: purchaseFunc)
    }

    @IBAction func editingDidBegin(_ sender: Any) {
        print("****************** EditingDidBegin")
    }
    
    @IBAction func editingDidEnd(_ sender: BSInputLine) {
        print("****************** EditingDidEnd, value=\(sender.getValue())")
    }
    @IBAction func editingChanged(_ sender: BSInputLine) {
        print("****************** editingChanged, value=\(sender.getValue())")
    }
    @IBAction func touchUpInside(_ sender: BSInputLine) {
        print("****************** container touchUpInside")
    }
    
}
