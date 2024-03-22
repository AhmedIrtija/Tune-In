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
                                VStack {
                                    HStack {
                                        Text(user.name)
                                            .font(Font.custom("Damion", size: 24))
                                            .foregroundStyle(Color.white)
    //                                            .background(RoundedRectangle(cornerRadius: 4).fill(Color.black))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        AsyncImage(url: URL(string: track.albumUrl)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Image(systemName: "music.note.list")
                                                .aspectRatio(contentMode: .fit)
                                        }
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10)

                                        VStack(alignment: .leading) {
                                            Text("\(track.name)")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Color.textGray)
                                                .padding(.bottom, 2)
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
                                    .offset(y: -30)
                                }
                                .padding(.bottom, -30)
                                
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
