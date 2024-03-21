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
    var user: AppUser
    var isSheet: Bool
    @State private var showSettingsView: Bool = false
    @State private var displayedUserAddress: String = ""
    
    // use userModel for current user, user argument for others
    private var displayedUser: AppUser {
        // determine which data to display
        if !isSheet {
            return userModel.currentUser ?? user
        } else {
            return user
        }
    }
    
    var body: some View {
        ZStack() {
            // background color
            if isSheet {
                Color.backgroundGray.ignoresSafeArea()
            }
            else {
                Color.black.ignoresSafeArea()
            }

            VStack() {
                // don't display settings icon if sheet
                if user.userId == userModel.currentUser?.userId && !isSheet {
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
                }
                
                //Profile Photo
                if let _ = displayedUser.imageUrl {
                    AsyncImage(url: URL(string: displayedUser.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135.0, height: 135.0)
                            .clipShape(.circle)
                            .padding([.top], 50)
                    } placeholder: {
                        Image("DefaultImage")
                            .resizable()
                            .frame(width: 135.0, height: 135.0)
                            .clipShape(.circle)
                            .padding([.top], 50)
                    }
                } else {
                    Image("DefaultImage")
                        .resizable()
                        .frame(width: 135.0, height: 135.0)
                        .clipShape(.circle)
                        .padding([.top], 50)
                }
                //Display Name
                Text(displayedUser.name)
                    .font(Font.custom("Damion", size: 40))
                    .foregroundColor(.white)
                //Pronouns
                if let pronouns = displayedUser.pronouns {
                    Text(pronouns.rawValue)
                        .font(.custom("Helvetica", size: 14))
                        .padding([.bottom], 5)
                }
                //Location
                Text(displayedUserAddress)
                    .multilineTextAlignment(.center)
                    .padding([.bottom], 20)
                //Bio
                if let bio = user.bio {
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
            guard let location = displayedUser.location else { return }
            viewModel.setUserLocation(location: location)
            viewModel.getLocationAddress { address in
                displayedUserAddress = address ?? ""
            }
        }
        .onChange(of: user.location) {
            guard let location = displayedUser.location else { return }
            viewModel.setUserLocation(location: location)
            viewModel.getLocationAddress { address in
                displayedUserAddress = address ?? ""
            }
        }
    }
}

//#Preview {
//    ProfileView(rootViewType: .constant(.mapView))
//}
