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
                    .foregroundStyle(Color.white)
                    .padding(.top, 48.0)
                    .padding(.bottom, 12.0)

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
                                        Text(user.name )
                                            .font(.system(size: 16, weight: .heavy))
                                            .foregroundStyle(Color.white)
                                            .padding(.bottom, 2)
                                        Text("\(track.name)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color.textGray)
                                            .padding(.bottom, 1)
                                        Text("by \(track.artist)")
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundStyle(Color.textGray)
                                        Text("on \(track.album)")
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundStyle(Color.textGray)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundGray))
                                .shadow(radius: 5)
                                .padding(.vertical, 5)
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
                        .frame(height: 55.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.customGreen)
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
