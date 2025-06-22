//
//  PhotoLibraryPermission.swift
//  BookXPAssign
//
//  Created by vikash kumar on 22/06/25.
//


import SwiftUI
import Photos

@MainActor
class PhotoLibraryPermission: ObservableObject {
    
    @Published var isPhotoLibraryPermission: Bool = false
    
    func getPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            isPhotoLibraryPermission = true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            isPhotoLibraryPermission = (newStatus == .authorized || newStatus == .limited)
        case .denied, .restricted:
            isPhotoLibraryPermission = false
        @unknown default:
            isPhotoLibraryPermission = false
        }
        return isPhotoLibraryPermission
    }
}
