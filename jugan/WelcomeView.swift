import SwiftUI

struct WelcomeView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 100) // 타이틀을 아래로 내림
            
            VStack(spacing: 15) {
                Text("주간예정사항")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("일정 공유 및 개인 업무 관리를 시작해보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                // 카카오 로그인 버튼
                Button(action: {
                    handleSocialLogin(platform: "Kakao")
                }) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 18))
                        Text("카카오로 로그인")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 254/255, green: 229/255, blue: 0)) // 카카오 시그니처 옐로우
                    .cornerRadius(12)
                }
                
                // 구글 로그인 버튼
                Button(action: {
                    handleSocialLogin(platform: "Google")
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 18))
                        Text("구글로 로그인")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
                .frame(height: 100) // 버튼 위치를 위로 올리기 위해 하단 공간 추가
        }
    }
    
    // 소셜 로그인 처리 로직 (자동 로그인/회원가입 시뮬레이션)
    private func handleSocialLogin(platform: String) {
        // 실제 구현 시에는 여기서 소셜 SDK 호출 및 가입 여부 확인 로직이 들어갑니다.
        // 현재는 클릭 시 바로 메인 화면으로 진입하도록 처리합니다.
        withAnimation {
            isLoggedIn = true
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isLoggedIn: .constant(false))
    }
}
