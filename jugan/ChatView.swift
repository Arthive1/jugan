import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: "홍길동", text: "업무 준비 다 되셨나요?", isMe: false, profileImage: "person.crop.circle.fill"),
        ChatMessage(sender: "Me", text: "네, 지금 준비 중입니다!", isMe: true, profileImage: "person.circle.fill"),
        ChatMessage(sender: "김철수", text: "저도 곧 들어갑니다.", isMe: false, profileImage: "person.crop.circle.badge.plus")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                // 상단: 제목 직접 구현 (기본 네비게이션 타이틀 공백 제거)
                HStack {
                    Text("Group Chat")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                                
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
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        withAnimation {
            messages.append(ChatMessage(sender: "Me", text: messageText, isMe: true, profileImage: "person.circle.fill"))
            messageText = ""
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isMe {
                Spacer()
            } else {
                // 상대방 프로필 이미지
                Image(systemName: message.profileImage)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 4)
            }
            
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                if !message.isMe {
                    // 상대방 이름
                    Text(message.sender)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(.leading, 2)
                }
                
                // 말풍선
                Text(message.text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .foregroundColor(message.isMe ? .white : .primary)
                    .background(message.isMe ? Color.blue : Color(.systemGray6))
                    .clipShape(ChatBubbleShape(isMe: message.isMe))
            }
            
            if !message.isMe {
                Spacer()
            }
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
    let profileImage: String
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
