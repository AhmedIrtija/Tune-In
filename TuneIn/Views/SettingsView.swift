//
//  SettingsView.swift
//  TuneIn
//
//  Created by Nivrithi Krishnan on 3/5/24.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var userModel: UserModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var rootViewType: RootViewType
    @State private var newDisplayName: String = ""
    @State private var newPronouns = Pronouns.na
    @State private var newBio: String = ""
    @State private var newPassword: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack() {
            Color.black
                .ignoresSafeArea()
            VStack() {
                Spacer()
                
                // Title
                Text("Settings")
                    .font(Font.custom("Damion", size: 50))
                    .padding([.bottom], 10)
                    .foregroundColor(.white)
                
                // Profile Photo with Edit Button
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    ZStack {
                        // Profile Photo
                        AsyncImage(url: URL(string: userModel.currentUser?.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120.0, height: 120.0)
                                .clipShape(.circle)
                                .padding(12.0)
                        } placeholder: {
                            Image("DefaultImage")
                                .resizable()
                                .frame(width: 120.0, height: 120.0)
                                .clipShape(.circle)
                                .padding(12.0)
                        }
                        
                        // Edit Icon Overlay
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.gray)
                            .background(Circle().fill(Color.black))
                            .offset(x: 45, y: 45)
                    }
                }
                
                Form {
                    // Display Name
                    Section(header: Text("Display Name")) {
                        TextField(userModel.currentUser?.name ?? "", text: $newDisplayName)
                            .foregroundColor(Color.gray)
                            .focused($isTextFieldFocused)
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
                            .focused($isTextFieldFocused)
                            .menuStyle(BorderlessButtonMenuStyle())
                        }
                    }
                    .textCase(nil)
                    
                    // Bio
                    Section(header: Text("Bio")) {
                        TextField(userModel.currentUser?.bio ?? "", text: $newBio)
                            .foregroundColor(Color.gray)
                            .focused($isTextFieldFocused)
                            .foregroundColor(Color.white)
                    }
                    .textCase(nil)
                }
                .preferredColorScheme(.dark)
                .scrollDisabled(true)
                
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
                .offset(y: -30)
                
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
                
                Spacer()
            }
            .font(.custom("Helvetica", size: 16))
            .padding([.horizontal], 24)
            .foregroundColor(Color.gray)
            .onChange(of: selectedItem) {
                guard let userId = userModel.currentUser?.userId else { return }
                if let selectedItem {
                    Task {
                        let url = try await viewModel.saveProfileImage(item: selectedItem, userId: userId)
                        try await UserManager.shared.updateImage(userId: userId, newImageUrl: url.absoluteString)
                        try await userModel.setUserImageUrl(imageUrl: url.absoluteString)
                    }
                }
            }
        }
        .onAppear {
            guard let userPronouns = userModel.currentUser?.pronouns else {
                return
            }
            newPronouns = userPronouns
        }
        .onTapGesture { isTextFieldFocused = false }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    SettingsView(rootViewType: .constant(.mapView))
}
