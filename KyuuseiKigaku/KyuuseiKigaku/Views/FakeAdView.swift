import SwiftUI

struct FakeAdView: View {
    let category: String
    let message: String

    @State private var countdown = 2
    @State private var navigateToResult = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)

            Text(I18n.t("ad_title"))
                .font(.title2)
                .fontWeight(.bold)

            Text(I18n.t("ad_message"))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("\(countdown)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.blue)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startCountdown()
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(category: category, message: message)
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                navigateToResult = true
            }
        }
    }
}
