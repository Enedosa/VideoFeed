//
//  VideoResponse.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//

import UIKit


struct VideoResponse: Codable {
    let page, perPage: Int?
    let videos: [Video]?
    let totalResults: Int?
    let nextPage, url: String?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case videos
        case totalResults = "total_results"
        case nextPage = "next_page"
        case url
    }
}

struct Video: Codable {
    let id, width, height, duration: Int?
    let url: String?
    let image: String?
    let user: User?
    let videoFiles: [VideoFile]?
    let videoPictures: [VideoPicture]?

    var likeCount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, duration
        case url, image
        case user
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
}

struct User: Codable {
    let id: Int?
    let name: String?
    let url: String?
    
    var avatarURL: URL? {
        return nil
    }
}

struct VideoFile: Codable {
    let id: Int?
    let quality: Quality?
    let fileType: FileType?
    let width, height: Int?
    let fps: Double?
    let link: String?
    let size: Int?

    enum CodingKeys: String, CodingKey {
        case id, quality
        case fileType = "file_type"
        case width, height, fps, link, size
    }
}

enum FileType: String, Codable {
    case videoMp4 = "video/mp4"
}

enum Quality: String, Codable {
    case hd = "hd"
    case sd = "sd"
    case uhd = "uhd"
}

struct VideoPicture: Codable {
    let id, nr: Int?
    let picture: String?
}


//extension Video {
//    var bestPlayableURL: URL? {
//        // Pick the smallest width MP4 video
//        guard let urlString = videoFiles?
//            .sorted(by: { $0.width ?? 0 < $1.width ?? 0 })
//            .first(where: { $0.fileType?.rawValue ?? "" == "video/mp4" })?
//            .link else {
//                return nil
//        }
//        return URL(string: urlString)
//    }
//}
extension Video {
    var bestPlayableURL: URL? {
        // 1. Ensure files exist
        guard let files = videoFiles else { return nil }

        // 2. Filter for mp4 files using rawValue to avoid enum member errors
        let mp4s = files.filter { $0.fileType?.rawValue.lowercased().contains("mp4") == true }

        // 3. Sort by width: Smallest width first
        let sortedMp4s = mp4s.sorted { ($0.width ?? 0) < ($1.width ?? 0) }

        // 4. Take the very first (smallest) one
        guard let link = sortedMp4s.first?.link else { return nil }
        
        return URL(string: link)
    }
}
