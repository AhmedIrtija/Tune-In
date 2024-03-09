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
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}

struct SettingsView: View {
    @Binding var rootViewType: RootViewType
    @ObservedObject var userModel = UserModel()
    @FocusState var isFocused
    @State private var temp: String = ""
    @State private var temp2: String = ""
    @StateObject private var viewModel = SettingsViewModel()
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
                    //Display Name
                    Section(header: Text("Display Name")) {
                        TextField("TuneIn", text: $temp)
                            .onTapGesture{
                                isFocused = true
                            }
                            .foregroundColor(.white)
                            .focused($isFocused)
                    }
                    .textCase(nil)
                    //Pronouns
                    Section(header: Text("Pronouns")) {
                        TextField("--", text: $temp2)
                            .onTapGesture{
                                isFocused = true
                            }
                            .foregroundColor(.white)
                            .focused($isFocused)
                    }
                    .textCase(nil)
                    //Location
                    Section(header: Text("Location")) {
                        TextField("--", text: $temp2)
                            .onTapGesture{
                                isFocused = true
                            }
                            .foregroundColor(.white)
                            .focused($isFocused)
                    }
                    .textCase(nil)
                    //Bio
                    Section(header: Text("Bio")) {
                        TextField("--", text: $temp2)
                            .onTapGesture{
                                isFocused = true
                            }
                            .foregroundColor(.white)
                            .focused($isFocused)
                    }
                    .textCase(nil)
                }
                .padding([.top],30)
                .preferredColorScheme(.dark)
                
                // Reset Password Button
                Button(action: {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                           print("Password reset")
                            rootViewType = .authenticationView
                        }
                    }
                }) {
                    Text("Reset password")
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(height: 32.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(10.0)
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
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(height: 32.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(10.0)
                }
                
                // Logout Button
                Button(action: {
                    Task {
                        do {
                            try viewModel.signOut()
                            rootViewType = .authenticationView
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    Text("Log out")
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(height: 32.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(10.0)
                }
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
