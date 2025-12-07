import SwiftUI

// MARK: - Chat Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: Date
    let isCurrentUser: Bool
}

// MARK: - Chat Manager
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(author: "Priya Sharma", content: "Hey everyone! Just joined the TXIndia community 🎉", timestamp: Date().addingTimeInterval(-3600), isCurrentUser: false),
        ChatMessage(author: "Arjun Patel", content: "Welcome! Great to see more people from the community here 👋", timestamp: Date().addingTimeInterval(-3300), isCurrentUser: false),
        ChatMessage(author: "Neha Kumar", content: "Has anyone attended the upcoming Diwali event?", timestamp: Date().addingTimeInterval(-1800), isCurrentUser: false)
    ]
    @Published var newMessageText: String = ""
    @Published var isLoading: Bool = false
    
    func sendMessage(userName: String = "You") {
        guard !newMessageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = ChatMessage(
            author: userName,
            content: newMessageText,
            timestamp: Date(),
            isCurrentUser: true
        )
        messages.append(userMessage)
        newMessageText = ""
    }
}

// MARK: - Chat Bubble View
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isCurrentUser ?
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.2, blue: 0.6),
                                Color(red: 0.4, green: 0.8, blue: 0.95)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.9, blue: 0.95),
                                Color(red: 0.95, green: 0.95, blue: 0.98)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(message.isCurrentUser ? .white : .black)
                    .cornerRadius(12)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
            }
            
            if !message.isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat Window View
struct ChatWindowView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var isExpanded: Bool
    @State private var userName: String = "Community Member"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Community Chat")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("\(chatManager.messages.count) members here")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.2, blue: 0.6),
                    Color(red: 0.4, green: 0.8, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chatManager.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: chatManager.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(chatManager.messages.last?.id)
                    }
                }
            }
            
            Divider()
            
            // Input
            HStack(spacing: 8) {
                TextField("Share your thoughts...", text: $chatManager.newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 36)
                
                Button(action: {
                    chatManager.sendMessage(userName: userName)
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.6))
                }
                .disabled(chatManager.newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Floating Chat Button
struct FloatingChatButton: View {
    @Binding var isExpanded: Bool
    @ObservedObject var chatManager: ChatManager
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                ChatWindowView(chatManager: chatManager, isExpanded: $isExpanded)
                    .frame(height: 500)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    if isExpanded {
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
    }
}

// MARK: - Preview
#if DEBUG
struct ChatWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                FloatingChatButton(
                    isExpanded: .constant(true),
                    chatManager: ChatManager()
                )
            }
        }
    }
}
#endif
