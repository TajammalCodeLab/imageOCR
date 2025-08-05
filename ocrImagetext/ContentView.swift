import SwiftUI
import Vision

struct ContentView: View {
  @State private var image: UIImage?
  @State private var activeSheet: ActiveSheet?
  @State private var extractedText = CNICData()
  
  var body: some View {
    VStack {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
        
        ScrollView {
          Text("\(extractedText)")
        }
      }
      
      Button("Capture Image") {
        activeSheet = .camera
      }
      .padding()
    }
    .sheet(item: $activeSheet, onDismiss: {
      // Skip cropping — directly go to OCR
      if let captured = image {
        recognizeText(from: captured) { text in
          DispatchQueue.main.async {
            extractedText = parseCNICData(from: text)
          }
        }
      }
    }) { item in
      switch item {
      case .camera:
        CameraView(image: $image)
//      case .cropper:
//        // no longer used
//        EmptyView()
      }
    }
  }
}



func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
  guard let cgImage = image.cgImage else {
    completion("")
    return
  }
  
  let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
  let request = VNRecognizeTextRequest { request, error in
    guard error == nil else {
      completion("")
      return
    }
    
    let text = request.results?
      .compactMap { ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string }
      .joined(separator: "\n") ?? ""
    
    completion(text)
  }
  
  request.recognitionLevel = .accurate
  request.usesLanguageCorrection = true
  
  DispatchQueue.global(qos: .userInitiated).async {
    do {
      try requestHandler.perform([request])
    } catch {
      completion("")
    }
  }
}

func parseCNICData(from rawText: String) -> CNICData {
  dump(rawText)
  return CNICData()
}
extension String {
  func matches(for regex: String) -> [String] {
    let regex = try? NSRegularExpression(pattern: regex)
    let results = regex?.matches(in: self, range: NSRange(self.startIndex..., in: self)) ?? []
    return results.map {
      String(self[Range($0.range, in: self)!])
    }
  }
}



struct CNICData {
  var firtName: String?
  var lastName: String?
  var sex: String?
  var dateOfBirth: String?
  var documentNo: String?
  var documentType: String?
  var issuingCountry: String?
}

enum ActiveSheet {
  case camera
}

extension ActiveSheet: Identifiable {
  var id: Int {
    switch self {
    case .camera: return 1
    }
  }
}
