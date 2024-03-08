//
//  RootView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

enum RootViewType {
    case launchView
    case authenticationView
    case mapView
}

struct RootView: View {
    @State var rootViewType: RootViewType = .launchView
    var body: some View {
        ZStack {
            switch rootViewType {
            case .launchView:
                LaunchView(rootViewType: $rootViewType)
            case .authenticationView:
                NavigationStack {
                    AuthenticationView(rootViewType: $rootViewType)
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
