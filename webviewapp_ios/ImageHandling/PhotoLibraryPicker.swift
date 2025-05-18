//
//  PhotoLibraryPicker.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//
import SwiftUI
import PhotosUI
// MARK: - Photo Library Picker (iOS 14+)
@available(iOS 14.0, *)
struct PhotoLibraryPicker: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Text("Select Photo")
        }
        .onChange(of: selectedItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
