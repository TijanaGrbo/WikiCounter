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

            ProgressView()
                .opacity(isLoading ? 1 : 0)

            ScrollView {
                Text(articleText)
            }
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

            print(String(data: data, encoding: String.Encoding.utf8) ?? "NIL")

            let wikiResponse = try JSONDecoder().decode(WikiResponse.self, from: data)

            // Extract the HTML content and convert to plain text
            let htmlContent = wikiResponse.wikiResult.articleText.content
            let plainText = convertHTMLToPlainText(htmlContent)

            print(plainText)

            await MainActor.run {
                self.articleText = plainText ?? "Could not parse article content."
                self.occurrenceCount = 0
            }

        } catch {
            // error
        }

        // handle no result/error
        // count the number of occurrences
        // assign to the counter
        // reset topic string
    }

    func convertHTMLToPlainText(_ htmlString: String) -> String? {
        guard let data = htmlString.data(using: .utf8) else { return nil }

        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString.string
        } catch {
            print("Error converting the text to HTML: \(error)")
            return nil
        }
    }
}

#Preview {
    ContentView()
}

// create counting logic
// display the number of occurrences

struct WikiResponse: Decodable {
    let wikiResult: WikiResult

    enum CodingKeys: String, CodingKey {
        case wikiResult = "parse"
    }
}

struct WikiResult: Decodable {
    let title: String
    let pageid: Int
    let articleText: WikiArticleText

    enum CodingKeys: String, CodingKey {
        case title, pageid
        case articleText = "text"
    }
}

struct WikiArticleText: Decodable {
    let content: String

    enum CodingKeys: String, CodingKey {
        case content = "*"
    }
}

