//
//  ProfileView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userModel: UserModel
    @Binding var rootViewType: RootViewType
    @State private var showSettingsView: Bool = false
    var body: some View {
        ZStack() {
            Color.black
                .ignoresSafeArea()
            VStack() {
                Text("Current User ID: \(userModel.currentUser?.userId ?? "No user")")
                    .foregroundColor(.white)
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
                if let displayName = userModel.currentUser?.name {
                    Text(displayName)
                        .font(Font.custom("Damion", size: 40))
                        .foregroundColor(.white)
                }
                //Pronouns
                if let pronouns = userModel.currentUser?.pronouns {
                    Text(pronouns.rawValue)
                        .font(.custom("Helvetica", size: 14))
                        .padding([.bottom], 5)
                }
                //Location
                Text("Davis, CA, USA")
                    .padding([.bottom], 20)
                //Bio
                if let bio = userModel.currentUser?.bio {
                    Text(bio)
                        .padding([.bottom], 20)
                }
                Spacer()
            }
            .font(.custom("Helvetica", size: 18))
            .padding([.horizontal], 20)
            .foregroundColor(Color.gray)
        }
    }
}

#Preview {
    ProfileView(rootViewType: .constant(.mapView))
}
