//
//  CropView.swift
//  ocrImagetext
//
//  Created by Ml Bench on 17/07/2025.
//

import SwiftUI
import TOCropViewController
import CropViewController

struct CropView: UIViewControllerRepresentable {
    var image: UIImage
    var onCropped: (UIImage) -> Void

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: CropView

        init(_ parent: CropView) {
            self.parent = parent
        }

      func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.onCropped(image)
            cropViewController.dismiss(animated: true, completion: nil)
        }

        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropVC = TOCropViewController(image: image)
      cropVC.delegate = context.coordinator as? any TOCropViewControllerDelegate
        return cropVC
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
}
