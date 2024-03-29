//
//  RootView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

enum RootViewType {
    case launchView
    case signInView
    case spotifyLoginView
    case mapView
    case loadingView
}

struct RootView: View {
    @EnvironmentObject var userModel: UserModel
    @State var rootViewType: RootViewType = .launchView
    
    var body: some View {
        ZStack {
            switch rootViewType {
            case .launchView:
                LaunchView(rootViewType: $rootViewType)
            case .signInView:
                SignInView(rootViewType: $rootViewType)
            case .spotifyLoginView:
                SpotifyLoginView(rootViewType: $rootViewType)
            case .mapView:
                NavigationStack {
                    MapView(rootViewType: $rootViewType)
                }
            case .loadingView:
                NavigationStack {
                    LoadingView(rootViewType: $rootViewType)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
