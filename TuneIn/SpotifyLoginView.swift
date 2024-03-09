//
//  LoginView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

struct SpotifyLoginView: View {
    @Binding var rootViewType: RootViewType
    
    var body: some View {
        VStack {
            Text("Spotify Login View")
            Button(action: {
                rootViewType = .mapView
            }) {
                Text("Proceed to Map View")
                    .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                    .foregroundColor(.white)
                    .padding(10.0)
                    .frame(height: 55.0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
        }
        .padding()
    }
}

#Preview {
    SpotifyLoginView(rootViewType: .constant(.signInView))
}
