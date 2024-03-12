//
//  LaunchView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 3/8/24.
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var userModel: UserModel
    @Binding var rootViewType: RootViewType
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Tune In")
                    .font(Font.custom("Damion", size: 80))
                    .foregroundColor(.white)
            }
            
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    rootViewType = authUser == nil ? .signInView : .mapView
                }
            }
            
//
        }
    }
}

#Preview {
    LaunchView(rootViewType: .constant(.launchView))
}