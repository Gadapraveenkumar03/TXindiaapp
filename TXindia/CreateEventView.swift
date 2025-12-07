import SwiftUI

struct CreateEventView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var price = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory: EventCategory = .cultural
    @State private var selectedCity: City = .dallas
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingPhotoPicker = false
    
    @StateObject private var storageManager = StorageManager()
    @EnvironmentObject var eventManager: EventManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section
                    VStack(alignment: .leading) {
                        Text("Event Image")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            if #available(iOS 14.0, *) {
                                showingPhotoPicker = true
                            } else {
                                showingImagePicker = true
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 200)
                                
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    VStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("Tap to add image")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        CustomTextField(icon: "textformat", placeholder: "Event Title", text: $title)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                                    .frame(width: 20)
                                Text("Description")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            TextEditor(text: $description)
                                .frame(height: 100)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        
                        CustomTextField(icon: "location", placeholder: "Location", text: $location)
                        
                        CustomTextField(icon: "dollarsign.circle", placeholder: "Price (Optional)", text: $price)
                            .keyboardType(.decimalPad)
                        
                        // Date Picker
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                                    .frame(width: 20)
                                Text("Event Date")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        
                        // Category Picker
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                                    .frame(width: 20)
                                Text("Category")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(EventCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            selectedCategory = category
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: category.icon)
                                                Text(category.rawValue)
                                            }
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? category.color : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedCategory == category ? .white : .black)
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // City Picker
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                                    .frame(width: 20)
                                Text("City")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(City.allCases, id: \.self) { city in
                                        Button(action: {
                                            selectedCity = city
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(city.emoji)
                                                    .font(.title2)
                                                Text(city.rawValue)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedCity == city ? LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.2, blue: 0.6),
                                                    Color(red: 0.4, green: 0.8, blue: 0.95)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) : LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.gray.opacity(0.2),
                                                    Color.gray.opacity(0.2)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                            .foregroundColor(selectedCity == city ? .white : .black)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Create Button
                    Button(action: createEvent) {
                        HStack {
                            if storageManager.isUploading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(storageManager.isUploading ? "Creating Event..." : "Create Event")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.2, blue: 0.6),
                                Color(red: 0.4, green: 0.8, blue: 0.95)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .cornerRadius(15)
                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(storageManager.isUploading || title.isEmpty || description.isEmpty || location.isEmpty)
                    .padding(.horizontal)
                    
                    if let errorMessage = storageManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            if #available(iOS 14.0, *) {
                PhotoPicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func createEvent() {
        Task {
            do {
                var imageKey: String?
                
                // Upload image if selected
                if let image = selectedImage {
                    let key = "events/\(UUID().uuidString).jpg"
                    imageKey = try await storageManager.uploadImage(image, key: key)
                }
                
                let eventPrice = price.isEmpty ? nil : Double(price)
                
                let newEvent = Event(
                    id: UUID().uuidString,
                    title: title,
                    description: description,
                    date: selectedDate,
                    city: selectedCity,
                    category: selectedCategory,
                    imageURL: nil, // Will be generated from imageKey when needed
                    imageKey: imageKey,
                    location: location,
                    price: eventPrice
                )
                
                // Here you would typically save to your backend
                // For now, we'll just add to local events
                await MainActor.run {
                    eventManager.events.append(newEvent)
                    presentationMode.wrappedValue.dismiss()
                }
                
            } catch {
                await MainActor.run {
                    storageManager.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
