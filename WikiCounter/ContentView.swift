//
//  ContentView.swift
//  WikiCounter
//
//  Created by Tijana Grbo on 14/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var topic = ""
    @State private var occurenceCount = 0

    var body: some View {
        VStack(spacing: 20) {
            TextField("Search for a Wiki topic", text: $topic)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical)
            Button {
                // search for an article
            } label: {
                Text("Search")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// save search field content (requested topic)
// create request
// send request
// create loader
// load while fetching data
// get response
// parse response
// create regex for removing html tags
// create counting logic
// display the number of occurences
