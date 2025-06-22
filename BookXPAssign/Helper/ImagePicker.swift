//
//  ImagePicker.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import SwiftUI
import PhotosUI

struct ImagePickerManager: UIViewControllerRepresentable {
   
    var selectedImage: Binding<UIImage?>? = nil
    var selectedVideoURL: Binding<URL?>? = nil
    let sourceType: ImagePickerSourceType
    var selectedImageValue: ((UIImage) -> ())? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        switch sourceType {
        case .cameraImage:
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
            picker.videoQuality = .typeMedium
            return picker

        case .photoLibraryImage:
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            config.preferredAssetRepresentationMode = .automatic
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            picker.view.backgroundColor = .clear

            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.parent?.view.backgroundColor = .clear
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
        let parent: ImagePickerManager

        init(_ parent: ImagePickerManager) {
            self.parent = parent
        }

        // For camera (UIImagePickerController)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.parent.selectedImage?.wrappedValue = image
                self.parent.selectedImageValue?(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        // For PHPickerViewController (photo library)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else { return }

            if result.itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImage?.wrappedValue = image
                            self.parent.selectedImageValue?(image)
                        }
                    }
                }
            }
        }
    }
}

enum ImagePickerSourceType: Identifiable {
    case cameraImage, photoLibraryImage

    var id: String {
        switch self {
        case .cameraImage: return "cameraImage"
        case .photoLibraryImage: return "photoLibraryImage"
        }
    }
}
