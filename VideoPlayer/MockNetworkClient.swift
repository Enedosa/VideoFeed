//
//  MockNetworkClient.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 08/02/2026.
//
import Foundation

class MockNetworkClient: NetworkClient {
    var result: Result<[Video], Error> = .success([])
    var fetchCount = 0

    func fetchVideos() async throws -> [Video] {
        fetchCount += 1
        switch result {
        case .success(let videos): return videos
        case .failure(let error): throw error
        }
    }
}
