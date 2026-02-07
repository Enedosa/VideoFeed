//
//  FeedViewModel.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//
import UIKit


final class FeedViewModel {

    var onVideosUpdated: (() -> Void)?

   var videos: [Video] = [] {
        didSet {
            onVideosUpdated?()
        }
    }

    private let network: NetworkClient
    private let likesStore = LikesStore()

    init(network: NetworkClient) {
        self.network = network
    }

    func load() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let fetchedVideos = try await network.fetchVideos()
                await MainActor.run {
                    self.videos = fetchedVideos
                }
            } catch {
                await MainActor.run {
                    self.videos = []
                }
            }
        }
    }

    func toggleLike(for video: Video) {
        likesStore.toggleLike(id: video.id ?? 0)
        if let index = videos.firstIndex(where: { $0.id == video.id }) {
            videos[index].likeCount += isLiked(video) ? 1 : -1
            onVideosUpdated?()
        }
    }

    func isLiked(_ video: Video) -> Bool {
        likesStore.isLiked(id: video.id ?? 0)
    }

    func video(at index: Int) -> Video? {
        guard videos.indices.contains(index) else { return nil }
        return videos[index]
    }
}
