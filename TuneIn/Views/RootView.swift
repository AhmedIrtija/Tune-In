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
    case mapView
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
                NavigationStack {
                    SignInView(rootViewType: $rootViewType)
                }
            case .mapView:
                NavigationStack {
                    MapView(rootViewType: $rootViewType)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
