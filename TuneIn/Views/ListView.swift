//
//  ListView.swift
//  TuneIn
//
//  Created by Bert Joseph Prestoza on 2/21/24.
//

import SwiftUI

struct ListView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Text("TUNE IN")
            .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
            .padding()
        Spacer()
        VStack {
            Button(action: {
                dismiss()
            }) {
                Text("VIEW MAP")
                    .font(.custom("Avenir", size: 16.0).uppercaseSmallCaps())
                    .foregroundColor(.white)
                    .padding(10.0)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
        }
        .padding([.top, .horizontal], 12.0)
    }
}

#Preview {
    ListView()
}
