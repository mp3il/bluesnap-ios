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
    internal var purchaseFunc: (BSPaymentDetails!)->Void = {
        paymentDetails in
        print("purchaseFunc should be overridden")
    }
    
    // MARK: UIViewController functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
    }
    
    // MARK: button functions
    
    @IBAction func applePayClick(_ sender: Any) {
        
        let alert = BSViewsManager.createErrorAlert(title: "Apple Pay", message: "Not yet implemented")
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ccDetailsClick(_ sender: Any) {
        
        animateToPaymentScreen(completion: { animate in
        _ = BSViewsManager.showCCDetailsScreen(inNavigationController: self.navigationController, animated: animate, paymentDetails: self.paymentDetails, fullBilling: self.fullBilling, purchaseFunc: self.purchaseFunc)
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
