import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAuthenticated = true
            self.currentUser = User(
                id: UUID().uuidString,
                name: "Test User",
                email: email,
                city: .dallas
            )
            self.isLoading = false
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func register(name: String, email: String, password: String, city: City) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAuthenticated = true
            self.currentUser = User(
                id: UUID().uuidString,
                name: name,
                email: email,
                city: city
            )
            self.isLoading = false
        }
    }
}
