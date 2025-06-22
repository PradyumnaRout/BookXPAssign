//
//  ProfileViewModel.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    @Published var profileData: UserDataModel?
    @Published var showCamera = false
    @Published var showGallery = false
    @Published var alertForPermission = false
    @Published var showPicker = false
    
    let cameraPermission = CameraPermission()
    let galleryPermission = PhotoLibraryPermission()
    
    init() {
        profileData = CoreDataManager.shared.fetchOnlyUSer()
    }
    
    // Camera Permission
    func handleCameraTapped() {
        Task {
            let permit = await cameraPermission.getCameraPermission()
            if permit {
                showCamera = true
            } else {
                alertForPermission = true
            }
            showPicker = false
        }
    }
    
    // Gallery Permission And Selection
    func handleGalleryTapped() {
        Task {
            let permit = await galleryPermission.getPhotoLibraryPermission()
            if permit {
                showGallery = true
            } else {
                alertForPermission = true
            }
            showPicker = false
        }
    }
    
}
