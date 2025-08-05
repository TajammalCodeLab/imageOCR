//
//  CameraView.swift
//  ocrImagetext
//
//  Created by Ml Bench on 17/07/2025.
//


import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.showsCameraControls = true
        picker.cameraOverlayView = OverlayView()
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

final class OverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Full blue overlay
        context.setFillColor(UIColor.blue.withAlphaComponent(0.5).cgColor)
        context.fill(bounds)
        
        // Transparent rectangle in the center
        let boxWidth: CGFloat = 250
        let boxHeight: CGFloat = 160
        let rectX = (bounds.width - boxWidth) / 2
        let rectY = (bounds.height - boxHeight) / 2
        
        let transparentRect = CGRect(x: rectX, y: rectY, width: boxWidth, height: boxHeight)
        context.clear(transparentRect)

        // Add white border to focus area
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.stroke(transparentRect)
    }
}
