import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = SpotifyController()

    var body: some View {
        VStack(spacing: 16) {
            Image("SpotifyIcon")
                .resizable()
                .frame(width: 195, height: 195)
                .padding(.bottom)
            Text("It's time to Tune In")
            button
        }
        .padding()
        .onOpenURL { url in
            viewModel.open(url: url)
        }
        .alert(
            viewModel.alertTitle,
            isPresented: Binding(
                get: {
                    viewModel.isAlertPresented
                }, set: { _ in
                    viewModel.setStateIdle()
                }
            )
        ) {
            Button(viewModel.alertButtonTitle, role: .cancel) { }
        }
    }
}

private extension LoginView {
    var button: some View {
        Button {
            viewModel.startAuthorizationCodeProcess()
        } label: {
            Text("CONNECT")
                .font(.system(.body, weight: .heavy))
                .kerning(2.0)
                .padding(
                    EdgeInsets(
                        top: 11.75,
                        leading: 32.0,
                        bottom: 11.75,
                        trailing: 32.0
                    )
                )
                .foregroundColor(.white)
                .background(
                    Color(
                        red: 29.0 / 255.0,
                        green: 185.0 / 255.0,
                        blue: 84.0 / 255.0
                    )
                )
                .cornerRadius(20)
        }
        .contentShape(Rectangle())
    }
}

private extension SpotifyController {
    var isAlertPresented: Bool {
        switch state {
        case .idle:
            return false
        default:
            return true
        }
    }

    var alertTitle: String {
        switch state {
        case .idle:
            return ""

        case .failure(let errorMessage):
            return errorMessage

        case .success(let successMessage):
            return successMessage
        }
    }

    var alertButtonTitle: String {
        switch state {
        case .idle:
            return ""

        case .failure:
            return "Bummer"

        case .success:
            return "Nice"
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

