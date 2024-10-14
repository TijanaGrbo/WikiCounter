//
//  ContentView.swift
//  WikiCounter
//
//  Created by Tijana Grbo on 14/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var topic = ""
    @State private var occurrenceCount = 0

    @State private var articleText = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Search for a Wiki topic", text: $topic)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical)
            Button {
                Task {
                    await searchForTopic(for: topic)
                }
            } label: {
                Text("Search")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    func searchForTopic(for topic: String) async {
        guard !topic.isEmpty else {
            articleText = "Please enter a search term"
            occurrenceCount = 0
            return
        }

        let formattedTopic = topic.replacingOccurrences(of: " ", with: "_")
        // separate the url into multiple components for better readability if there's time
        let urlString = "https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&format=json&redirects=true&page=\(formattedTopic)"
        guard let queryUrl = URL(string: urlString) else {
            articleText = "Invalid URL"
            occurrenceCount = 0
            return
        }

        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: queryUrl)
            isLoading = false
        } catch {
            // error
        }

        // handle no result/error
        // parse
        // count the number of occurrences
        // assign to the counter
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
// display the number of occurrences
