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
                Text("TuneIn")
                    .font(Font.custom("Damion", size: 40))
                    .foregroundColor(.white)
                //Pronouns
                Text("(she/her)")
                    .font(.custom("Helvetica", size: 14))
                    .padding([.bottom], 5)
                //Location
                Text("Davis, CA, USA")
                    .padding([.bottom], 20)
                //Bio
                Text("Hey there! I am using TuneIn.")
                    .padding([.bottom], 20)
                Spacer()
            }
            .font(.custom("Helvetica", size: 18))
            .padding([.horizontal], 20)
            .foregroundColor(Colors.gray)
        }
    }
}

#Preview {
    ProfileView(rootViewType: .constant(.mapView))
}
