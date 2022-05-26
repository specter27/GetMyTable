//
//  RestaurantMenuViewController.swift
//  GMT
//
//  Created by Harshit Malhotra on 2022-05-25.
//

import UIKit

import WebKit

class RestaurantMenuViewController: UIViewController, WKNavigationDelegate {

    
    //properties
    var webView: WKWebView!
    var webUrl:String = ""
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "\(webUrl)")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    

}
