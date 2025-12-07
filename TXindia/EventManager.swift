import SwiftUI

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchEvents(for city: City) {
        isLoading = true
        
        // Simulate fetching events
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.events = [
                Event(
                    id: "1",
                    title: "Diwali Celebration",
                    description: "Annual Diwali festival celebration with food, music, and fireworks",
                    date: Date().addingTimeInterval(86400 * 7),
                    city: city,
                    category: .religious,
                    imageURL: "https://via.placeholder.com/300x200?text=Diwali",
                    imageKey: nil,
                    location: "Fair Park",
                    price: 15.0,
                    attendees: 150,
                    isFavorite: false
                ),
                Event(
                    id: "2",
                    title: "Tech Meetup",
                    description: "Monthly tech professionals meetup to discuss industry trends",
                    date: Date().addingTimeInterval(86400 * 14),
                    city: city,
                    category: .professional,
                    imageURL: "https://via.placeholder.com/300x200?text=Tech",
                    imageKey: nil,
                    location: "Tech Hub Downtown",
                    price: 0.0,
                    attendees: 75,
                    isFavorite: false
                )
            ]
            self.isLoading = false
        }
    }
    
    func createEvent(_ event: Event) throws {
        self.events.append(event)
    }
    
    func deleteEvent(_ id: String) throws {
        self.events.removeAll { $0.id == id }
    }
    
    func toggleFavorite(for eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].isFavorite.toggle()
        }
    }
    
    static let sampleEvents: [Event] = [
        Event(
            id: "1",
            title: "Diwali Celebration 2025",
            description: "Join us for a grand Diwali celebration with cultural programs, food, and festivities.",
            date: Date(),
            city: .dallas,
            category: .cultural,
            imageURL: nil,
            imageKey: nil,
            location: "Dallas Convention Center",
            price: 25.0
        ),
        Event(
            id: "2",
            title: "Tech Meetup for Indians",
            description: "Monthly networking event for IT professionals in the Indian community.",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            city: .austin,
            category: .professional,
            imageURL: nil,
            imageKey: nil,
            location: "Austin Tech Hub",
            price: nil
        )
    ]
}
