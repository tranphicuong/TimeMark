import SwiftUI
import UIKit

struct CameraView: View {
    var onImageCaptured: (UIImage?) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        CameraPicker(onImageCaptured: onImageCaptured, dismiss: dismiss)
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage?) -> Void
    var dismiss: DismissAction
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front         
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            } else {
                parent.onImageCaptured(nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.onImageCaptured(nil)
        }
    }
}
