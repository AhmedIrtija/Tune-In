//
//  LaunchView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var userModel: UserModel
    @Binding var rootViewType: RootViewType
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Image("TuneIn_Splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .onAppear {
            Task {
                // load authentication token from local storage
                try await userModel.loadAuthenticationTokenFromStorage()
                // load user
                try await userModel.loadUser()
//                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        rootViewType = userModel.authToken == nil ? .signInView : .spotifyLoginView
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .transition(.blurReplace)
    }
}

#Preview {
    LaunchView(rootViewType: .constant(.launchView))
}
