//
//  PermissionManager.swift
//  webviewapp_ios
//
//  Created by Sardorbek Numonov on 5/18/25.
//

import SwiftUI
import PhotosUI

// MARK: - Permission Manager
import AVFoundation
import Photos

class PermissionManager: ObservableObject {
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        updatePermissionStatuses()
    }
    
    func updatePermissionStatuses() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if #available(iOS 14, *) {
            photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus()
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            DispatchQueue.main.async {
                self.updatePermissionStatuses()
            }
        }
    }
    
    func requestPhotoLibraryPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                DispatchQueue.main.async {
                    self.updatePermissionStatuses()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { _ in
                DispatchQueue.main.async {
                    self.updatePermissionStatuses()
                }
            }
        }
    }
}
