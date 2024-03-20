//
//  ProfileView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileView: View {
    @EnvironmentObject var userModel: UserModel
    @StateObject private var viewModel = ProfileViewModel()
    
    @Binding var rootViewType: RootViewType
    @State private var showSettingsView: Bool = false
    @State private var userAddress: String = ""
    
    var body: some View {
        ZStack() {
            Color.black
                .ignoresSafeArea()
            VStack() {
//                Text("Current User ID: \(userModel.currentUser?.userId ?? "No user")")
//                    .foregroundColor(.white)
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
                if let _ = userModel.currentUser?.imageUrl {
                    AsyncImage(url: URL(string: userModel.currentUser?.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135.0, height: 135.0)
                            .clipShape(.circle)
                    } placeholder: {
                        Image("DefaultImage")
                            .resizable()
                            .frame(width: 135.0, height: 135.0)
                            .clipShape(.circle)
                    }
                } else {
                    Image("DefaultImage")
                        .resizable()
                        .frame(width: 135.0, height: 135.0)
                        .clipShape(.circle)
                }
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
                Text(userAddress)
                    .multilineTextAlignment(.center)
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
        .onAppear {
            guard let location = userModel.currentUser?.location else { return }
            viewModel.setUserLocation(location: location)
            viewModel.getLocationAddress { address in
                userAddress = address ?? ""
            }
        }
        .onChange(of: userModel.currentUser?.location) {
            guard let location = userModel.currentUser?.location else { return }
            viewModel.setUserLocation(location: location)
            viewModel.getLocationAddress { address in
                userAddress = address ?? ""
            }
        }
    }
}

#Preview {
    ProfileView(rootViewType: .constant(.mapView))
}
