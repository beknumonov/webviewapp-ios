//
//  SplashView.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//
import SwiftUI
import WebKit
import PhotosUI
import AVFoundation

// MARK: - Splash View
struct SplashView: View {
    var body: some View {
        ZStack {
            
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("WebView App")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}
