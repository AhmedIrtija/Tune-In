//
//  WebModel.swift
//  TuneIn
//
//  Created by Ahmed Irtija on 3/2/24.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
        let url: URL
        
        func makeUIView(context: Context) -> WKWebView  {
            
            let wkwebView = WKWebView()
            let request = URLRequest(url: url)
            wkwebView.load(request)
            return wkwebView
        }
    
    func makeCoordinator() -> WebCoordinator{
        WebCoordinator (didStart: <#T##() -> Void#>, didFinish: <#T##() -> Void#>)
    }
    }

class WebCoordinator: NSObject, WKNavigationDelegate {
    var didStart: () -> Void
    var didFinish: () -> Void
    
    init(didStart: @escaping () -> Void, didFinish: @escaping () -> Void) {
        self.didStart = didStart
        self.didFinish = didFinish
    }
}
