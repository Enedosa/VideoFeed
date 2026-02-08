//
//  NetworkClient.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//
import UIKit

protocol NetworkClient {
    func fetchVideos() async throws -> [Video]
}

final class URLSessionNetworkClient: NetworkClient {

    private let session: URLSession
    private let url: URL

    init(
            url: URL = URL(string: "https://api.pexels.com/videos/search?query=nature&per_page=10&orientation=portrait")!
        ) {
            self.url = url
        
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.httpMaximumConnectionsPerHost = 1
            config.timeoutIntervalForRequest = 10
           
            self.session = URLSession(configuration: config)
        }

    func fetchVideos() async throws -> [Video] {
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 8

            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(VideoResponse.self, from: data)
            print("🌐 Remote videos loaded:", decoded.videos?.count)
            return decoded.videos ?? []

        } catch {
            print("⚠️ Remote failed → using local JSON:", error.localizedDescription)
            return try loadLocalVideos()
        }
    }

    private func loadLocalVideos() throws -> [Video] {
        guard let url = Bundle.main.url(forResource: "videos", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(VideoResponse.self, from: data)
        print("📦 Local videos loaded:", decoded.videos?.count)
        return decoded.videos ?? []
    }
}

enum NetworkError: Error {
    case invalidURL
    case badResponse(Int)
    case decoding(Error)
    case unknown
}
