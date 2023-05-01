//
//  VideoManager.swift
//  VideoFinderSwiftUI
//
//  Created by UKESH KUMAR on 24/03/23.
//

import Foundation

enum Query: String, CaseIterable {
    case nature, animals, people, ocean, food
}

class VideoManager: ObservableObject {
    @Published private(set) var videos: [Video] = []
    @Published var selectedQuery: Query = Query.nature {
        didSet {
            Task.init {
                await findVideos(topic: selectedQuery)
            }
        }
    }
    
    init() {
        Task.init {
            await findVideos(topic: selectedQuery)
        }
    }
    
    // Fetching the videos asynchronously
    func findVideos(topic: Query) async {
        do {
            guard let url = URL(string: "https://api.pexels.com/videos/search?query=\(topic)&per_page=10&orientation=portrait") else { fatalError("Missing URL") }
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.setValue("563492ad6f91700001000001c5e05f997bf84b9698b9b0e3015d9786", forHTTPHeaderField: "Authorization")
            
            // Fetching the data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
            
            let decoder = JSONDecoder()
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode into the ResponseBody struct below
            let decodedData = try decoder.decode(ResponseBody.self, from: data)
            
            DispatchQueue.main.async {
                self.videos = []
                
                self.videos = decodedData.videos
            }
            
        } catch {
            // If we run into an error, print the error in the console
            print("Error fetching data from Pexels: \(error)")
        }
    }
}

