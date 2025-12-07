import SwiftUI
import MapKit
import Combine
// import Amplify
// import AWSS3StoragePlugin
// import AWSCognitoAuthPlugin
// import AWSAPIPlugin

// MARK: - Data Models
struct User {
    let id: String
    let name: String
    let email: String
    let city: City
}

enum City: String, CaseIterable {
    case dallas = "Dallas"
    case houston = "Houston"
    case austin = "Austin"
    case sanAntonio = "San Antonio"
    case corpusChristi = "Corpus Christi"
    
    var emoji: String {
        switch self {
        case .dallas: return "🏢"
        case .houston: return "🚀"
        case .austin: return "🎸"
        case .sanAntonio: return "🏛️"
        case .corpusChristi: return "🏖️"
        }
    }
    
    // Theme colors for each city
    var themeColors: (primary: Color, secondary: Color, gradient1: Color, gradient2: Color) {
        switch self {
        case .dallas:
            // Dallas: Blue & Gold (Corporate)
            return (
                primary: Color(red: 0.0, green: 0.4, blue: 0.8),
                secondary: Color(red: 1.0, green: 0.84, blue: 0.0),
                gradient1: Color(red: 0.0, green: 0.3, blue: 0.6),
                gradient2: Color(red: 0.0, green: 0.5, blue: 0.9)
            )
        case .houston:
            // Houston: Orange & Teal (Energy)
            return (
                primary: Color(red: 1.0, green: 0.55, blue: 0.0),
                secondary: Color(red: 0.0, green: 0.8, blue: 0.9),
                gradient1: Color(red: 0.9, green: 0.4, blue: 0.0),
                gradient2: Color(red: 0.2, green: 0.7, blue: 0.95)
            )
        case .austin:
            // Austin: Purple & Green (Creative)
            return (
                primary: Color(red: 0.6, green: 0.2, blue: 0.8),
                secondary: Color(red: 0.2, green: 0.9, blue: 0.4),
                gradient1: Color(red: 0.5, green: 0.1, blue: 0.7),
                gradient2: Color(red: 0.3, green: 0.8, blue: 0.5)
            )
        case .sanAntonio:
            // San Antonio: Red & Cream (Historic)
            return (
                primary: Color(red: 0.85, green: 0.1, blue: 0.2),
                secondary: Color(red: 1.0, green: 0.95, blue: 0.85),
                gradient1: Color(red: 0.75, green: 0.05, blue: 0.15),
                gradient2: Color(red: 0.95, green: 0.3, blue: 0.3)
            )
        case .corpusChristi:
            // Corpus Christi: Turquoise & Sand (Beach)
            return (
                primary: Color(red: 0.0, green: 0.8, blue: 0.9),
                secondary: Color(red: 1.0, green: 0.9, blue: 0.7),
                gradient1: Color(red: 0.0, green: 0.7, blue: 0.8),
                gradient2: Color(red: 0.1, green: 0.9, blue: 0.95)
            )
        }
    }
    
    var backgroundGradient: LinearGradient {
        let colors = themeColors
        return LinearGradient(
            gradient: Gradient(colors: [colors.gradient1, colors.gradient2]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum EventCategory: String, CaseIterable {
    case religious = "Religious"
    case cultural = "Cultural"
    case professional = "Professional"
    case kids = "Kids"
    case online = "Online"
    
    var icon: String {
        switch self {
        case .religious: return "om"
        case .cultural: return "theatermasks"
        case .professional: return "briefcase"
        case .kids: return "figure.2.and.child.holdinghands"
        case .online: return "wifi"
        }
    }
    
    var color: Color {
        switch self {
        case .religious: return .purple
        case .cultural: return .orange
        case .professional: return .blue
        case .kids: return .pink
        case .online: return .green
        }
    }
}

// MARK: - GraphQL Response Types
struct GraphQLResponse<T: Codable>: Codable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Codable {
    let message: String
}

struct ListEventsQuery: Codable {
    let listEvents: EventList?
}

struct EventList: Codable {
    let items: [EventItem]?
}

struct EventItem: Codable {
    let id: String?
    let title: String?
    let description: String?
    let date: String?
    let city: String?
    let category: String?
    let location: String?
    let price: Double?
    let imageURL: String?
    let imageKey: String?
}

// MARK: - Event Model
struct Event {
    let id: String
    let title: String
    let description: String
    let date: Date
    let city: City
    let category: EventCategory
    let imageURL: String?
    let imageKey: String?
    let location: String
    let price: Double?
    var attendees: Int = 0
    var isFavorite: Bool = false
    
    // Helper method to get full S3 URL
    func getImageURL() async -> URL? {
        guard let imageKey = imageKey else { return URL(string: imageURL ?? "") }
        // Amplify disabled for UI testing
        /*
        do {
            return try await Amplify.Storage.getURL(key: imageKey)
        } catch {
            print("Failed to get image URL: \(error)")
            return nil
        }
        */
        return URL(string: imageURL ?? "https://via.placeholder.com/300x200")
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

// MARK: - Custom Text Field Components
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Login View
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background: vibrant purple-pink-teal blend
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.08, green: 0.04, blue: 0.18),  // Deep purple
                        Color(red: 0.15, green: 0.08, blue: 0.25)   // Darker purple-blue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 50)
                        
                        // App Logo and Title
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                            Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 15, x: 0, y: 8)
                                
                                Image(systemName: "globe.asia.australia")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 20) {
                                Text("TXIndia")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                            Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                
                                Text("Connecting Indian Communities in Texas")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(16)
                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.2), radius: 10, x: 0, y: 4)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            VStack(spacing: 15) {
                                CustomTextField(
                                    icon: "envelope",
                                    placeholder: "Email",
                                    text: $email
                                )
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                
                                CustomSecureField(
                                    icon: "lock",
                                    placeholder: "Password",
                                    text: $password
                                )
                            }
                            
                            // Login Button
                            Button(action: {
                                authManager.login(email: email, password: password)
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    Text(authManager.isLoading ? "Signing In..." : "Login")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                        Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(15)
                                .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(authManager.isLoading)
                            
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                            
                            // Register Button
                            Button("Create New Account") {
                                showingRegister = true
                            }
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                    Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .fontWeight(.medium)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
    }
}
        // MARK: - Register View
        struct RegisterView: View {
            @State private var name = ""
            @State private var email = ""
            @State private var password = ""
            @Environment(\.presentationMode) var presentationMode
            @EnvironmentObject var authManager: AuthenticationManager
            
            var body: some View {
                NavigationView {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.08, green: 0.04, blue: 0.18),  // Deep purple
                                Color(red: 0.15, green: 0.08, blue: 0.25)   // Darker purple-blue
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 25) {
                                Text("Join TXIndia")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                            Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .padding(.top)
                                
                                VStack(spacing: 15) {
                                    CustomTextField(icon: "person", placeholder: "Full Name", text: $name)
                                    
                                    CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                    
                                    CustomSecureField(icon: "lock", placeholder: "Password", text: $password)
                                    
                                    Button(action: {
                                        // Register without city selection - use default city
                                        authManager.register(name: name, email: email, password: password, city: .dallas)
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                            Text("Create Account")
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                                Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .cornerRadius(15)
                                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.horizontal, 30)
                                
                                Spacer()
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                        }
                    }
                }
            }
        }
        
        // MARK: - Main Tab View
        struct MainTabView: View {
            @EnvironmentObject var cityManager: CityManager
            @StateObject var chatManager = ChatManager()
            @State private var isChatExpanded = false
            
            var body: some View {
                ZStack {
                    TabView {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                        
                        EventsView()
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("Events")
                            }
                        
                        ReligionView()
                            .tabItem {
                                Image(systemName: "sparkles")
                                Text("Religion")
                            }
                        
                        ClassifiedsView()
                            .tabItem {
                                Image(systemName: "tag")
                                Text("Classifieds")
                            }
                        
                        BusinessesView()
                            .tabItem {
                                Image(systemName: "building.2")
                                Text("Businesses")
                            }
                        
                        ProfileView()
                            .tabItem {
                                Image(systemName: "person")
                                Text("Profile")
                            }
                    }
                    .accentColor(cityManager.selectedCity.themeColors.primary)
                    
                    // Floating Chat Widget
                    VStack {
                        if isChatExpanded {
                            ChatWindowView(chatManager: chatManager, isExpanded: $isChatExpanded)
                                .frame(height: 500)
                                .padding()
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isChatExpanded.toggle()
                                }
                            }) {
                                if isChatExpanded {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.2, blue: 0.6),
                                                Color(red: 0.4, green: 0.8, blue: 0.95)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .clipShape(Circle())
                                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
                                } else {
                                    ZStack(alignment: .topTrailing) {
                                        VStack(spacing: 2) {
                                            Image(systemName: "bubble.right.fill")
                                                .font(.system(size: 20))
                                        }
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.2, blue: 0.6),
                                                Color(red: 0.4, green: 0.8, blue: 0.95)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .clipShape(Circle())
                                        .shadow(color: Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.4), radius: 8, x: 0, y: 4)
                                        
