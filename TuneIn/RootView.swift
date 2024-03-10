//
//  RootView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

enum RootViewType {
    case mapView
    case loginView
}

struct RootView: View {
    @State var rootViewType: RootViewType = .loginView
    var body: some View {
        switch rootViewType {
        case .mapView:
            NavigationStack {
                MapView(rootViewType: $rootViewType)
            }
            .navigationBarBackButtonHidden(true)
        case .loginView:
            NavigationStack {
                LoginView()
            }
        }
    }
}

#Preview {
    RootView()
}
