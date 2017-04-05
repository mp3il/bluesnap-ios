//
//  BSWebViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 05/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSWebViewController: UIViewController {
    
    // MARK: puclic properties
    var url : String = ""
   
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wUrl = URL(string: self.url)
        webView.loadRequest(URLRequest(url: wUrl!))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
