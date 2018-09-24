//
//  BSWebViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 05/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//
import UIKit

class BSWebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: private properties
    
    @IBOutlet weak var webView: UIWebView!
    fileprivate var url : String = ""
    fileprivate var shouldGoToUrlFunc : ((_ url : String) -> Bool)?
    fileprivate var activityIndicator : UIActivityIndicatorView?
    
    // MARK: init
    
    /**
    * Initialize the web viw to go to URL; when URL changes, we call shouldGoToUrlFunc and nacvigate only if it returns true.
    */
    func initScreen(url: String, shouldGoToUrlFunc: ((_ url : String) -> Bool)?) {
        self.url = url
        self.shouldGoToUrlFunc = shouldGoToUrlFunc
    }
    
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
    
    private func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let urlStr = request.mainDocumentURL?.absoluteString ?? ""
        if let shouldGoToUrlFunc = shouldGoToUrlFunc {
            return shouldGoToUrlFunc(urlStr)
        }
        return true
    }
    
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
