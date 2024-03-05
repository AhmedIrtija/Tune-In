//
//  SettingsView.swift
//  TuneIn
//
//  Created by Nivrithi Krishnan on 3/5/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var rootViewType: RootViewType
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SettingsView(rootViewType: .constant(.mapView))
}
