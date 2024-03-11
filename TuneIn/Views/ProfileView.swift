//
//  ProfileView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

struct ProfileView: View {
    @Binding var rootViewType: RootViewType
    @State private var showSettingsView: Bool = false
    var authenticationManager = AuthenticationManager.shared
    @State private var currentUser: DBUser?
    var body: some View {
        ZStack() {
            Color.black
                .ignoresSafeArea()
            VStack() {
                HStack {
                    Spacer()
                    //Settings Icon
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image("SettingsIcon")
                            .padding(12.0)
                    }
                    .navigationDestination(isPresented: $showSettingsView) {
                        SettingsView(rootViewType: $rootViewType)
                    }
                }
                .padding([.bottom], 50)
                //Profile Photo
                Image("DefaultImage")
                    .resizable()
                    .frame(width: 135.0, height: 135.0)
                //Display Name
                if let displayName = currentUser?.name {
                    Text(displayName)
                        .font(Font.custom("Damion", size: 40))
                        .foregroundColor(.white)
                }
                //Pronouns
                if let pronouns = currentUser?.pronouns {
                    Text(pronouns.rawValue)
                        .font(.custom("Helvetica", size: 14))
                        .padding([.bottom], 5)
                }
                //Location
//                if let pronouns = currentUser?.pronouns {
//                    Text(pronouns.rawValue)
//                        .padding([.bottom], 20)
//                }
                //Bio
                if let bio = currentUser?.bio {
                    Text(bio)
                        .padding([.bottom], 20)
                }
                Spacer()
            }
            .font(.custom("Helvetica", size: 18))
            .padding([.horizontal], 20)
            .foregroundColor(Colors.gray)
            .onAppear {
                Task {
                    do {
                        let authData = try authenticationManager.getAuthenticatedUser()
                        let userManager = UserManager.shared
                        currentUser = try await userManager.getUser(userId: authData.uid)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(rootViewType: .constant(.mapView))
}
