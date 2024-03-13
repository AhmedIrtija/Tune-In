//
//  LoadingView.swift
//  TuneIn
//
//  Created by Ashani Sinha on 3/3/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    @Binding var rootViewType: RootViewType
    @StateObject var viewModel = SpotifyController()
    @EnvironmentObject var userModel: UserModel
    @State var openView = false
    @State private var progress: CGFloat = 0.0
    @State var track: Track? = nil

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(white: 0, opacity: 0.75).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                Text("Tuning you in...")
                    .foregroundColor(.white)
                    .font(.headline)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 20)
                            .foregroundColor(Color.gray.opacity(0.5))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: progress + 20, height: 20)
                            .foregroundColor(Color.green)
                            .animation(.linear(duration: 0.5), value: progress)
                        
                        HStack(spacing: 0) {
                            Image(uiImage: UIImage(imageLiteralResourceName: "AppIcon"))
                                .resizable()
                                .frame(width: 20, height: 20)
                                .offset(x: progress)
                                .animation(.linear(duration: 0.5), value: progress)
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(height: 20)
                    .cornerRadius(10)
                    .padding()
                    .onReceive(timer) { _ in
                        let stepSize = geometry.size.width / 6
                        if progress + stepSize < geometry.size.width {
                            progress += stepSize
                        } else {
                            progress = geometry.size.width - 20
                            rootViewType = .mapView
                            timer.upstream.connect().cancel()
                        }
                    }
                }
                .frame(height: 20)
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            if let URLRequestForCurrentTrack = viewModel.createURLRequest() {
                if let insideURL = URLRequestForCurrentTrack.url {
                    viewModel.open(url: insideURL)
                    Task {
                            do {
                                if let fetchedTrack = try await viewModel.fetchCurrentPlayingTrack() {
                                    track = fetchedTrack
                                    try await userModel.setCurrentTrack(track: fetchedTrack)
                                } 
                            } catch {
                                print("Failed to fetch current track: \(error)")
                            }
                        }

                }
            }
        }
    }
}

