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
            VStack {
                Text("The phrase '\(topic)' occurs")
                Text(occurrenceCount.description)
                    .font(.largeTitle)
                    .bold()
                Text("times.")
            }
            .padding()

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

            ProgressView()
                .opacity(isLoading ? 1 : 0)

            ScrollView {
                Text(articleText)
            }
        }
        .padding()
        .onChange(of: topic) {
            occurrenceCount = 0
        }
    }

    func searchForTopic(for topic: String) async {
        guard !topic.isEmpty else {
            updateTextAndCounter(text: "Please enter a search term", count: 0)
            return
        }

        let formattedTopic = topic.replacingOccurrences(of: " ", with: "_").lowercased()
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&explaintext=1&redirects=1&titles=\(formattedTopic)"

        guard let queryUrl = URL(string: urlString) else {
            updateTextAndCounter(text: "Invalid URL", count: 0)
            return
        }

        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: queryUrl)

            isLoading = false

            let response = try JSONDecoder().decode(WikiResponse.self, from: data)
            let plainText = response.query.pages.first?.value.extract ?? ""
            let occurrences = countOccurrences(of: topic.lowercased(), in: plainText.lowercased())

            updateTextAndCounter(text: plainText, count: occurrences)
        } catch {
            updateTextAndCounter(text: "Error: \(error.localizedDescription)", count: 0)
        }
    }

    func updateTextAndCounter(text: String, count: Int) {
        articleText = text
        occurrenceCount = count
    }

    func countOccurrences(of phrase: String, in text: String) -> Int {
        do {
            let regex = try NSRegularExpression(pattern: "\(NSRegularExpression.escapedPattern(for: phrase))", options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return matches.count
        } catch {
            print("Error creating regex: \(error.localizedDescription)")
            return 0
        }
    }
}

#Preview {
    ContentView()
}

struct WikiResponse: Decodable {
    let batchcomplete: String
    let query: Query
}

struct Query: Decodable {
    let pages: [String: Page]
}

struct Page: Codable {
    let pageid: Int
    let ns: Int
    let title: String
    let extract: String
}
