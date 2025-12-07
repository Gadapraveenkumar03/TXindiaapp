import SwiftUI

struct AsyncImageView: View {
    let imageKey: String?
    let placeholder: String
    let width: CGFloat?
    let height: CGFloat?
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @StateObject private var storageManager = StorageManager()
    
    init(imageKey: String?, placeholder: String = "photo", width: CGFloat? = nil, height: CGFloat? = nil) {
        self.imageKey = imageKey
        self.placeholder = placeholder
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                    
                    ProgressView()
                        .scaleEffect(0.8)
                }
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                    
                    Image(systemName: placeholder)
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageKey = imageKey, loadedImage == nil, !isLoading else { return }
        
        isLoading = true
        
        Task {
            do {
                let imageData = try await storageManager.downloadImage(key: imageKey)
                if let image = UIImage(data: imageData) {
                    await MainActor.run {
                        self.loadedImage = image
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print("Failed to load image: \(error)")
            }
        }
    }
}
