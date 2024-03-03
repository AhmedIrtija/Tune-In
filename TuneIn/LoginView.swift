//
//  LoginView.swift
//  Test
//
//  Created by Ahmed Irtija on 2/26/24.
//

import SwiftUI
import WebKit

struct LoginView: View {
    @ObservedObject var spotifyController: SpotifyController
    @State private var isAuthenticated: Bool = false

    var body: some View {
        NavigationStack {
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack{
                    Spacer()
                    
                    Image("SpotifyIcon")
                        .resizable()
                        .frame(width: 195, height: 195)
                        .padding(.bottom)
                                        
                    Text("it's time to")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .shadow(color: .green, radius: 10, x: 0, y: 0)
                                                            
                    // Apply the gradient to the text
                    Text("Tune In")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .shadow(color: .green, radius: 10, x: 0, y: 0)
                        
                    
                    
                    if spotifyController.isAuthenticationFailed {
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
//                        print(spotifyController.getAccessTokenURL() ?? "")
//                        print(spotifyController.createURLRequest() ?? "")
//                        print(getAccessTokenFromWebView())
                    }
                }
                .navigationBarHidden(true)
                .navigationDestination(isPresented: $isAuthenticated){
                    RootView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    
//    func getAccessTokenFromWebView() {
//        guard let urlRequest = SpotifyController.shared.getAccessTokenURL() else { return }
//        let webview = WKWebView()
//        
//        webview.load(urlRequest)
//        webview.navigationDelegate = self
//        view = webview
//    }
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
