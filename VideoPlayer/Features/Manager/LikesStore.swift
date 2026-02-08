//
//  LikesStore.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//
import UIKit

final class LikesStore {
    private let key = "likedVideos"

    var ids: Set<Int> {
        get {
            Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    func isLiked(id: Int) -> Bool {
        ids.contains(id)
    }

    func toggleLike(id: Int) {
        var copy = ids
        if copy.contains(id) {
            copy.remove(id)
        } else {
            copy.insert(id)
        }
        ids = copy
    }
}