                                        if chatManager.messages.count > 0 {
                                            Text("\(chatManager.messages.count)")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 4, y: -4)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .environmentObject(chatManager)
                }
            }
        }
        
        // MARK: - Home View
        struct HomeView: View {
            @EnvironmentObject var cityManager: CityManager
            @EnvironmentObject var eventManager: EventManager
            @EnvironmentObject var authManager: AuthenticationManager
            
            var body: some View {
                NavigationView {
                    ZStack {
                        cityManager.selectedCity.backgroundGradient
                            .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 20) {
                            // Welcome Header
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Welcome back!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        if let user = authManager.currentUser {
                                            Text("Hello, \(user.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            
                            // City Selector - Prominent
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select City")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(City.allCases, id: \.self) { city in
                                            Button(action: {
                                                cityManager.selectedCity = city
                                                eventManager.fetchEvents(for: city)
                                            }) {
                                                VStack(spacing: 6) {
                                                    Text(city.emoji)
                                                        .font(.title2)
                                                    Text(city.rawValue)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.center)
                                                }
                                                .frame(width: 70, height: 90)                                .background(cityManager.selectedCity == city ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    city.themeColors.primary,
                                                    city.themeColors.secondary
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.white, Color.white]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                )
                                .foregroundColor(cityManager.selectedCity == city ? .white : .black)
                                .cornerRadius(12)
                                .shadow(color: cityManager.selectedCity == city ? city.themeColors.primary.opacity(0.4) : Color.clear, radius: 6, x: 0, y: 3)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
                            
                            // Quick Actions
                            SectionHeader(title: "Quick Actions", actionTitle: "View All")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                EnhancedQuickActionCard(title: "Upcoming Events", icon: "calendar", color: .blue, count: "12")
                                EnhancedQuickActionCard(title: "New Businesses", icon: "building.2", color: .green, count: "8")
                                EnhancedQuickActionCard(title: "Classifieds", icon: "tag", color: .purple, count: "25")
                                EnhancedQuickActionCard(title: "Online Events", icon: "wifi", color: .orange, count: "5")
                            }
                            .padding(.horizontal)
                            
                            // Featured Events
                            SectionHeader(title: "Featured Events", actionTitle: "See All")
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(eventManager.events.prefix(3), id: \.id) { event in
                                        EnhancedEventCard(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Latest News
                            SectionHeader(title: "Community News", actionTitle: "Read More")
                            
                            VStack(spacing: 12) {
                                ForEach(0..<3, id: \.self) { index in
                                    EnhancedNewsCard(index: index)
                                }
                            }
                            .padding(.horizontal)
                        }
                        }
                    }
                    .navigationTitle("TXIndia")
                    .navigationBarTitleDisplayMode(.large)
                }
                .onAppear {
                    eventManager.fetchEvents(for: cityManager.selectedCity)
                }
            }
        }
        
        // MARK: - Events View
        
struct EventsView: View {
    @EnvironmentObject var cityManager: CityManager
    @EnvironmentObject var eventManager: EventManager
    @State private var selectedCategory: EventCategory? = nil
    @State private var searchText = ""
    @State private var showingCreateEvent = false
    
    var filteredEvents: [Event] {
        // Fix: Use EventManager.sampleEvents instead of Event.EventManager.sampleEvents
        var events = eventManager.events.isEmpty ? EventManager.sampleEvents : eventManager.events
        
        if let category = selectedCategory {
            events = events.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            events = events.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return events.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                cityManager.selectedCity.backgroundGradient
                    .ignoresSafeArea()
                
                VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search events...", text: $searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // All Categories Button
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            Text("All")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? LinearGradient(
                                    gradient: Gradient(colors: [
                                        cityManager.selectedCity.themeColors.primary,
                                        cityManager.selectedCity.themeColors.secondary
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.3)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .foregroundColor(selectedCategory == nil ? .white : .black)
                                .cornerRadius(20)
                        }
                        
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.caption)
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? category.color : Color.white.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .white)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Events List
                if eventManager.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No events found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your search or category filter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEvents, id: \.id) { event in
                                EnhancedEventRowView(event: event)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {                            Button(action: {
                                showingCreateEvent = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                            }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(City.allCases, id: \.self) { city in
                            Button(action: {
                                cityManager.selectedCity = city
                                eventManager.fetchEvents(for: city)
                            }) {
                                HStack {
                                    Text(city.emoji)
                                    Text(city.rawValue)
                                    if city == cityManager.selectedCity {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(cityManager.selectedCity.emoji)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                }
                }
            }
            // Fix: Move the sheet modifier inside the NavigationView
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView()
                    .environmentObject(eventManager)
            }
        }
        .onAppear {
            if eventManager.events.isEmpty {
                eventManager.fetchEvents(for: cityManager.selectedCity)
            }
        }
    }
}
        
        // Add this **outside** the EventManager class
        extension EventManager {
            static let sampleEventsDetails: [Event] = [
                Event(
                    id: "1",
                    title: "Sample Event 1",
                    description: "This is a sample event",
                    date: Date(),
                    city: .dallas,
                    category: .cultural,
                    imageURL: nil,
                    imageKey: nil,
                    location: "Sample Location",
                    price: nil
                ),
                // Add more sample events here
            ]
        }
        
        // MARK: - Religion Models
        enum ReligionType: String, CaseIterable, Hashable {
            case hinduism = "Hinduism"
            case christianity = "Christianity"
            case islam = "Islam"
            case buddhism = "Buddhism"
            case sikhism = "Sikhism"
            case judaism = "Judaism"
            
            var icon: String {
                switch self {
                case .hinduism: return "om"
                case .christianity: return "cross.fill"
                case .islam: return "moon.stars.fill"
                case .buddhism: return "flame.fill"
                case .sikhism: return "star.fill"
                case .judaism: return "star.of.david.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .hinduism: return Color(red: 1.0, green: 0.6, blue: 0.0)
                case .christianity: return Color(red: 0.8, green: 0.1, blue: 0.2)
                case .islam: return Color(red: 0.0, green: 0.5, blue: 0.0)
                case .buddhism: return Color(red: 1.0, green: 0.8, blue: 0.0)
                case .sikhism: return Color(red: 0.8, green: 0.6, blue: 0.0)
                case .judaism: return Color(red: 0.0, green: 0.0, blue: 0.5)
                }
            }
            
            var description: String {
                switch self {
                case .hinduism:
                    return "Hinduism is one of the world's oldest religions, with diverse practices and philosophies centered on dharma (duty), karma (action), and moksha (liberation)."
                case .christianity:
                    return "Christianity is based on the teachings of Jesus Christ and emphasizes salvation through faith, love for God, and compassion for others."
                case .islam:
                    return "Islam is an Abrahamic religion based on the teachings of the Prophet Muhammad, centered on submission to Allah and following the Five Pillars."
                case .buddhism:
                    return "Buddhism focuses on the path to enlightenment through following the Four Noble Truths and the Noble Eightfold Path, emphasizing compassion and mindfulness."
                case .sikhism:
                    return "Sikhism teaches belief in one God and emphasizes equality, justice, and service to others through Gurdwaras and community-oriented practices."
                case .judaism:
                    return "Judaism is based on Torah and the teachings of the Prophets, emphasizing ethical monotheism and the covenant between God and the Jewish people."
                }
            }
            
            var practices: [String] {
                switch self {
                case .hinduism:
                    return ["Meditation & Yoga", "Puja (Prayer Rituals)", "Pilgrimage", "Dharma & Karma"]
                case .christianity:
                    return ["Prayer", "Church Services", "Bible Study", "Community Service"]
                case .islam:
                    return ["Prayer (Salah)", "Fasting (Sawm)", "Pilgrimage", "Charity (Zakat)"]
                case .buddhism:
                    return ["Meditation", "Mindfulness", "Study of Dharma", "Service to Others"]
                case .sikhism:
                    return ["Meditation on God", "Langar (Community Meal)", "Kirtan (Singing)", "Service"]
                case .judaism:
                    return ["Prayer", "Sabbath Observance", "Torah Study", "Kosher Living"]
                }
            }
        }
        
        struct Religion: Identifiable {
            let id = UUID()
            let type: ReligionType
            let description: String
            let practices: [String]
            let followers: String
            let originCountry: String
            let history: String
            
            static let allReligions: [Religion] = [
                Religion(
                    type: .hinduism,
                    description: ReligionType.hinduism.description,
                    practices: ReligionType.hinduism.practices,
                    followers: "1.2 Billion+",
                    originCountry: "India",
                    history: "Hinduism originated in India over 3,500 years ago. It is characterized by diverse philosophical and spiritual traditions, including the practice of yoga, meditation, and devotion to various deities."
                ),
                Religion(
                    type: .christianity,
                    description: ReligionType.christianity.description,
                    practices: ReligionType.christianity.practices,
                    followers: "2.4 Billion+",
                    originCountry: "Middle East",
                    history: "Christianity began in the 1st century with the teachings of Jesus Christ and has become the world's largest religion, emphasizing faith in Christ's redemption."
                ),
                Religion(
                    type: .islam,
                    description: ReligionType.islam.description,
                    practices: ReligionType.islam.practices,
                    followers: "1.8 Billion+",
                    originCountry: "Saudi Arabia",
                    history: "Islam was founded by Prophet Muhammad in the 7th century and is based on the Quran. It emphasizes monotheism and submission to the will of Allah."
                ),
                Religion(
                    type: .buddhism,
                    description: ReligionType.buddhism.description,
                    practices: ReligionType.buddhism.practices,
                    followers: "520 Million+",
                    originCountry: "India/Nepal",
                    history: "Buddhism originated with Siddhartha Gautama (Buddha) in the 5th century BCE. It focuses on ending suffering through enlightenment and the pursuit of inner peace."
                ),
                Religion(
                    type: .sikhism,
                    description: ReligionType.sikhism.description,
                    practices: ReligionType.sikhism.practices,
                    followers: "30 Million+",
                    originCountry: "India",
                    history: "Sikhism was founded by Guru Nanak in 15th century Punjab, India. It promotes equality, social justice, and service to humanity through Gurdwaras."
                ),
                Religion(
                    type: .judaism,
                    description: ReligionType.judaism.description,
                    practices: ReligionType.judaism.practices,
                    followers: "15 Million+",
                    originCountry: "Middle East",
                    history: "Judaism is one of the world's oldest religions, dating back over 4,000 years. It is centered on Torah, the Talmud, and ethical monotheism."
                )
            ]
        }
        
        struct Temple: Identifiable {
            let id = UUID()
            let name: String
            let religion: ReligionType
            let city: City
            let address: String
            let phone: String
            let website: String?
            let serviceTime: String
            let description: String
            let amenities: [String]
            
