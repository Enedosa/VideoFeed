//
//  LikesStore.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//
import UIKit

final class LikesStoree {
    private let key = "likedVideos"

    func isLiked(id: Int) -> Bool {
        likedIDs().contains(id)
//        print("ids..", id)
    }

    func toggleLike(id: Int) {
        var ids = likedIDs()
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }

    private func likedIDs() -> Set<Int> {
  
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        let ints = stored.compactMap { Int($0) }
        return Set(ints)
    }
}

final class LikesStore {
    private let key = "likedVideos"

    private var ids: Set<Int> {
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
