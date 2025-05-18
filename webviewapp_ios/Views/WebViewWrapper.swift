import SwiftUI
import WebKit
import PhotosUI
import AVFoundation

// MARK: - WebView UIKit Wrapper
struct WebViewWrapper: UIViewRepresentable {
    @ObservedObject var webViewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        return webViewModel.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Updates handled by WebViewModel
    }
}
