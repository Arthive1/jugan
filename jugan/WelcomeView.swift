import SwiftUI

struct WelcomeView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
                .frame(height: 50)
            
            VStack(spacing: 15) {
                Text("주간예정사항")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("일정 공유 및 개인 업무 관리를 시작해보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        isLoggedIn = true
                    }
                }) {
                    Text("로그인")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation {
                        isLoggedIn = true
                    }
                }) {
                    Text("회원가입")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isLoggedIn: .constant(false))
    }
}
