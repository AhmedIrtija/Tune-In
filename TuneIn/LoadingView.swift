//
//  LoadingView.swift
//  TuneIn
//
//  Created by Ashani Sinha on 3/3/24.
//

import Foundation
import SwiftUI

struct LoadingView : View {
    
    @State var openView = false    
    var body: some View {
        ZStack {
            Text("Loading...")
        }
        .overlay {
                ZStack {
                    Color(white: 0, opacity: 0.75)
                    ProgressView().tint(.white)
                }
        }
    }
}
