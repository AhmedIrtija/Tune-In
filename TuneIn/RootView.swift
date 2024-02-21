//
//  RootView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

enum RootViewType {
    case mapView
}

struct RootView: View {
    @State var rootViewType: RootViewType = .mapView
    var body: some View {
        switch rootViewType {
        case .mapView:
            NavigationStack {
                MapView(rootViewType: $rootViewType)
            }
        }
    }
}

#Preview {
    RootView()
}
