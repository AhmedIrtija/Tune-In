//
//  ContentView.swift
//  Test
//
//  Created by Ahmed Irtija on 2/26/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var spotifyController: SpotifyController
    @State private var isAuthenticated: Bool = false

    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                Image("SpotifyIcon")
                    .resizable()
                    .frame(width: 195, height: 195)
                    .padding(.bottom)
                
                
                Button(action: {
                    spotifyController.initialize()
                       }) {
                    Text("Log In")
                               .fontWeight(.bold)
                               .foregroundColor(.white)
                               .frame(minWidth: 0, maxWidth: .infinity)
                               .padding()
                               .background(Color.green)
                               .cornerRadius(40)
                               .padding(.horizontal, 20)
                }
                .shadow(radius: 10)
                
                
                if !spotifyController.isAuthenticationFailed {
                    Button(action: {
                        spotifyController.authenticate()
                        if(!spotifyController.isAuthenticationFailed){
                            isAuthenticated = true
                        }
                    }) {
                        Text("Authenticate Again")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(40)
                            .padding(.horizontal, 20)
                    }
                    .shadow(radius: 10)
                }
                Spacer()
            }
            .onAppear(){
                if(!spotifyController.isAuthenticationFailed){
                    isAuthenticated = true
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isAuthenticated){
                RootView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct Config {
    private static var configDict: [String: Any]? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Config.plist file not found")
        }
        return dict
    }

    static func value(forKey key: String) -> String? {
        return configDict?[key] as? String
    }
}


#Preview {
    LoginView(spotifyController: SpotifyController())
}
