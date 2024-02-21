//
//  ProfileView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

struct ProfileView: View {
    @Binding var rootViewType: RootViewType
    var body: some View {
        Text("Profile View")
    }
}

#Preview {
    ProfileView(rootViewType: .constant(.mapView))
}
