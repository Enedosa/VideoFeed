//
//  VideoPlayerManager.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//
import UIKit
import AVFoundation

final class VideoPlayerManager {
    static let shared = VideoPlayerManager()

    private var players: [IndexPath: AVPlayer] = [:]

    func player(for url: URL, at indexPath: IndexPath) -> AVPlayer {
        if let player = players[indexPath] {
            return player
        }

        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause
        players[indexPath] = player
        return player
    }

    func pauseAll(except indexPath: IndexPath?) {
        for (key, player) in players {
            if key != indexPath {
                player.pause()
                players[key] = nil
            }
        }
    }
}
