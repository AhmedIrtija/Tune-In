//
//  SettingsView.swift
//  TuneIn
//
//  Created by Nivrithi Krishnan on 3/5/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var rootViewType: RootViewType
    @ObservedObject var userModel = UserModel()
    @FocusState var isFocused
    @State private var temp: String = ""
    @State private var temp2: String = ""
    
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