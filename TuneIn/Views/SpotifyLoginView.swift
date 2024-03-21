//
//  LoginView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

struct SpotifyLoginView: View {
    @Binding var rootViewType: RootViewType
    @StateObject var viewModel = SpotifyController()
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(uiImage: UIImage(imageLiteralResourceName: "AppIcon"))
                .resizable()
                .frame(width: 195, height: 195)
                .padding(.bottom)
            Text("It's time to Tune In")
                .font(Font.custom("Damion", size: 50))
                .foregroundColor(.white)
            button
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onOpenURL { url in
            viewModel.open(url: url)
        }
        .onChange(of: viewModel.state) {
            let newState = viewModel.state
            switch newState {
            case .success:
                withAnimation {
                    rootViewType = .loadingView
                }
            default:
                break
            }
        }
        .preferredColorScheme(.dark)
        .transition(.push(from: .bottom))
    }
}

private extension SpotifyLoginView {
    var button: some View {
        Button {
            rootViewType = .mapView
        } label: {
            Text("CONNECT USING SPOTIFY")
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




#Preview {
    SpotifyLoginView(rootViewType: .constant(.signInView))
}
