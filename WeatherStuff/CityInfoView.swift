//
//  CityInfoView.swift
//  WeatherStuff
//
//  Created by Kourosh Alasti on 12/5/24.
//

import SwiftUI
import AVFoundation

struct CityResponse: Codable {
    let items: [CityInfo]
}

struct CityInfo: Codable {
    let xata_id: String
    let city: String
    let lastTemperature: Double
    let images: [String]?
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CityInfoView: View {
    let city: String
    
    @State private var temperature = "Unknown"
    @State private var photos: [UIImage] = []
    @State private var showCamera = false
    @State private var isUploading = false
    @State private var image: UIImage?
    @State private var imageURI: String = ""
    @State private var selectedImageData: Data?
    
    var body: some View {
        VStack {
            Text("\(city) - \(temperature)")
                .font(.headline)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos, id: \.self) { photo in
                        Image(uiImage: photo)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            
            Button(action: {
                showCamera.toggle()
            }) {
                Text("Take Photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            }
            
            if !imageURI.isEmpty {
                Button(action: uploadPhoto) {
                    Text("Upload Photo")
                        .padding()
                        .background(isUploading ? .gray : .blue)
                        .foregroundColor(.white)
                        .disabled(isUploading)
                }
                .padding()
            }
            Spacer()
        }
        .onAppear {
            fetchCityInfo(cityName: city) { cityInfo in
                if let cityInfo = cityInfo {
                    DispatchQueue.main.async {
                        temperature = String(format: "%.1f degC", cityInfo.lastTemperature)
                        photos = cityInfo.images?.compactMap { base64ToImage($0)} ?? []
                    }
                } else {
                    DispatchQueue.main.async {
                        temperature = "Unavailable Temperature"
                        photos = []
                    }
                }
                
            }
        }
        .sheet(isPresented: $showCamera, onDismiss: loadImage) {
            ImagePicker(image: $image)
        }
        
    }
    
    func fetchCityInfo(cityName: String, completion: @escaping (CityInfo?) -> Void) {
        guard let url = URL(string: "https://deploy-preview-1--unishopapp.netlify.app/api/") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error during GET Request: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CityResponse.self, from: data)
                if let cityInfo = decodedResponse.items.first(where: {$0.city.lowercased() == cityName.lowercased()}) {
                    completion(cityInfo)
                } else {
                    print("City Not Found")
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func loadImage() {
        guard let selectedImage  = image else {
            return
        }
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            imageURI = imageData.base64EncodedString()
        }
    }
    
    func uploadPhoto() {
        guard !imageURI.isEmpty else { return }
        isUploading = true
        
        guard let url = URL(string: "https://deploy-preview-1--unishopapp.netlify.app/api/image?city=\(encodeStringToURLString(city))") else { return }
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["imageURI": imageURI]
        
        do {
               request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
           } catch {
               print("Error serializing JSON: \(error)")
               isUploading = false
               return
           }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                if let error = error {
                    print ("Upload failed with error: \(error.localizedDescription)")
                } else {
                    print("Uploaded Successfully")
                    
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                }
            }
        }.resume()
    }
    
    func base64ToImage(_ base64: String) -> UIImage? {
        
            let base64String = base64.replacingOccurrences(of: "data:image/png;base64,", with: "")
            
            
            guard let imageData = Data(base64Encoded: base64String) else {
                return nil
            }
            
    
            return UIImage(data: imageData)
    }
    
    func encodeStringToURLString(_ input: String) -> String {
        return input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
    }
    
    func imagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        
        return imagePicker
    }
}

#Preview {
    CityInfoView(city: "Sample City")
}
