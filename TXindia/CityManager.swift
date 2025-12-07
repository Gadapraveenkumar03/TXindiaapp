import SwiftUI

class CityManager: ObservableObject {
    @Published var selectedCity: City = .dallas
    @Published var cities: [City] = City.allCases
    
    func selectCity(_ city: City) {
        self.selectedCity = city
    }
}
