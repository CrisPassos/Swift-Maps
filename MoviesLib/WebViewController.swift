//
//  WebViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webPageUrl = URL(string: url)
        let request = URLRequest(url: webPageUrl!)
        webView.loadRequest(request)
        
    }
    
    @IBAction func runJS(_ sender: UIBarButtonItem) {
        webView.stringByEvaluatingJavaScript(from: "alert('isso ai')")
    }


}


extension WebViewController: UIWebViewDelegate{
    //todas as URLs que estao sendo abertas juntos com a URL principal
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
       print(request.url!.absoluteString)
    
        if request.url!.absoluteString.range(of: "ads") != nil {
            return false
        }
        
       return true
    }
}