            static let sampleTemples: [Temple] = [
                // Dallas
                Temple(
                    name: "Sri Venkateswara Temple",
                    religion: .hinduism,
                    city: .dallas,
                    address: "5425 Abrams Rd, Dallas, TX 75231",
                    phone: "(972) 248-9090",
                    website: "www.svtdallas.org",
                    serviceTime: "Daily 8AM-6PM",
                    description: "A beautiful Hindu temple dedicated to Lord Venkateswara with traditional architecture and cultural programs.",
                    amenities: ["Puja Services", "Classes", "Cultural Events", "Vegetarian Kitchen"]
                ),
                Temple(
                    name: "St. Michael's Cathedral",
                    religion: .christianity,
                    city: .dallas,
                    address: "1001 N Harwood St, Dallas, TX 75201",
                    phone: "(214) 969-1911",
                    website: "www.saintmichaelsdallas.org",
                    serviceTime: "Sunday 8AM, 10AM, 12PM",
                    description: "Historic Catholic cathedral in downtown Dallas offering Mass and spiritual services.",
                    amenities: ["Sunday Mass", "Confessions", "Bible Study", "Community Services"]
                ),
                Temple(
                    name: "Masjid Al-Islam",
                    religion: .islam,
                    city: .dallas,
                    address: "4820 Malcolm X Blvd, Dallas, TX 75215",
                    phone: "(214) 428-1700",
                    website: "www.masjidalislam.com",
                    serviceTime: "5 Daily Prayers",
                    description: "Major Islamic mosque serving the Dallas Muslim community with Friday prayers and educational programs.",
                    amenities: ["Prayer Halls", "Quran Classes", "Halal Food", "Women's Section"]
                ),
                
                // Houston
                Temple(
                    name: "Sai Baba Temple",
                    religion: .hinduism,
                    city: .houston,
                    address: "4215 Bellaire Blvd, Houston, TX 77025",
                    phone: "(713) 661-0312",
                    website: "www.saibabatemplehouston.org",
                    serviceTime: "Daily 8AM-8PM",
                    description: "Devotional temple dedicated to Shirdi Sai Baba with spiritual programs and community gatherings.",
                    amenities: ["Puja Services", "Meditation Classes", "Aarti", "Spiritual Counseling"]
                ),
                Temple(
                    name: "Christ Church Cathedral",
                    religion: .christianity,
                    city: .houston,
                    address: "1117 Texas Ave, Houston, TX 77002",
                    phone: "(713) 221-2664",
                    website: "www.christchurchhouston.org",
                    serviceTime: "Sunday 7:30AM, 9AM, 11AM",
                    description: "Historic Episcopal cathedral in downtown Houston offering traditional and contemporary worship.",
                    amenities: ["Sunday Services", "Adult Education", "Youth Programs", "Counseling"]
                ),
                
                // Austin
                Temple(
                    name: "Arsha Vidya Gurukulam",
                    religion: .hinduism,
                    city: .austin,
                    address: "3500 Bee Cave Rd, Austin, TX 78746",
                    phone: "(512) 258-3456",
                    website: "www.arshavidya.org",
                    serviceTime: "Daily Classes & Worship",
                    description: "Vedic learning center and temple offering Sanskrit classes, meditation, and Vedantic philosophy.",
                    amenities: ["Vedanta Classes", "Meditation", "Yoga", "Library"]
                ),
                Temple(
                    name: "The University of Texas Hindu Students",
                    religion: .hinduism,
                    city: .austin,
                    address: "Various Locations, Austin, TX",
                    phone: "(512) 123-4567",
                    website: "www.uthinduorg.com",
                    serviceTime: "Monthly Events",
                    description: "Student organization promoting Hindu culture, philosophy, and community service.",
                    amenities: ["Study Groups", "Cultural Events", "Mentorship", "Social Service"]
                ),
                
                // San Antonio
                Temple(
                    name: "Sri Meenakshi Temple",
                    religion: .hinduism,
                    city: .sanAntonio,
                    address: "8715 Steubing Ln, San Antonio, TX 78230",
                    phone: "(210) 696-6686",
                    website: "www.srisanantonio.org",
                    serviceTime: "Daily 7AM-9PM",
                    description: "South Indian temple with traditional Meenakshi shrine offering Puja and festivals.",
                    amenities: ["Puja Services", "Festival Celebrations", "Vegetarian Kitchen", "Classes"]
                ),
                Temple(
                    name: "Sikh Gurdwara Singh Sabha",
                    religion: .sikhism,
                    city: .sanAntonio,
                    address: "2022 East Commerce St, San Antonio, TX 78220",
                    phone: "(210) 222-7533",
                    website: "www.gurudwarasasikhsa.org",
                    serviceTime: "Daily Services",
                    description: "Sikh temple serving the community with Langar (free meal) and spiritual programs.",
                    amenities: ["Langar", "Prayer Halls", "Kirtan", "Community Service"]
                ),
                
                // Corpus Christi
                Temple(
                    name: "Hindu Temple & Cultural Society",
                    religion: .hinduism,
                    city: .corpusChristi,
                    address: "5606 S Staples St, Corpus Christi, TX 78411",
                    phone: "(361) 888-8867",
                    website: "www.hindutemplecorpus.org",
                    serviceTime: "Daily 6AM-8PM",
                    description: "Community temple offering worship, cultural classes, and Hindu festivals.",
                    amenities: ["Puja Services", "Kids Classes", "Festivals", "Youth Programs"]
                )
            ]
        }
        
        // MARK: - Religion View
        struct ReligionView: View {
            @EnvironmentObject var cityManager: CityManager
            @State private var selectedTab: ReligionTab = .explore
            @State private var selectedReligion: ReligionType? = nil
            @State private var searchText = ""
            
            var body: some View {
                NavigationView {
                    ZStack {
                        cityManager.selectedCity.backgroundGradient
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Tab Selector
                            Picker("", selection: $selectedTab) {
                                ForEach(ReligionTab.allCases, id: \.self) { tab in
                                    Text(tab.rawValue).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            
                            // Content
                            if selectedTab == .explore {
                                ExploreReligionsView(selectedReligion: $selectedReligion, cityManager: cityManager)
                            } else if selectedTab == .temples {
                                TempleDirectoryView(selectedCity: cityManager.selectedCity)
                            } else {
                                ReligiousEventsView(cityManager: cityManager)
                            }
                        }
                        .navigationTitle("Religion & Spirituality")
                        .navigationBarTitleDisplayMode(.large)
                    }
                }
            }
        }
        
        enum ReligionTab: String, CaseIterable {
            case explore = "Explore"
            case temples = "Temples"
            case events = "Events"
        }
        
        struct ExploreReligionsView: View {
            @Binding var selectedReligion: ReligionType?
            let cityManager: CityManager
            
