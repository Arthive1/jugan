import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: "홍길동", text: "업무 준비 다 되셨나요?", isMe: false),
        ChatMessage(sender: "Me", text: "네, 지금 준비 중입니다!", isMe: true),
        ChatMessage(sender: "김철수", text: "저도 곧 들어갑니다.", isMe: false)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // 메시지 목록
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding()
                    }
                }
                
                Divider()
                
                // 메시지 입력창
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("메시지를 입력하세요...", text: $messageText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("Group Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        withAnimation {
            messages.append(ChatMessage(sender: "Me", text: messageText, isMe: true))
            messageText = ""
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isMe { Spacer() }
            
            if !message.isMe {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    Text(message.text)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .clipShape(ChatBubbleShape(isMe: false))
                }
            } else {
                Text(message.text)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(ChatBubbleShape(isMe: true))
            }
            
            if !message.isMe { Spacer() }
        }
    }
}

// 말풍선 모양 커스텀
struct ChatBubbleShape: Shape {
    var isMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, isMe ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 15, height: 15))
        return Path(path.cgPath)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let isMe: Bool
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
