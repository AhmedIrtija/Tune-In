//
//  LoadingView.swift
//  TuneIn
//
//  Created by Ashani Sinha on 3/3/24.
//

import Foundation
import SwiftUI

struct LoadingView : View {
    @Binding var rootViewType: RootViewType
    @StateObject var viewModel = SpotifyController()
    //var URLRequestForCurrentTrack: URLRequest? = viewModel.createURLRequest()
    @State var openView = false
    var body: some View {
        ZStack {
            Text("Loading...")
        }
        .onAppear {
            if let URLRequestForCurrentTrack = viewModel.createURLRequest() {
                if let insideURL = URLRequestForCurrentTrack.url {
                    //open here
                    viewModel.open(url:insideURL)
                }
            }
        }
        .overlay {
                ZStack {
                    Color(white: 0, opacity: 0.75)
                    ProgressView().tint(.white)
                }
        }
    }
}
