//
//  WebViewModel.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//

import SwiftUI
import WebKit
import PhotosUI
import AVFoundation

// MARK: - WebView Model
class WebViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var isPageLoaded = false
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var error: Error?
    @Published var showNavigation = false // Set to true to show navigation controls
    
    // MARK: - Properties
    let webView: WKWebView
    private let initialURL: String
    
    // File upload handling
    private var fileUploadCompletion: ((URL?) -> Void)?
    @Published var showingImagePicker = false
    @Published var showingCameraPicker = false
    @Published var selectedImage: UIImage?
    
    // JavaScript communication
    private let jsMessageHandler = "nativeInterface"
    
    // MARK: - Initialization
    override init() {
        // Default URL - you can customize this
        self.initialURL = "https://www.linkedin.com/"
        
        // WebView configuration
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        // Add message handler for JavaScript communication
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        // Create WebView
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        super.init()
        
        // Setup WebView
        setupWebView()
        
        // Add message handler
        contentController.add(self, name: jsMessageHandler)
        
        // Load initial URL
        loadInitialURL()
    }
    
    // MARK: - WebView Setup
    private func setupWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Enable developer tools in debug builds
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        
        // Observe properties
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
        
        webView.publisher(for: \.isLoading)
            .assign(to: &$isLoading)
    }
    
    // MARK: - Navigation Methods
    func loadInitialURL() {
        guard let url = URL(string: initialURL) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func refresh() {
        webView.reload()
    }
    
    // MARK: - JavaScript Communication
    func evaluateJavaScript(_ script: String, completion: ((Any?, Error?) -> Void)? = nil) {
        webView.evaluateJavaScript(script, completionHandler: completion)
    }
    
    // MARK: - User Session Management
    func loginFinished(userId: String) {
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        // Add any additional login logic here
        print("User logged in: \(userId)")
    }
    
    func logoutFinished() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        // Add any additional logout logic here
        print("User logged out")
    }
}


// MARK: - Enhanced WebView with File Upload Support
extension WebViewModel: WKUIDelegate {
    
    // Handle file upload for HTML input elements
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        
        fileUploadCompletion = { url in
            if let url = url {
                completionHandler([url])
            } else {
                completionHandler(nil)
            }
        }
        
        // Check if camera is allowed
        if parameters.allowsDirectories == false &&
           parameters.allowsMultipleSelection == false {
            
            // Show action sheet for single file selection
            DispatchQueue.main.async {
                self.showFileUploadOptions()
            }
        }
    }
    
    private func showFileUploadOptions() {
        let alert = UIAlertController(title: "Select File", message: nil, preferredStyle: .actionSheet)
        
        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.checkCameraPermissionAndShow()
            })
        }
        
        // Photo Library option
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.checkPhotoLibraryPermissionAndShow()
        })
        
        // Cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.fileUploadCompletion?(nil)
        })
        
        // Present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            if let popover = alert.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func checkCameraPermissionAndShow() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showingCameraPicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showingCameraPicker = true
                    } else {
                        self.fileUploadCompletion?(nil)
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: "Camera")
        @unknown default:
            fileUploadCompletion?(nil)
        }
    }
    
    private func checkPhotoLibraryPermissionAndShow() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            showingImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.showingImagePicker = true
                    } else {
                        self.fileUploadCompletion?(nil)
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: "Photo Library")
        @unknown default:
            fileUploadCompletion?(nil)
        }
    }
    
    private func showPermissionDeniedAlert(for feature: String) {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "\(feature) access is required to upload files. Please enable it in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.fileUploadCompletion?(nil)
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}




// MARK: - WKNavigationDelegate
extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        error = nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        isPageLoaded = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        self.error = error
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle custom URL schemes
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Allow HTTP/HTTPS
        if url.scheme == "http" || url.scheme == "https" {
            decisionHandler(.allow)
            return
        }
        
        // Handle custom schemes
        if handleCustomScheme(url: url) {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func handleCustomScheme(url: URL) -> Bool {
        // Handle deep links and custom schemes
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        }
        return false
    }
}


// MARK: - WKScriptMessageHandler
extension WebViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle messages from JavaScript
        guard message.name == jsMessageHandler else { return }
        
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }
        
        switch action {
        case "loginFinished":
            if let userId = body["userId"] as? String {
                loginFinished(userId: userId)
            }
        case "logoutFinished":
            logoutFinished()
        default:
            print("Unknown action: \(action)")
        }
    }
}

// MARK: - File Upload Support (iOS 14+)
@available(iOS 14.0, *)
extension WebViewModel {
    // This would be used in conjunction with a file upload delegate
    // For HTML file inputs, you'd need to implement WKUIDelegate methods
    // This is a simplified example
    
    func handleFileUpload() {
        // Present action sheet for file selection
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.showingCameraPicker = true
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showingImagePicker = true
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}
