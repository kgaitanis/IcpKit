//
//  MiniWebView.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import Foundation

import SwiftUI
import WebKit

struct MiniWebView: UIViewRepresentable {
    let url: URL
    @Binding var error: Bool
    private let delegate: WDelegate
    
    init(url: URL, error: Binding<Bool>) {
        self.url = url
        self._error = error
        delegate = WDelegate(url: url, onError: error)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = delegate
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

private class WDelegate: NSObject, WKNavigationDelegate {
    let url: URL
    let onError: Binding<Bool>
    
    init(url: URL, onError: Binding<Bool>) {
        self.url = url
        self.onError = onError
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, _) in
            if complete != nil {
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onError.wrappedValue = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onError.wrappedValue = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        if navigationAction.request.url?.host() == url.host {
            return (.allow, preferences)
        } else {
            return (.cancel, preferences)
        }
    }
}

private let js = """
    // center svg
    var svg = document.getElementsByTagName('svg').item(0);
    svg.removeAttribute("width");
    svg.removeAttribute("height");
    svg.setAttribute("preserveAspectRatio","xMidYMid slice");

    // center html
    var meta = document.createElement('meta');
    meta.name='viewport';
    meta.content='width=device-width';
    //document.getElementsByTagName('head')[0].appendChild(meta);
"""
