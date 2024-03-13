//
//  ListView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

struct ListView: View {
    var usersAroundLocation: [AppUser]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("EXPLORE MUSIC")
                    .font(.custom("Avenir", size: 24.0).uppercaseSmallCaps().bold())
                    .foregroundStyle(Color.gray)
                    .padding()

                ScrollView {
                    VStack {
                        ForEach(usersAroundLocation.filter { $0.currentTrack != nil }, id: \.userId) { user in
                            if let track = user.currentTrack {
                                HStack {
                                    AsyncImage(url: URL(string: track.albumUrl)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Image(systemName: "music.note.list")
                                            .aspectRatio(contentMode: .fit)
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .padding(.trailing, 10)

                                    VStack(alignment: .leading) {
                                        Text(user.name ?? "Anonymous User")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color.white)
                                            .padding(.bottom, 2)
                                        Text("Track: \(track.name)")
                                            .font(.system(size: 12, weight: .light))
                                        Text("Artist: \(track.artist)")
                                            .font(.system(size: 12, weight: .light))
                                        Text("Album: \(track.album)")
                                            .font(.system(size: 12, weight: .light))
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray))
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("VIEW MAP")
                        .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                        .foregroundColor(.white)
                        .padding(10.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.green)
                        .cornerRadius(10.0)
                }
                .padding([.top, .horizontal], 12.0)
            }
        }
    }
}

//#Preview {
//    ListView(usersAroundLocation: <#[AppUser]#>)
//}
