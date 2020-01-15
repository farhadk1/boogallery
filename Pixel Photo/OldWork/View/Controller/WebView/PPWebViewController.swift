//
//  PPWebViewController.swift
//  Pixel Photo
//
//  Created by DoughouzLight on 26/12/2018.
//  Copyright © 2018 DoughouzLight. All rights reserved.
//

import UIKit
import WebKit

class PPWebViewController: UIViewController {
    
    var viewModel : WebViewViewModeling?
    fileprivate var progress = ProgressDialog()
    
    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        progress.show()
        
        self.navigationController?.isNavigationBarHidden = false
        self.webView.load(URLRequest(url: URL(string: self.viewModel!.url!)!))
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
            if Float(webView.estimatedProgress) > 0.0 {
                progress.dismiss()
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
