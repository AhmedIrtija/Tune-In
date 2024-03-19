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
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var rootViewType: RootViewType
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
                AsyncImage(url: URL(string: userModel.currentUser?.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 135.0, height: 135.0)
                        .clipShape(.circle)
                        .padding(12.0)
                } placeholder: {
                    Image("DefaultImage")
                        .resizable()
                        .frame(width: 135.0, height: 135.0)
                        .clipShape(.circle)
                        .padding(12.0)
                }
                //Edit Image Button
                Button(
                    action: {
                        
                    }, label: {
                        Text("Edit Image")
                            .foregroundColor(Color.gray)
                    }
                )
                .frame(width: 125, height: 32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 15,
                        style: .circular
                    )
                    .stroke(Color.gray, lineWidth: 2)
                )
                .padding([.top],15)
                Form {
                    // Display Name
                    Section(header: Text("Display Name")) {
                        TextField(userModel.currentUser?.name ?? "", text: $newDisplayName)
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                self.newDisplayName = ""
                            }
                            .foregroundColor(Color.white)
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
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                self.newDisplayName = ""
                            }
                            .foregroundColor(Color.white)
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
                                dismiss()
                            }
                            if newPronouns != .na {
                                try await userModel.setPronouns(pronouns: newPronouns)
                                dismiss()
                            }
                            if !newBio.isEmpty {
                                try await userModel.setBio(bio: newBio)
                                dismiss()
                            }
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
                            .stroke(Color.gray, lineWidth: 2)
                        )
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
                                .stroke(Color.gray, lineWidth: 2)
                            )
                    }
                }
                .padding([.bottom], 20)
                
                // Logout Button
                Button(action: {
                    Task {
                        do {
                            try await userModel.deleteAuthenticationTokenFromStorage()
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
                            .fill(Color.gray)
                        )
                }
                .foregroundColor(Color.black)
                .padding([.top], 15)
            }
            .font(.custom("Helvetica", size: 16))
            .padding([.horizontal], 24)
            .foregroundColor(Color.gray)
        }
    }
}

#Preview {
    SettingsView(rootViewType: .constant(.mapView))
}