            var body: some View {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Religion.allReligions, id: \.id) { religion in
                            NavigationLink(destination: ReligionDetailView(religion: religion, cityManager: cityManager)) {
                                ReligionCardView(religion: religion, cityManager: cityManager)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        
        struct ReligionCardView: View {
            let religion: Religion
            let cityManager: CityManager
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: religion.type.icon)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(religion.type.color)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(religion.type.rawValue)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(religion.followers)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(religion.originCountry)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    Text(religion.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        
        struct ReligionDetailView: View {
            let religion: Religion
            let cityManager: CityManager
            
            var body: some View {
                ZStack {
                    cityManager.selectedCity.backgroundGradient
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            HStack(spacing: 16) {
                                Image(systemName: religion.type.icon)
                                    .font(.system(size: 48))
                                    .foregroundColor(.white)
                                    .frame(width: 80, height: 80)
                                    .background(religion.type.color)
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(religion.type.rawValue)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(religion.followers)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // Overview
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Overview")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(religion.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            // History
                            VStack(alignment: .leading, spacing: 8) {
                                Text("History & Origins")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(religion.history)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            // Practices
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Practices")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(religion.practices, id: \.self) { practice in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(religion.type.color)
                                            Text(practice)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
                .navigationTitle(religion.type.rawValue)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        struct TempleDirectoryView: View {
            let selectedCity: City
            
            var filteredTemples: [Temple] {
                Temple.sampleTemples.filter { $0.city == selectedCity }
            }
            
            var body: some View {
                ScrollView {
                    VStack(spacing: 12) {
                        if filteredTemples.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "building.2.badge.exclamationmark")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("No temples found in \(selectedCity.rawValue)")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxHeight: .infinity)
                            .padding()
                        } else {
                            ForEach(filteredTemples) { temple in
                                TempleCardView(temple: temple)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        
        struct TempleCardView: View {
            let temple: Temple
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: temple.religion.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(temple.religion.color)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(temple.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            Text(temple.religion.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    Text(temple.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(temple.religion.color)
                                Text(temple.address)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                    .font(.caption)
                                    .foregroundColor(temple.religion.color)
                                Text(temple.phone)
                                    .font(.caption2)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(temple.religion.color)
                                Text(temple.serviceTime)
                                    .font(.caption2)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Button(action: {}) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(temple.religion.color)
                                    .cornerRadius(8)
                            }
                            
                            if let website = temple.website {
                                Button(action: {}) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(temple.religion.color.opacity(0.7))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Amenities
                    FlowLayout(spacing: 6) {
                        ForEach(temple.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(temple.religion.color.opacity(0.7))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        
        struct ReligiousEventsView: View {
            let cityManager: CityManager
            @State private var selectedReligion: ReligionType? = nil
            
            var filteredEvents: [ReligiousEvent] {
                let events = ReligiousEvent.sampleEvents
                if let religion = selectedReligion {
                    return events.filter { $0.religion == religion }
                }
                return events
            }
            
            var body: some View {
                VStack(spacing: 12) {
                    // Religion Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button(action: { selectedReligion = nil }) {
                                Text("All")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedReligion == nil ? LinearGradient(gradient: Gradient(colors: [cityManager.selectedCity.themeColors.primary, cityManager.selectedCity.themeColors.secondary]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(selectedReligion == nil ? .white : .black)
                                    .cornerRadius(16)
                            }
                            
                            ForEach(ReligionType.allCases, id: \.self) { religion in
                                Button(action: { selectedReligion = religion }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: religion.icon)
                                            .font(.caption)
                                        Text(religion.rawValue)
                                            .font(.caption2)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(selectedReligion == religion ? religion.color : Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Events List
                    ScrollView {
                        VStack(spacing: 12) {
                            if filteredEvents.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No events found")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxHeight: .infinity)
                                .padding()
                            } else {
                                ForEach(filteredEvents) { event in
                                    ReligiousEventCardView(event: event)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        
        struct ReligiousEvent: Identifiable {
            let id = UUID()
            let title: String
            let religion: ReligionType
            let date: Date
            let time: String
            let location: String
            let description: String
            let organized: String
            
            static let sampleEvents: [ReligiousEvent] = [
                ReligiousEvent(
                    title: "Diwali Celebration - Festival of Lights",
                    religion: .hinduism,
                    date: Date().addingTimeInterval(86400 * 10),
                    time: "6:00 PM",
                    location: "Sri Venkateswara Temple, Dallas",
                    description: "Join us for a vibrant celebration of Diwali with prayers, fireworks, and cultural performances.",
                    organized: "Hindu Temple"
                ),
                ReligiousEvent(
                    title: "Easter Sunday Service",
                    religion: .christianity,
                    date: Date().addingTimeInterval(86400 * 15),
                    time: "10:00 AM",
                    location: "St. Michael's Cathedral, Dallas",
                    description: "Celebrate the resurrection of Jesus Christ with our Easter Sunday worship service.",
                    organized: "Catholic Church"
                ),
                ReligiousEvent(
                    title: "Iftar Dinner - Breaking the Fast",
                    religion: .islam,
                    date: Date().addingTimeInterval(86400 * 5),
                    time: "7:30 PM",
                    location: "Masjid Al-Islam, Dallas",
                    description: "Community Iftar dinner during Ramadan to break the fast and strengthen community bonds.",
                    organized: "Islamic Community"
                ),
                ReligiousEvent(
                    title: "Buddha's Birthday Celebration",
                    religion: .buddhism,
                    date: Date().addingTimeInterval(86400 * 20),
                    time: "2:00 PM",
                    location: "Buddhist Center, Houston",
                    description: "Celebrate the enlightenment of Buddha with meditation and dharma talks.",
                    organized: "Buddhist Temple"
                ),
                ReligiousEvent(
                    title: "Vaisakhi Celebration",
                    religion: .sikhism,
                    date: Date().addingTimeInterval(86400 * 25),
                    time: "11:00 AM",
                    location: "Sikh Gurdwara, San Antonio",
                    description: "Annual Sikh festival celebrating the birth of Khalsa with langar and kirtan.",
                    organized: "Sikh Community"
                ),
                ReligiousEvent(
                    title: "Hanukkah Menorah Lighting",
                    religion: .judaism,
                    date: Date().addingTimeInterval(86400 * 30),
                    time: "6:00 PM",
                    location: "Jewish Temple, Austin",
                    description: "Eight-day festival celebrating the dedication of the holy temple with menorah lighting.",
                    organized: "Jewish Community"
                )
            ]
        }
        
        struct ReligiousEventCardView: View {
            let event: ReligiousEvent
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: event.religion.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(event.religion.color)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            Text(event.religion.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.fill")
                                    .font(.caption)
                                    .foregroundColor(event.religion.color)
                                Text(event.date, style: .date)
                                    .font(.caption2)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(event.religion.color)
                                Text(event.time)
                                    .font(.caption2)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(event.religion.color)
                                Text(event.location)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("RSVP")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(event.religion.color)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        
        // MARK: - Placeholder Views
        struct ClassifiedsView: View {
            @State private var showingPostingView = false
            @State private var selectedTab: ClassifiedsTab = .browse
            @EnvironmentObject var authManager: AuthenticationManager
            @EnvironmentObject var cityManager: CityManager
            
            var body: some View {
                NavigationView {
                    VStack(spacing: 0) {
                        // Tab Selector
                        Picker("", selection: $selectedTab) {
                            ForEach(ClassifiedsTab.allCases, id: \.self) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        
                        // Content
                        if selectedTab == .browse {
                            BrowseClassifiedsView()
                                .environmentObject(cityManager)
                        } else {
                            PostClassifiedView()
                                .environmentObject(cityManager)
                        }
                    }
                    .navigationTitle("Classifieds")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        
        enum ClassifiedsTab: String, CaseIterable {
            case browse = "Browse"
            case post = "Post"
        }
        
        struct BrowseClassifiedsView: View {
            @State private var selectedCategory: ClassifiedCategory = .all
            @EnvironmentObject var cityManager: CityManager
            
            var filteredListings: [ClassifiedListing] {
                let listings = ClassifiedListing.sampleListings
                if selectedCategory == .all {
                    return listings
                }
                return listings.filter { $0.category == selectedCategory }
            }
            
            var body: some View {
                VStack {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ClassifiedCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(selectedCategory == category ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Group {
                                                if selectedCategory == category {
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color(red: 1.0, green: 0.2, blue: 0.6),
                                                            Color(red: 0.4, green: 0.8, blue: 0.95)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                } else {
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.gray.opacity(0.1),
                                                            Color.gray.opacity(0.1)
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                }
                                            }
                                        )
                                        .cornerRadius(20)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Listings
                    ScrollView {
                        VStack(spacing: 12) {
                            if filteredListings.isEmpty {
                                VStack {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No classifieds found")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxHeight: .infinity)
                                .padding()
                            } else {
                                ForEach(filteredListings) { listing in
                                    ClassifiedCard(listing: listing)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        
        struct ClassifiedCard: View {
            let listing: ClassifiedListing
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    // Image & Badge
                    ZStack(alignment: .topTrailing) {
                        AsyncImageView(
                            imageKey: listing.imageKey,
                            placeholder: listing.category.icon,
                            height: 150
                        )
                        .cornerRadius(12)
                        
                        Text(listing.category.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(listing.category.color)
                            .cornerRadius(8)
                            .padding(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Title & Price
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(listing.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Text(listing.location)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Text(listing.formattedPrice)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.6),
                                        Color(red: 0.4, green: 0.8, blue: 0.95)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        }
                        
                        // Description
                        Text(listing.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        // Details
                        HStack(spacing: 16) {
                            ForEach(listing.details, id: \.self) { detail in
                                Label(detail, systemImage: listing.category.detailIcon)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Seller Info & Contact
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Posted by \(listing.postedBy)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                Text(listing.postedDate)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "message.fill")
                                    Text("Contact")
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.6),
                                        Color(red: 0.4, green: 0.8, blue: 0.95)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(12)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
            }
        }
        
        struct PostClassifiedView: View {
            @State private var title = ""
            @State private var description = ""
            @State private var price = ""
            @State private var category: ClassifiedCategory = .cars
            @State private var selectedImage: UIImage?
            @State private var showingImagePicker = false
            @State private var details = ""
            @EnvironmentObject var cityManager: CityManager
            
            var body: some View {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.6),
                                        Color(red: 0.4, green: 0.8, blue: 0.95)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            Text("Post a New Classified")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Share what you're selling or renting")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        
                        VStack(spacing: 16) {
                            // Category Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Category", systemImage: "tag.fill")
                                    .fontWeight(.semibold)
                                
                                Picker("Category", selection: $category) {
                                    ForEach(ClassifiedCategory.allCases.filter { $0 != .all }, id: \.self) { cat in
                                        Text(cat.rawValue).tag(cat)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Title", systemImage: "pencil")
                                    .fontWeight(.semibold)
                                
                                TextField("e.g., 2019 Honda Civic...", text: $title)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Price
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Price", systemImage: "dollarsign.circle.fill")
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Text("$")
                                    TextField("0", text: $price)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Description", systemImage: "list.bullet")
                                    .fontWeight(.semibold)
                                
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .border(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                            
                            // Details (Category Specific)
                            VStack(alignment: .leading, spacing: 8) {
                                Label(category.detailPlaceholder, systemImage: "info.circle.fill")
                                    .fontWeight(.semibold)
                                
                                TextField(category.detailPlaceholder, text: $details)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Image Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Add Photo", systemImage: "photo.fill")
                                    .fontWeight(.semibold)
                                
                                Button(action: { showingImagePicker = true }) {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 150)
                                            .clipped()
                                            .cornerRadius(12)
                                    } else {
                                        VStack(spacing: 12) {
                                            Image(systemName: "photo.badge.plus")
                                                .font(.system(size: 32))
                                                .foregroundColor(.gray)
                                            Text("Tap to add a photo")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 150)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                .sheet(isPresented: $showingImagePicker) {
                                    ImagePicker(selectedImage: $selectedImage)
                                }
                            }
                            
                            // Submit Button
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Post Classified")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.2, blue: 0.6),
                                        Color(red: 0.4, green: 0.8, blue: 0.95)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
        
        enum ClassifiedCategory: String, CaseIterable {
            case all = "All"
            case cars = "Cars"
            case apartments = "Apartments"
            case furniture = "Furniture"
            case jobs = "Jobs"
            case services = "Services"
            
            var icon: String {
                switch self {
                case .all: return "list.bullet"
                case .cars: return "car.fill"
                case .apartments: return "building.2.fill"
                case .furniture: return "chair.lounge.fill"
                case .jobs: return "briefcase.fill"
                case .services: return "wrench.and.hammer.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .all: return .gray
                case .cars: return Color(red: 1.0, green: 0.4, blue: 0.3)
                case .apartments: return Color(red: 0.3, green: 0.6, blue: 1.0)
                case .furniture: return Color(red: 0.8, green: 0.5, blue: 0.3)
                case .jobs: return Color(red: 0.2, green: 0.8, blue: 0.4)
                case .services: return Color(red: 0.9, green: 0.5, blue: 0.7)
                }
            }
            
            var detailIcon: String {
                switch self {
                case .cars: return "speedometer"
                case .apartments: return "bed.double.fill"
                case .furniture: return "square.fill"
                case .jobs: return "person.fill"
                case .services: return "star.fill"
                default: return "info.circle"
                }
            }
            
            var detailPlaceholder: String {
                switch self {
                case .cars: return "Mileage, Year, Make, Model"
                case .apartments: return "Bedrooms, Bathrooms, Sq Ft"
                case .furniture: return "Condition, Dimensions"
                case .jobs: return "Position, Experience Required"
                case .services: return "Service Type, Expertise"
                default: return "Additional Details"
                }
            }
        }
        
        struct ClassifiedListing: Identifiable {
            let id = UUID()
            let title: String
            let description: String
            let price: Double
            let category: ClassifiedCategory
            let location: String
            let imageKey: String
            let postedBy: String
            let postedDate: String
            let details: [String]
            
            var formattedPrice: String {
                return String(format: "$%.0f", price)
            }
            
            static let sampleListings: [ClassifiedListing] = [
                // Cars
                ClassifiedListing(
                    title: "2019 Honda Civic - Excellent Condition",
                    description: "Well-maintained sedan with full service history. Clean interior, recently serviced brakes and tires.",
                    price: 14500,
                    category: .cars,
                    location: "Dallas, TX",
                    imageKey: "car1",
                    postedBy: "John Smith",
                    postedDate: "2 days ago",
                    details: ["92K miles", "Automatic", "Gray"]
                ),
                ClassifiedListing(
                    title: "2015 Toyota Camry - Great Deal",
                    description: "Reliable family sedan. Original owner, all records available. Recently updated suspension.",
                    price: 12800,
                    category: .cars,
                    location: "Houston, TX",
                    imageKey: "car2",
                    postedBy: "Maria Garcia",
                    postedDate: "5 days ago",
                    details: ["118K miles", "Automatic", "Blue"]
                ),
                ClassifiedListing(
                    title: "2021 Ford F-150 Pickup",
                    description: "Like new condition with extended warranty. Premium sound system, backup camera.",
                    price: 28500,
                    category: .cars,
                    location: "Austin, TX",
                    imageKey: "car3",
                    postedBy: "David Brown",
                    postedDate: "1 week ago",
                    details: ["45K miles", "4WD", "Red"]
                ),
                
                // Apartments
                ClassifiedListing(
                    title: "Modern 2BR/2BA Apartment - Downtown Dallas",
                    description: "Newly renovated with hardwood floors, stainless steel appliances, in-unit laundry. Close to restaurants and shops.",
                    price: 1800,
                    category: .apartments,
                    location: "Downtown Dallas, TX",
                    imageKey: "apt1",
                    postedBy: "Luxury Apartments LLC",
                    postedDate: "3 days ago",
                    details: ["1000 sqft", "Gym Access", "Pool"]
                ),
                ClassifiedListing(
                    title: "Cozy 1BR Studio with Patio - Houston",
                    description: "Sunny studio with garden patio. Perfect for professionals. Water and trash included in rent.",
                    price: 1200,
                    category: .apartments,
                    location: "Heights, Houston, TX",
                    imageKey: "apt2",
                    postedBy: "Sarah's Rentals",
                    postedDate: "1 day ago",
                    details: ["650 sqft", "Pet-Friendly", "Furnished"]
                ),
                ClassifiedListing(
                    title: "Spacious 3BR House - Family Friendly",
                    description: "Large backyard, great schools nearby. Recently painted, new roof. Washer/dryer included.",
                    price: 2400,
                    category: .apartments,
                    location: "Suburban Austin, TX",
                    imageKey: "apt3",
                    postedBy: "HomeRent Properties",
                    postedDate: "4 days ago",
                    details: ["1800 sqft", "Garage", "Yard"]
                ),
                
                // Furniture
                ClassifiedListing(
                    title: "Sectional Sofa - Like New",
                    description: "Gray sectional, very comfortable, barely used. Must go this week!",
                    price: 450,
                    category: .furniture,
                    location: "San Antonio, TX",
                    imageKey: "furn1",
                    postedBy: "Robert Wilson",
                    postedDate: "6 days ago",
                    details: ["8ft wide", "Stain-resistant", "Moveable"]
                ),
                ClassifiedListing(
                    title: "Dining Table Set - 6 Chairs",
                    description: "Oak wood dining set with matching chairs. Glass top. No scratches.",
                    price: 350,
                    category: .furniture,
                    location: "Corpus Christi, TX",
                    imageKey: "furn2",
                    postedBy: "Emma Taylor",
                    postedDate: "3 days ago",
                    details: ["Seats 6", "Oak Wood", "Like New"]
                ),
                
                // Services
                ClassifiedListing(
                    title: "Professional House Cleaning",
                    description: "Eco-friendly cleaning products. Experienced team. Free estimates. Licensed & insured.",
                    price: 150,
                    category: .services,
                    location: "Dallas, TX",
                    imageKey: "svc1",
                    postedBy: "Crystal Clean Services",
                    postedDate: "2 days ago",
                    details: ["Flexible", "Insured", "Eco-Friendly"]
                ),
                ClassifiedListing(
                    title: "Affordable Web Design & Development",
                    description: "Custom websites for small businesses. SEO optimization included. 5+ years experience.",
                    price: 1500,
                    category: .services,
                    location: "Austin, TX",
                    imageKey: "svc2",
                    postedBy: "Tech Solutions Pro",
                    postedDate: "1 week ago",
                    details: ["Mobile", "SEO", "Support"]
                ),
                
                // Jobs
                ClassifiedListing(
                    title: "Experienced Plumber Needed",
                    description: "Growing plumbing company seeking experienced plumbers. Good pay, benefits, advancement opportunities.",
                    price: 55000,
                    category: .jobs,
                    location: "Houston, TX",
                    imageKey: "job1",
                    postedBy: "Premier Plumbing Co.",
                    postedDate: "4 days ago",
                    details: ["Full-time", "Benefits", "Exp. Required"]
                ),
            ]
        }
        
        struct BusinessesView: View {
            @State private var selectedCategory: BusinessCategory = .all
            @State private var searchText = ""
            @EnvironmentObject var cityManager: CityManager
            
            var filteredBusinesses: [Business] {
                var businesses = Business.sampleBusinesses
                
                if selectedCategory != .all {
                    businesses = businesses.filter { $0.category == selectedCategory }
                }
                
                if !searchText.isEmpty {
                    businesses = businesses.filter {
                        $0.name.localizedCaseInsensitiveContains(searchText) ||
                        $0.description.localizedCaseInsensitiveContains(searchText)
                    }
                }
                
                return businesses.sorted { $0.rating > $1.rating }
            }
            
            var body: some View {
                NavigationView {
                    ZStack {
                        cityManager.selectedCity.backgroundGradient
                            .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("Search businesses...", text: $searchText)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(BusinessCategory.allCases, id: \.self) { category in
                                        Button(action: { selectedCategory = category }) {
                                            VStack(spacing: 4) {
                                                Image(systemName: category.icon)
                                                    .font(.system(size: 18))
                                                Text(category.rawValue)
                                                    .font(.caption2)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(width: 70, height: 90)
                                            .background(selectedCategory == category ?
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        cityManager.selectedCity.themeColors.primary,
                                                        cityManager.selectedCity.themeColors.secondary
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.white, Color.white]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .foregroundColor(selectedCategory == category ? .white : .black)
                                            .cornerRadius(12)
                                            .shadow(color: selectedCategory == category ?
                                                cityManager.selectedCity.themeColors.primary.opacity(0.4) :
                                                Color.clear, radius: 6, x: 0, y: 3)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Businesses List
                            if filteredBusinesses.isEmpty {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "building.2.badge.exclamationmark")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("No businesses found")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Try adjusting your search or category filter")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(filteredBusinesses, id: \.id) { business in
                                            BusinessCardView(business: business, cityColors: cityManager.selectedCity.themeColors)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .navigationTitle("Businesses")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        
        // MARK: - Business Models
        enum BusinessCategory: String, CaseIterable, Hashable {
            case all = "All"
            case accountants = "Accountants"
            case doctors = "Doctors"
            case realEstate = "Real Estate"
            case restaurants = "Restaurants"
            case groceries = "Groceries"
            case beauty = "Beauty & Spa"
            case lawyers = "Lawyers"
            case insurance = "Insurance"
            case travel = "Travel"
            case wedding = "Wedding"
            case photography = "Photography"
            case tutoring = "Tutoring"
            case homeServices = "Home Services"
            case plumbing = "Plumbing"
            case electrical = "Electrical"
            case danceSchool = "Dance School"
            case jewellery = "Jewellery"
            case movers = "Movers"
            
            var icon: String {
                switch self {
                case .all: return "list.bullet"
                case .accountants: return "doc.text.fill"
                case .doctors: return "stethoscope"
                case .realEstate: return "house.fill"
                case .restaurants: return "fork.knife"
                case .groceries: return "cart.fill"
                case .beauty: return "sparkles"
                case .lawyers: return "scale.3d"
                case .insurance: return "shield.fill"
                case .travel: return "airplane"
                case .wedding: return "heart.fill"
                case .photography: return "camera.fill"
                case .tutoring: return "book.fill"
                case .homeServices: return "hammer.fill"
                case .plumbing: return "wrench.and.hammer.fill"
                case .electrical: return "bolt.fill"
                case .danceSchool: return "music.note"
                case .jewellery: return "diamond.fill"
                case .movers: return "truck.box.fill"
                }
            }
        }
        
        struct Business: Identifiable {
            let id = UUID()
            let name: String
            let category: BusinessCategory
            let description: String
            let address: String
            let phone: String
            let email: String
            let website: String?
            let rating: Double
            let reviews: Int
            let hours: String
            let image: String
            let specialties: [String]
            
            static let sampleBusinesses: [Business] = [
                // Accountants & Taxes
                Business(
                    name: "Singh & Associates - CPA Firm",
                    category: .accountants,
                    description: "Expert tax preparation, bookkeeping, and business accounting services for individuals and small businesses.",
                    address: "2845 Oak Lawn Ave, Dallas, TX",
                    phone: "(214) 555-0142",
                    email: "info@singhcpa.com",
                    website: "www.singhcpa.com",
                    rating: 4.8,
                    reviews: 127,
                    hours: "Mon-Fri: 9AM-6PM",
                    image: "doc.text.fill",
                    specialties: ["Tax Planning", "Small Business", "Personal Taxes", "Bookkeeping"]
                ),
                Business(
                    name: "Patel Tax Solutions",
                    category: .accountants,
                    description: "Specialized in H1B tax returns, NRI taxation, and investment planning for Indian professionals.",
                    address: "1200 Main St, Houston, TX",
                    phone: "(713) 555-0198",
                    email: "hello@pateltax.com",
                    website: "www.pateltax.com",
                    rating: 4.9,
                    reviews: 89,
                    hours: "Mon-Sat: 9AM-7PM",
                    image: "doc.text.fill",
                    specialties: ["H1B Taxes", "NRI Taxation", "Investment Planning"]
                ),
                
                // Doctors & Medical Services
                Business(
                    name: "Dr. Sharma's Family Medicine Clinic",
                    category: .doctors,
                    description: "Comprehensive family medicine with focus on preventive care and chronic disease management.",
                    address: "3456 Medical Plaza, Austin, TX",
                    phone: "(512) 555-0175",
                    email: "clinic@drsharma.com",
                    website: "www.drsharma.com",
                    rating: 4.7,
                    reviews: 234,
                    hours: "Mon-Fri: 8AM-5PM, Sat: 9AM-1PM",
                    image: "stethoscope",
                    specialties: ["Family Medicine", "Diabetes Care", "Hypertension", "Preventive Care"]
                ),
                Business(
                    name: "Desai Dental - Advanced Cosmetic Dentistry",
                    category: .doctors,
                    description: "State-of-the-art dental clinic offering general, cosmetic, and implant dentistry.",
                    address: "456 Dental Ave, San Antonio, TX",
                    phone: "(210) 555-0156",
                    email: "smile@desaidental.com",
                    website: "www.desaidental.com",
                    rating: 4.9,
                    reviews: 156,
                    hours: "Mon-Thu: 8AM-6PM, Fri: 8AM-4PM",
                    image: "stethoscope",
                    specialties: ["Cosmetic Dentistry", "Implants", "Orthodontics", "General Dentistry"]
                ),
                
                // Real Estate Agents
                Business(
                    name: "Kapoor Real Estate Group",
                    category: .realEstate,
                    description: "Award-winning real estate team specializing in residential and commercial properties.",
                    address: "789 Property Lane, Dallas, TX",
                    phone: "(214) 555-0123",
                    email: "agents@kapoor.realestate",
                    website: "www.kapoor.realestate",
                    rating: 4.8,
                    reviews: 189,
                    hours: "Mon-Sun: 9AM-8PM",
                    image: "house.fill",
                    specialties: ["Residential Sales", "Investment Properties", "Property Management"]
                ),
                Business(
                    name: "Gupta Homes - Your Dream House Awaits",
                    category: .realEstate,
                    description: "Helping families find their perfect homes with personalized service and market expertise.",
                    address: "321 Realtor Dr, Houston, TX",
                    phone: "(713) 555-0145",
                    email: "contact@guptahomes.com",
                    website: "www.guptahomes.com",
                    rating: 4.7,
                    reviews: 142,
                    hours: "Mon-Sat: 9AM-7PM, Sun: 10AM-6PM",
                    image: "house.fill",
                    specialties: ["First-Time Buyers", "Luxury Homes", "Neighborhood Guides"]
                ),
                
                // Restaurants
                Business(
                    name: "Tandoori Nights - Fine Indian Dining",
                    category: .restaurants,
                    description: "Authentic Indian cuisine with traditional tandoori specialties and contemporary fusion dishes.",
                    address: "654 Curry Lane, Dallas, TX",
                    phone: "(214) 555-0167",
                    email: "reservations@tandoorinights.com",
                    website: "www.tandoorinights.com",
                    rating: 4.6,
                    reviews: 312,
                    hours: "Tue-Sun: 5PM-10PM, Mon: Closed",
                    image: "fork.knife",
                    specialties: ["Tandoori", "Curries", "Biryani", "Naan"]
                ),
                Business(
                    name: "Masala Magic - Casual Indian Eatery",
                    category: .restaurants,
                    description: "Quick and delicious Indian street food, dosas, and curries in a casual family setting.",
                    address: "987 Food Court, Austin, TX",
                    phone: "(512) 555-0189",
                    email: "order@masalamagic.com",
                    website: "www.masalamagic.com",
                    rating: 4.5,
                    reviews: 278,
                    hours: "Mon-Sun: 11AM-9PM",
                    image: "fork.knife",
                    specialties: ["Dosas", "Curries", "Street Food", "Vegetarian Options"]
                ),
                
                // Groceries & Indian Stores
                Business(
                    name: "Saffron Spice - Indian Grocery Store",
                    category: .groceries,
                    description: "One-stop shop for authentic Indian groceries, spices, fresh produce, and ready-to-cook items.",
                    address: "111 Spice Bazaar, Houston, TX",
                    phone: "(713) 555-0134",
                    email: "shop@saffronspice.com",
                    website: "www.saffronspice.com",
                    rating: 4.7,
                    reviews: 198,
                    hours: "Mon-Sun: 9AM-8PM",
                    image: "cart.fill",
                    specialties: ["Spices", "Ghee", "Fresh Produce", "Ready Meals"]
                ),
                Business(
                    name: "Mumbai Mart - Authentic Indian Products",
                    category: .groceries,
                    description: "Premium selection of Indian groceries, household items, and exclusive import brands.",
                    address: "222 Market St, San Antonio, TX",
                    phone: "(210) 555-0112",
                    email: "shopping@mumbaimart.com",
                    website: "www.mumbaimart.com",
                    rating: 4.6,
                    reviews: 165,
                    hours: "Tue-Sun: 10AM-7PM, Mon: Closed",
                    image: "cart.fill",
                    specialties: ["Groceries", "Spices", "Imported Foods", "Household Items"]
                ),
                
                // Beauty & Spa Services
                Business(
                    name: "Lotus Spa & Wellness Center",
                    category: .beauty,
                    description: "Full-service spa offering massages, facials, beauty treatments, and wellness therapies.",
                    address: "333 Wellness Way, Dallas, TX",
                    phone: "(214) 555-0178",
                    email: "book@lotusspa.com",
                    website: "www.lotusspa.com",
                    rating: 4.8,
                    reviews: 223,
                    hours: "Mon-Sun: 10AM-8PM",
                    image: "sparkles",
                    specialties: ["Ayurvedic Massage", "Facials", "Hair Treatment", "Aromatherapy"]
                ),
                Business(
                    name: "Priya's Beauty Studio",
                    category: .beauty,
                    description: "Expert bridal makeup, threading, waxing, and skincare treatments by experienced beauticians.",
                    address: "444 Beauty Blvd, Austin, TX",
                    phone: "(512) 555-0156",
                    email: "appointments@priyasbeauty.com",
                    website: "www.priyasbeauty.com",
                    rating: 4.9,
                    reviews: 156,
                    hours: "Tue-Sun: 10AM-7PM, Mon: By Appointment",
                    image: "sparkles",
                    specialties: ["Bridal Makeup", "Threading", "Facials", "Henna"]
                ),
                
                // Lawyers & Legal Services
                Business(
                    name: "Kumar & Associates Law Firm",
                    category: .lawyers,
                    description: "Specialized in immigration, business, and family law with multilingual legal team.",
                    address: "555 Legal Lane, Houston, TX",
                    phone: "(713) 555-0167",
                    email: "legal@kumarlaw.com",
                    website: "www.kumarlaw.com",
                    rating: 4.7,
                    reviews: 112,
                    hours: "Mon-Fri: 9AM-6PM",
                    image: "scale.3d",
                    specialties: ["Immigration", "H1B Visa", "Business Law", "Family Law"]
                ),
                Business(
                    name: "Desai Legal Consultants",
                    category: .lawyers,
                    description: "Expert legal advice on real estate, contracts, and business transactions.",
                    address: "666 Attorney Ave, Dallas, TX",
                    phone: "(214) 555-0145",
                    email: "consult@desailegal.com",
                    website: "www.desailegal.com",
                    rating: 4.6,
                    reviews: 98,
                    hours: "Mon-Fri: 10AM-5PM, Sat: 10AM-2PM",
                    image: "scale.3d",
                    specialties: ["Real Estate Law", "Contracts", "Business Formation"]
                ),
                
                // Insurance Services
                Business(
                    name: "Sharma Insurance Solutions",
                    category: .insurance,
                    description: "Comprehensive insurance coverage including health, auto, home, and life insurance.",
                    address: "777 Insurance Plaza, Austin, TX",
                    phone: "(512) 555-0134",
                    email: "quotes@sharmainsurance.com",
                    website: "www.sharmainsurance.com",
                    rating: 4.8,
                    reviews: 134,
                    hours: "Mon-Fri: 9AM-6PM, Sat: 10AM-3PM",
                    image: "shield.fill",
                    specialties: ["Health Insurance", "Auto Insurance", "Home Insurance", "Life Insurance"]
                ),
                Business(
                    name: "Bhagwat Insurance Agents",
                    category: .insurance,
                    description: "Personalized insurance planning for families and small businesses.",
                    address: "888 Coverage St, San Antonio, TX",
                    phone: "(210) 555-0123",
                    email: "agent@bhagwatinsurance.com",
                    website: "www.bhagwatinsurance.com",
                    rating: 4.7,
                    reviews: 89,
                    hours: "Mon-Sat: 10AM-6PM",
                    image: "shield.fill",
                    specialties: ["Policy Review", "Coverage Planning", "Claims Assistance"]
                ),
                
                // Travel Agencies
                Business(
                    name: "Voyages India Travel Services",
                    category: .travel,
                    description: "Expertise in planning trips to India and worldwide travel packages with visa assistance.",
                    address: "999 Journey Lane, Dallas, TX",
                    phone: "(214) 555-0156",
                    email: "travel@voyagesindia.com",
                    website: "www.voyagesindia.com",
                    rating: 4.8,
                    reviews: 167,
                    hours: "Mon-Fri: 9AM-6PM, Sat: 10AM-4PM",
                    image: "airplane",
                    specialties: ["India Trips", "Visa Assistance", "Group Tours", "Hotel Bookings"]
                ),
                Business(
                    name: "Taj Travel - Your Journey Specialist",
                    category: .travel,
                    description: "Customized travel itineraries, visa services, and group tour packages.",
                    address: "1010 Passport Rd, Houston, TX",
                    phone: "(713) 555-0178",
                    email: "book@tajtravel.com",
                    website: "www.tajtravel.com",
                    rating: 4.7,
                    reviews: 143,
                    hours: "Mon-Sun: 10AM-7PM",
                    image: "airplane",
                    specialties: ["Honeymoon Packages", "Family Tours", "Visa Processing"]
                ),
                
                // Wedding Planning
                Business(
                    name: "Celebration Weddings by Sharma",
                    category: .wedding,
                    description: "Full-service wedding planning for traditional and modern Indian weddings.",
                    address: "1111 Bride Ln, Austin, TX",
                    phone: "(512) 555-0189",
                    email: "plan@celebrationweddings.com",
                    website: "www.celebrationweddings.com",
                    rating: 4.9,
                    reviews: 201,
                    hours: "By Appointment",
                    image: "heart.fill",
                    specialties: ["Sangeet", "Mehandi", "Wedding Reception", "Coordination"]
                ),
                Business(
                    name: "Dreams & Destiny - Wedding Planners",
                    category: .wedding,
                    description: "Creative wedding designs and execution for Indian and fusion weddings.",
                    address: "1212 Ceremony Dr, San Antonio, TX",
                    phone: "(210) 555-0167",
                    email: "hello@dreamsanddestiny.com",
                    website: "www.dreamsanddestiny.com",
                    rating: 4.8,
                    reviews: 178,
                    hours: "By Appointment",
                    image: "heart.fill",
                    specialties: ["Decor Design", "Catering Coordination", "Venue Selection"]
                ),
                
                // Photography
                Business(
                    name: "Kiran Photography - Capturing Moments",
                    category: .photography,
                    description: "Professional wedding, portrait, and event photography with creative storytelling.",
                    address: "1313 Picture Pl, Dallas, TX",
                    phone: "(214) 555-0123",
                    email: "book@kiranphoto.com",
                    website: "www.kiranphoto.com",
                    rating: 4.9,
                    reviews: 245,
                    hours: "By Appointment",
                    image: "camera.fill",
                    specialties: ["Wedding Photography", "Portraits", "Events", "Videography"]
                ),
                Business(
                    name: "Lens & Light Photography Studio",
                    category: .photography,
                    description: "Artistic photography services for weddings, engagements, and family portraits.",
                    address: "1414 Shot St, Houston, TX",
                    phone: "(713) 555-0134",
                    email: "contact@lensandlight.com",
                    website: "www.lensandlight.com",
                    rating: 4.8,
                    reviews: 156,
                    hours: "By Appointment",
                    image: "camera.fill",
                    specialties: ["Candid Photography", "Pre-Wedding Shoots", "Album Design"]
                ),
                
                // Tutoring & Education
                Business(
                    name: "Excel Academy - Test Prep & Tutoring",
                    category: .tutoring,
                    description: "SAT, ACT, GRE preparation and personalized tutoring in math, sciences, and English.",
                    address: "1515 Education Blvd, Austin, TX",
                    phone: "(512) 555-0145",
                    email: "enroll@excelacademy.com",
                    website: "www.excelacademy.com",
                    rating: 4.7,
                    reviews: 189,
                    hours: "Mon-Sat: 3PM-8PM",
                    image: "book.fill",
                    specialties: ["SAT Prep", "Math Tutoring", "Science Tutoring", "College Counseling"]
                ),
                Business(
                    name: "Bright Minds Learning Center",
                    category: .tutoring,
                    description: "Group and individual tutoring for K-12 students with focus on STEM and language arts.",
                    address: "1616 Knowledge Ln, San Antonio, TX",
                    phone: "(210) 555-0156",
                    email: "learn@brightminds.edu",
                    website: "www.brightminds.edu",
                    rating: 4.6,
                    reviews: 134,
                    hours: "Mon-Fri: 3PM-7PM, Sat: 10AM-3PM",
                    image: "book.fill",
                    specialties: ["Math Tutoring", "English Tutoring", "Homework Help"]
                ),
                
                // Home Services
                Business(
                    name: "Sharma Home Maintenance Services",
                    category: .homeServices,
                    description: "General home repairs, maintenance, and renovations with skilled technicians.",
                    address: "1717 Repair Rd, Dallas, TX",
                    phone: "(214) 555-0178",
                    email: "service@sharmaservices.com",
                    website: "www.sharmaservices.com",
                    rating: 4.7,
                    reviews: 167,
                    hours: "Mon-Sat: 8AM-6PM",
                    image: "hammer.fill",
                    specialties: ["Drywall Repair", "Painting", "Carpentry", "General Repairs"]
                ),
                Business(
                    name: "Quick Fix Home Services",
                    category: .homeServices,
                    description: "Fast and reliable home repair and maintenance services for busy families.",
                    address: "1818 Maintenance Ave, Houston, TX",
                    phone: "(713) 555-0189",
                    email: "schedule@quickfixhome.com",
                    website: "www.quickfixhome.com",
                    rating: 4.6,
                    reviews: 143,
                    hours: "Mon-Sun: 7AM-7PM",
                    image: "hammer.fill",
                    specialties: ["Quick Repairs", "Maintenance Plans", "Emergency Service"]
                ),
                
                // Plumbing
                Business(
                    name: "Patel Plumbing Solutions",
                    category: .plumbing,
                    description: "Professional plumbing services for residential and commercial properties.",
                    address: "1919 Pipe Ln, Austin, TX",
                    phone: "(512) 555-0167",
                    email: "service@patelplumbing.com",
                    website: "www.patelplumbing.com",
                    rating: 4.8,
                    reviews: 178,
                    hours: "Mon-Sun: 7AM-9PM",
                    image: "wrench.and.hammer.fill",
                    specialties: ["Leak Repair", "Water Heaters", "Drain Cleaning", "Installation"]
                ),
                Business(
                    name: "Trusted Plumber - 24/7 Service",
                    category: .plumbing,
                    description: "Emergency plumbing repairs and maintenance with guaranteed satisfaction.",
                    address: "2020 Water St, San Antonio, TX",
                    phone: "(210) 555-0134",
                    email: "emergency@trustedplumber.com",
                    website: "www.trustedplumber.com",
                    rating: 4.7,
                    reviews: 156,
                    hours: "Mon-Sun: 24/7",
                    image: "wrench.and.hammer.fill",
                    specialties: ["Emergency Service", "Pipe Repair", "Inspection"]
                ),
                
                // Electrical
                Business(
                    name: "Sharma Electric - Professional Electricians",
                    category: .electrical,
                    description: "Licensed electricians for residential, commercial, and emergency electrical work.",
                    address: "2121 Power Ave, Dallas, TX",
                    phone: "(214) 555-0145",
                    email: "electric@sharmaelectric.com",
                    website: "www.sharmaelectric.com",
                    rating: 4.8,
                    reviews: 189,
                    hours: "Mon-Sat: 8AM-6PM",
                    image: "bolt.fill",
                    specialties: ["Home Wiring", "Panel Installation", "Smart Home Setup"]
                ),
                Business(
                    name: "Premier Electric Services",
                    category: .electrical,
                    description: "Quality electrical services with expert technicians and fast response times.",
                    address: "2222 Circuit Dr, Houston, TX",
                    phone: "(713) 555-0156",
                    email: "service@premierelectric.com",
                    website: "www.premierelectric.com",
                    rating: 4.7,
                    reviews: 167,
                    hours: "Mon-Sun: 8AM-8PM",
                    image: "bolt.fill",
                    specialties: ["Troubleshooting", "Upgrades", "Safety Inspections"]
                ),
                
                // Dance School
                Business(
                    name: "Bharatanatyam Dance Academy",
                    category: .danceSchool,
                    description: "Classical Indian dance training in Bharatanatyam, Kathak, and contemporary styles.",
                    address: "2323 Dance Ln, Austin, TX",
                    phone: "(512) 555-0178",
                    email: "enroll@bharatdance.com",
                    website: "www.bharatdance.com",
                    rating: 4.9,
                    reviews: 134,
                    hours: "Mon-Fri: 4PM-8PM, Sat: 10AM-5PM",
                    image: "music.note",
                    specialties: ["Bharatanatyam", "Kathak", "Children's Classes", "Adult Classes"]
                ),
                Business(
                    name: "Fusion Rhythm Dance Studio",
                    category: .danceSchool,
                    description: "Indian classical and fusion dance classes for all ages and skill levels.",
                    address: "2424 Movement Ave, San Antonio, TX",
                    phone: "(210) 555-0189",
                    email: "classes@fusionrhythm.com",
                    website: "www.fusionrhythm.com",
                    rating: 4.7,
                    reviews: 112,
                    hours: "Mon-Sat: 3PM-8PM",
                    image: "music.note",
                    specialties: ["Bollywood", "Hip-Hop Fusion", "Performances", "Choreography"]
                ),
                
                // Jewellery
                Business(
                    name: "Asha Jewels - Fine Indian Jewelry",
                    category: .jewellery,
                    description: "Authentic gold and diamond jewelry with traditional and modern designs.",
                    address: "2525 Gem St, Dallas, TX",
                    phone: "(214) 555-0123",
                    email: "shop@ashajewels.com",
                    website: "www.ashajewels.com",
                    rating: 4.8,
                    reviews: 201,
                    hours: "Mon-Sat: 11AM-7PM, Sun: 12PM-5PM",
                    image: "diamond.fill",
                    specialties: ["Gold Jewelry", "Diamonds", "Custom Design", "Wedding Jewelry"]
                ),
                Business(
                    name: "Radiant Gold House",
                    category: .jewellery,
                    description: "Premium gold and silver jewelry with certification and buyback guarantees.",
                    address: "2626 Sparkle Pl, Houston, TX",
                    phone: "(713) 555-0145",
                    email: "contact@radiantgold.com",
                    website: "www.radiantgold.com",
                    rating: 4.7,
                    reviews: 178,
                    hours: "Mon-Sun: 10AM-8PM",
                    image: "diamond.fill",
                    specialties: ["Gold Investment", "Hallmarked Jewelry", "Repair Services"]
                ),
                
                // Movers
                Business(
                    name: "Sharma's Reliable Movers",
                    category: .movers,
                    description: "Professional moving and packing services with insured trucks and trained staff.",
                    address: "2727 Moving Ln, Austin, TX",
                    phone: "(512) 555-0167",
                    email: "quote@sharmasmovers.com",
                    website: "www.sharmasmovers.com",
                    rating: 4.8,
                    reviews: 189,
                    hours: "Mon-Sat: 7AM-7PM",
                    image: "truck.box.fill",
                    specialties: ["Long Distance", "Local Moves", "Packing Services", "Storage"]
                ),
                Business(
                    name: "Express Relocation Services",
                    category: .movers,
                    description: "Fast and efficient moving services with competitive rates and excellent customer care.",
                    address: "2828 Transport Ave, San Antonio, TX",
                    phone: "(210) 555-0156",
                    email: "book@expressrelocation.com",
                    website: "www.expressrelocation.com",
                    rating: 4.7,
                    reviews: 156,
                    hours: "Mon-Sun: 6AM-8PM",
                    image: "truck.box.fill",
                    specialties: ["Corporate Relocations", "International Moves", "Warehouse Storage"]
                )
            ]
        }
        
        struct BusinessCardView: View {
            let business: Business
            let cityColors: (primary: Color, secondary: Color, gradient1: Color, gradient2: Color)
            @State private var isExpanded = false
            
            var body: some View {
                VStack(spacing: 0) {
                    // Header with icon and name
                    HStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Image(systemName: business.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [
                                        cityColors.primary,
                                        cityColors.secondary
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(business.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text(String(format: "%.1f", business.rating))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                Text("(\(business.reviews))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() } }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(cityColors.primary)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    if isExpanded {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Description
                            Text(business.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Specialties
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Specialties")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                
                                FlowLayout(spacing: 6) {
                                    ForEach(business.specialties, id: \.self) { specialty in
                                        Text(specialty)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(cityColors.primary.opacity(0.7))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            
                            // Contact Info
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(cityColors.primary)
                                        .font(.system(size: 14))
                                    
                                    Text(business.address)
                                        .font(.caption)
                                        .lineLimit(2)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(cityColors.primary)
                                        .font(.system(size: 14))
                                    
                                    Text(business.phone)
                                        .font(.caption)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(cityColors.primary)
                                        .font(.system(size: 14))
                                    
                                    Text(business.email)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(cityColors.primary)
                                        .font(.system(size: 14))
                                    
                                    Text(business.hours)
                                        .font(.caption)
                                }
                            }
                            
                            // Action Buttons
                            HStack(spacing: 8) {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "phone.circle.fill")
                                        Text("Call")
                                    }
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(cityColors.primary)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "globe")
                                        Text("Website")
                                    }
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(cityColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(cityColors.primary.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        
        // MARK: - Helper View for Layouts
        struct FlowLayout: Layout {
            var spacing: CGFloat = 8
            
            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
                guard !subviews.isEmpty else { return .zero }
                
                var height: CGFloat = 0
                var currentLineWidth: CGFloat = 0
                var lineHeight: CGFloat = 0
                let availableWidth = proposal.width ?? 300
                
                for subview in subviews {
                    let size = subview.sizeThatFits(.unspecified)
                    
                    if currentLineWidth + spacing + size.width > availableWidth && currentLineWidth > 0 {
                        height += lineHeight + spacing
                        currentLineWidth = 0
                        lineHeight = 0
                    }
                    
                    currentLineWidth += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                }
                
                height += lineHeight
                return CGSize(width: availableWidth, height: height)
            }
            
            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
                guard !subviews.isEmpty else { return }
                
                var x: CGFloat = bounds.minX
                var y: CGFloat = bounds.minY
                var lineHeight: CGFloat = 0
                
                for subview in subviews {
                    let size = subview.sizeThatFits(.unspecified)
                    
                    if x + size.width > bounds.maxX && x > bounds.minX {
                        y += lineHeight + spacing
                        x = bounds.minX
                        lineHeight = 0
                    }
                    
                    subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                    x += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                }
            }
        }
        
        struct ProfileView: View {
            @EnvironmentObject var authManager: AuthenticationManager
            @EnvironmentObject var cityManager: CityManager
            @State private var selectedCity: City = .dallas
            @State private var showingEditProfile = false
            @State private var showingSettings = false
            @State private var showingLogout = false
            @State private var favoriteBusinesses: [String] = []
            @State private var favoriteEvents: [String] = []
            
            var body: some View {
                NavigationView {
                    ZStack {
                        cityManager.selectedCity.backgroundGradient
                            .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Profile Header
                                if let user = authManager.currentUser {
                                    VStack(spacing: 16) {
                                        // Avatar
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        cityManager.selectedCity.themeColors.primary,
                                                        cityManager.selectedCity.themeColors.secondary
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .frame(width: 100, height: 100)
                                            
                                            Text(String(user.name.prefix(1)).uppercased())
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        // User Info
                                        VStack(spacing: 8) {
                                            Text(user.name)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            
                                            Text(user.email)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            HStack(spacing: 4) {
                                                Text(user.city.emoji)
                                                Text(user.city.rawValue)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        // Edit Profile Button
                                        Button(action: { showingEditProfile = true }) {
                                            HStack {
                                                Image(systemName: "pencil")
                                                Text("Edit Profile")
                                            }
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        cityManager.selectedCity.themeColors.primary,
                                                        cityManager.selectedCity.themeColors.secondary
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(10)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                                
                                // Stats Section
                                HStack(spacing: 0) {
                                    VStack(spacing: 8) {
                                        Text("12")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                        Text("Events Attended")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    
                                    Divider()
                                    
                                    VStack(spacing: 8) {
                                        Text("8")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                        Text("Saved Businesses")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    
                                    Divider()
                                    
                                    VStack(spacing: 8) {
                                        Text("5")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                        Text("Active Listings")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                }
                                .cornerRadius(16)
                                .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                                .padding(.horizontal)
                                
                                // Preferences Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Preferences")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 0) {
                                        // City Preference
                                        HStack {
                                            Image(systemName: "location.fill")
                                                .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                                .frame(width: 24)
                                            
                                            Text("Preferred City")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                Text(cityManager.selectedCity.emoji)
                                                Text(cityManager.selectedCity.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                        
                                        // Notifications
                                        HStack {
                                            Image(systemName: "bell.fill")
                                                .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                                .frame(width: 24)
                                            
                                            Text("Notifications")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Toggle("", isOn: .constant(true))
                                        }
                                        .padding()
                                        .background(Color.white)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                        
                                        // Theme
                                        HStack {
                                            Image(systemName: "moon.stars.fill")
                                                .foregroundColor(cityManager.selectedCity.themeColors.primary)
                                                .frame(width: 24)
                                            
                                            Text("Dark Mode")
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Toggle("", isOn: .constant(false))
                                        }
                                        .padding()
                                        .background(Color.white)
                                    }
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // Help & Support Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Help & Support")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 0) {
                                        NavigationLink(destination: Text("FAQs Coming Soon")) {
                                            HStack {
                                                Image(systemName: "questionmark.circle.fill")
                                                    .foregroundColor(.orange)
                                                    .frame(width: 24)
                                                
                                                Text("FAQs")
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                        }
                                        .background(Color.white)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                        
                                        NavigationLink(destination: Text("Contact Us Coming Soon")) {
                                            HStack {
                                                Image(systemName: "envelope.fill")
                                                    .foregroundColor(.blue)
                                                    .frame(width: 24)
                                                
                                                Text("Contact Support")
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                        }
                                        .background(Color.white)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                        
                                        NavigationLink(destination: Text("About Coming Soon")) {
                                            HStack {
                                                Image(systemName: "info.circle.fill")
                                                    .foregroundColor(.green)
                                                    .frame(width: 24)
                                                
                                                Text("About TXIndia")
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                        }
                                        .background(Color.white)
                                    }
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                
                                // Logout Button
                                Button(action: {
                                    showingLogout = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square.fill")
                                        Text("Logout")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.3, blue: 0.3),
                                                Color(red: 0.8, green: 0.1, blue: 0.2)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                                .padding()
                                .alert("Logout", isPresented: $showingLogout) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Logout", role: .destructive) {
                                        authManager.logout()
                                    }
                                } message: {
                                    Text("Are you sure you want to logout?")
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        
        // MARK: - Helper Views
        struct SectionHeader: View {
            let title: String
            let actionTitle: String
            
            var body: some View {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(actionTitle) {}
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.2, blue: 0.6),   // Hot pink
                                Color(red: 0.4, green: 0.8, blue: 0.95)   // Cyan
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
            }
        }
        
        struct EnhancedQuickActionCard: View {
            let title: String
            let icon: String
            let color: Color
            let count: String
            
            var body: some View {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    }
                    
                    VStack(spacing: 4) {
                        Text(count)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                        
                        Text(title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        
        struct EnhancedEventCard: View {
            let event: Event
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    // Event Image Placeholder
                    AsyncImageView(
                        imageKey: event.imageKey,
                        placeholder: event.category.icon,
                        height: 120
                    )
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(event.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(event.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        if let price = event.price {
                            Text("$\(Int(price))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .frame(width: 220)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        
        struct EnhancedNewsCard: View {
            let index: Int
            
            private var newsItems: [(title: String, description: String, time: String, category: String)] {
                [
                    ("Diwali Festival Registration Opens", "Join the grand celebration at Dallas Convention Center with cultural programs and traditional food.", "2 hours ago", "Cultural"),
                    ("New Indian Grocery Store Opens in Austin", "Fresh vegetables, spices, and authentic Indian products now available on South Lamar Boulevard.", "5 hours ago", "Business"),
                    ("Tech Meetup for Indian Professionals", "Monthly networking event for IT professionals in the Indian community. Free snacks and drinks.", "1 day ago", "Professional")
                ]
            }
            
            var body: some View {
                let news = newsItems[index % newsItems.count]
                
                HStack(spacing: 12) {
                    // News Image Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.2),
                                    Color(red: 0.4, green: 0.8, blue: 0.95).opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "newspaper")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(news.category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(red: 1.0, green: 0.2, blue: 0.6).opacity(0.1))
                                .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Text(news.time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(news.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        Text(news.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
            }
        }
        
        // MARK: - Enhanced Event Row View
        struct EnhancedEventRowView: View {
            let event: Event
            
            var body: some View {
                HStack(spacing: 12) {
                    // Event Image
                    AsyncImageView(
                        imageKey: event.imageKey,
                        placeholder: event.category.icon,
                        width: 80,
                        height: 80
                    )
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(event.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let price = event.price {
                                Text("$\(Int(price))")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(event.location)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(event.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(event.category.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(event.category.color.opacity(0.2))
                                .foregroundColor(event.category.color)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
            }
        }
    
        

    

