# WebView App - SwiftUI

A modern iOS WebView application built with SwiftUI that provides seamless web-native integration.

## 🚀 Features

- **Modern SwiftUI Architecture** - Clean, declarative UI
- **Built-in Navigation** - Back, forward, and refresh controls
- **Splash Screen** - Smooth loading experience
- **Error Handling** - User-friendly alerts
- **JavaScript Support** - Full web functionality

## 📋 Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## 🛠 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/webview-app-swiftui.git
```

2. Open in Xcode:
```bash
cd webview-app-swiftui
open WebViewApp.xcodeproj
```

3. Build and run (⌘R)

## 🎯 Usage

By default, the app loads LinkedIn. To change the URL:

```swift
// In WebViewModel.swift
private let initialURL = "https://your-website.com"
```

## 📁 Project Structure

```
Sources/
├── App/
│   └── WebViewApp.swift        # App entry point
├── ViewModels/
│   └── WebViewModel.swift      # WebView logic
└── Views/
    ├── ContentView.swift       # Main view
    ├── WebViewContainer.swift  # WebView wrapper
    ├── WebViewWrapper.swift    # UIKit bridge
    └── NavigationBarView.swift # Navigation controls
```

## 🔧 Configuration

### Enable Navigation Bar
```swift
webViewModel.showNavigation = true
```

### Custom Error Handling
```swift
// Customize in ContentView.swift
.alert("Error", isPresented: ...) { error in
    // Your custom error handling
}
```

## 📱 Screenshots

[Add screenshots here]

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
