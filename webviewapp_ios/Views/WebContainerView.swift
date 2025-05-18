//
//  WebContainerView.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//

import SwiftUI
import WebKit
import PhotosUI
import AVFoundation

// MARK: - WebView Container
struct WebViewContainer: View {
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar (optional)
            if webViewModel.showNavigation {
                NavigationBarView(webViewModel: webViewModel)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // WebView
            WebViewWrapper(webViewModel: webViewModel)
                .clipped()
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
