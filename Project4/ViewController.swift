//
//  ViewController.swift
//  Project4
//
//  Created by Steven Vandegrift on 8/13/20.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webview: WKWebView!
    var progressView: UIProgressView!
    var websites = [String]()
    var selectedSite: String = ""
    
    override func loadView() {
        webview = WKWebView()
        webview.navigationDelegate = self
        view = webview
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webview, action: #selector(webview.reload))
        let forward = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webview, action: #selector(webview.goForward))
        let backward = UIBarButtonItem(barButtonSystemItem: .rewind, target: webview, action: #selector(webview.goBack))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton,spacer,backward,forward,refresh]
        navigationController?.isToolbarHidden = false
        
        webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        let url = URL(string: "https://\(selectedSite)")!
        webview.load(URLRequest(url: url))
        webview.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped(){
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem // For iPads
        present(ac, animated: true)
    }

    func openPage(action: UIAlertAction){
        let url = URL(string: "https://\(action.title!)")!
        webview.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webview.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webview.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        let ac = UIAlertController(title: "Unknown Host", message: "This page is blocked for safety reasons", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: .none))
        
        if let host = url?.host {
            for website in websites {
                print(host)
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
            present(ac, animated: true)
        }
        decisionHandler(.cancel)
        
    }
}

