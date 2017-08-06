//
//  BSWebViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 05/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//
import UIKit

class BSWebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: puclic properties
    var url : String = ""
    
    // MARK: private properties
    
    @IBOutlet weak var webView: UIWebView!
    fileprivate var activityIndicator : UIActivityIndicatorView?
    
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        
        let wUrl = URL(string: self.url)
        NSLog("WebView loading URL \(url)")
        webView.loadRequest(URLRequest(url: wUrl!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UIWebViewDelegate functions
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: false)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        BSViewsManager.stopActivityIndicator(activityIndicator: self.activityIndicator)
    }
    
}
