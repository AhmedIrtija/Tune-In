//
//  SettingsView.swift
//  TuneIn
//
//  Created by Nivrithi Krishnan on 3/5/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    @EnvironmentObject var userModel: UserModel
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var rootViewType: RootViewType
    @State private var showProfileView: Bool = false
    @State private var newDisplayName: String = ""
    @State private var newPronouns = Pronouns.na
    @State private var newBio: String = ""
    @State private var newPassword: String = ""
    
    var body: some View {
        ZStack() {
            Color.black
                .ignoresSafeArea()
            VStack() {
                //Title
                Text("Settings")
                    .font(Font.custom("Damion", size: 50))
                    .padding([.top], 50)
                    .padding([.bottom], 10)
                    .foregroundColor(.white)
                //Profile Photo
                Image("DefaultImage")
                    .resizable()
                    .frame(width: 135.0, height: 135.0)
                //Edit Image Button
                Button(
                    action: {
                        
                    }, label: {
                        Text("Edit Image")
                            .foregroundColor(Colors.gray)
                    }
                )
                .frame(width: 125, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .circular
                    )
                    .stroke(Colors.gray, lineWidth: 2)
                )
                .padding([.top],15)
                Form {
                    // Display Name
                    Section(header: Text("Display Name")) {
                        TextField(userModel.currentUser?.name ?? "", text: $newDisplayName)
                            .foregroundColor(Colors.gray)
                            .onTapGesture {
                                self.newDisplayName = ""
                            }
                            .foregroundColor(Colors.white)
                    }
                    .textCase(nil)
                    
                    // Pronouns
                    Section(header: Text("Pronouns")) {
                        HStack {
                            Text(newPronouns.rawValue)
                                .foregroundColor(.gray)
                            Spacer()
                            Menu {
                                ForEach(Pronouns.allCases, id: \.self) { pronoun in
                                    Button(action: {
                                        self.newPronouns = pronoun
                                    }) {
                                        Text(pronoun.rawValue)
                                    }
                                }
                            } label: {
                                Label("", systemImage: "chevron.down")
                                    .foregroundColor(.primary)
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                        }
                    }
                    .textCase(nil)
                    
                    // Bio
                    Section(header: Text("Bio")) {
                        TextField(userModel.currentUser?.bio ?? "", text: $newBio)
                            .foregroundColor(Colors.gray)
                            .onTapGesture {
                                self.newDisplayName = ""
                            }
                            .foregroundColor(Colors.white)
                    }
                    .textCase(nil)

                }
                .padding([.top],30)
                .preferredColorScheme(.dark)
                
                // Save Changes Button
                Button(action: {
                    Task {
                        do {
                            if !newDisplayName.isEmpty {
                                try await userModel.setUserName(name: newDisplayName)
                            }
                            if newPronouns != .na {
                                try await userModel.setPronouns(pronouns: newPronouns)
                            }
                            if !newBio.isEmpty {
                                try await userModel.setBio(bio: newBio)
                            }
                            showProfileView = true
                        } catch {
                            print("Error updating profile: \(error)")
                        }
                    }
                }) {
                    Spacer()
                    Text("Save Changes")
                        .frame(width: 135, height: 32)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .circular
                            )
                            .stroke(Colors.gray, lineWidth: 2)
                        )
                }
                .navigationDestination(isPresented: $showProfileView) {
                    ProfileView(rootViewType: $rootViewType)
                }
                
                Form {
                    Section(header: Text("Update Password")) {
                        SecureField("New password", text: $newPassword)
                            .cornerRadius(10.0)
                    }
                    .textCase(nil)
                }
                .padding([.top], 20)
                
                HStack{
                    Spacer()
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.updatePassword(password: newPassword)
                                print("Password updated")
                            }
                        }
                    }) {
                        Text("Update password")
                            .frame(width: 160, height: 32)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .circular
                                )
                                .stroke(Colors.gray, lineWidth: 2)
                            )
                    }
                }
                .padding([.bottom], 20)
                
                // Logout Button
                Button(action: {
                    Task {
                        do {
                            try viewModel.signOut()
                            rootViewType = .launchView
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    Text("Log out")
                        .frame(width: 100, height: 32)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .circular
                            )
                            .fill(Colors.gray)
                        )
                }
                .foregroundColor(Colors.black)
                .padding([.top], 15)
            }
            .font(.custom("Helvetica", size: 16))
            .padding([.horizontal], 24)
            .foregroundColor(Colors.gray)
        }
    }
}

#Preview {
    SettingsView(rootViewType: .constant(.mapView))
}
