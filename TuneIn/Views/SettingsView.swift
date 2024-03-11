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
    @Binding var rootViewType: RootViewType
    @State private var showProfileView: Bool = false
    @ObservedObject var userModel = UserModel()
    @StateObject private var viewModel = SettingsViewModel()
    var authenticationManager = AuthenticationManager.shared
    @State private var currentUser: DBUser?
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
                        TextField(currentUser?.name ?? "", text: $newDisplayName)
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
                        TextField(currentUser?.bio ?? "", text: $newBio)
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
                            if let userId = currentUser?.userId {
                                if !newDisplayName.isEmpty {
                                    try await UserManager.shared.updateName(userId: userId, newName: newDisplayName)
                                }
                                if newPronouns != .na {
                                    try await UserManager.shared.updatePronouns(userId: userId, newPronouns: newPronouns)
                                }
                                if !newBio.isEmpty {
                                    try await UserManager.shared.updateBio(userId: userId, newBio: newBio)
                                }
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
                            .stroke(Colors.gray, lineWidth: 2)
                        )
                }
                .navigationDestination(isPresented: $showProfileView) {
                    ProfileView(rootViewType: $rootViewType)
                }
                
                HStack{

                }
                
                // Secure Field to enter new password
                SecureField("New password", text: $newPassword)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10.0)
                
                // Update Password Button
                Button(action: {
                    Task {
                        do {
                            try await viewModel.updatePassword(password: newPassword)
                           print("Password updated")
                        }
                    }
                }) {
                    Text("Update password")
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(height: 32.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .cornerRadius(10.0)
                }
                
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
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(height: 32.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .cornerRadius(10.0)
                }
            }
            .font(.custom("Helvetica", size: 16))
            .padding([.horizontal], 24)
            .foregroundColor(Colors.gray)
        }
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

#Preview {
    SettingsView(rootViewType: .constant(.mapView))
}
