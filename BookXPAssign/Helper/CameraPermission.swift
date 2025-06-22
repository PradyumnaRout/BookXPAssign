//
//  CameraPermission.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 22/06/25.
//

import Foundation
import AVFoundation

@MainActor
class CameraPermission: ObservableObject {
    @Published var isCameraPermission: Bool = false

    func getCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isCameraPermission = true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            isCameraPermission = granted
        case .denied, .restricted:
            isCameraPermission = false
        @unknown default:
            isCameraPermission = false
        }
        return isCameraPermission
    }
}

