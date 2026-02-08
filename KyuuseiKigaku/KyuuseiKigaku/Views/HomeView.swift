import SwiftUI

struct HomeView: View {
    @State private var showInput = false
    @State private var showHistory = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text(I18n.t("app_title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(I18n.t("app_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 20) {
                    Button(action: { showInput = true }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text(I18n.t("button_new_reading"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }

                    Button(action: { showHistory = true }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(I18n.t("button_view_history"))
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .navigationDestination(isPresented: $showInput) {
            InputView()
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
    }
}
