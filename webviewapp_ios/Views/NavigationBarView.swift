
import SwiftUI
import WebKit
import PhotosUI
import AVFoundation


// MARK: - Navigation Bar View
struct NavigationBarView: View {
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        HStack {
            Button(action: webViewModel.goBack) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(webViewModel.canGoBack ? .primary : .gray)
            }
            .disabled(!webViewModel.canGoBack)
            
            Button(action: webViewModel.goForward) {
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(webViewModel.canGoForward ? .primary : .gray)
            }
            .disabled(!webViewModel.canGoForward)
            
            Spacer()
            
            Button(action: webViewModel.refresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            if webViewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
}
