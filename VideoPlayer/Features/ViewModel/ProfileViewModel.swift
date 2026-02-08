//
//  ProfileViewModel.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//

import Foundation


final class ProfileViewModel {
    private let user: User
    private let videos: [Video]

    init(user: User, videos: [Video]) {
        self.user = user
        self.videos = videos
    }

    var username: String { user.name ?? "" }
    var avatarURL: URL? { user.avatarURL }
    var videoCount: Int { videos.count }
    var totalLikes: Int { videos.reduce(0) { $0 + ($1.likeCount ?? 0) } }

    func video(at index: Int) -> Video {
        videos[index]
    }
}
