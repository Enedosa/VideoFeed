//
//  FeedViewController.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 04/02/2026.
//
import UIKit

final class FeedViewController: UIViewController {
    private let viewModel = FeedViewModel(network: URLSessionNetworkClient())
    private var currentIndexPath: IndexPath?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.load()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func bindViewModel() {
        viewModel.onVideosUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.handleVideoPlayback()
                }
                self?.playFirstVisibleVideo()
            }
        }
        
    }
    func setInitialVideos(_ videos: [Video], at index: Int) {
            self.viewModel.videos = videos
            let indexPath = IndexPath(item: index, section: 0)
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                self.currentIndexPath = indexPath
            }
        }

        private func handleVideoPlayback() {
            let centerPoint = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.midY)
            
            guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
            if indexPath != currentIndexPath {
                collectionView.visibleCells.forEach { ($0 as? VideoCell)?.pause() }
                if let cell = collectionView.cellForItem(at: indexPath) as? VideoCell {
                    cell.play()
                    currentIndexPath = indexPath
                }
            }
        }
    private func playFirstVisibleVideo() {
        let centerPoint = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.midY)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint),
           let cell = collectionView.cellForItem(at: indexPath) as? VideoCell {
            cell.play()
            currentIndexPath = indexPath
        }
    }
    
    private func playVisibleCell() {
        let visibleCells = collectionView.visibleCells
        let centerPoint = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.midY)
        
        for cell in visibleCells {
            guard let videoCell = cell as? VideoCell else { continue }
            
            let convertedFrame = collectionView.convert(videoCell.frame, to: view)
            
            if convertedFrame.contains(centerPoint) {
                videoCell.play()
            } else {
                videoCell.pause()
            }
        }
    }
}

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        let video = viewModel.videos[indexPath.item]
        cell.configure(with: video, isLiked: viewModel.isLiked(video))
        
        cell.onUsernameTap = { [weak self] in
            guard let self = self else { return }
            guard let user = video.user else {
                print("Error: This video has no associated user.")
                return
            }
            let profileVC = ProfileViewController(user: user)
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playFirstVisibleVideo()
    }
   
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playFirstVisibleVideo()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //  pause the current video here to save CPU
    }
}
