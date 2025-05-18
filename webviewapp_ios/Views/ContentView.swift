//
//  ContentView.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            // Main WebView
            WebViewContainer(webViewModel: webViewModel)
                .opacity(showingSplash ? 0 : 1)
            
            // Splash Screen
            if showingSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onReceive(webViewModel.$isPageLoaded) { isLoaded in
            if isLoaded && showingSplash {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingSplash = false
                }
            }
        }
        .alert("Error", isPresented: .constant(webViewModel.error != nil), presenting: webViewModel.error) { error in
            Button("OK") {
                webViewModel.error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
