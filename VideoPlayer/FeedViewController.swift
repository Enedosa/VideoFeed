//
//  FeedViewController.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 04/02/2026.
//
import UIKit
import AVFoundation

final class FeedViewController: UIViewController {

    private let viewModel = FeedViewModel(network: URLSessionNetworkClient())
    private var currentIndexPath: IndexPath?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)

        view.backgroundColor = .black
        setupUI()
        bind()
        viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func bind() {
        viewModel.onVideosUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}

extension FeedViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.videos.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VideoCell.identifier,
            for: indexPath
        ) as! VideoCell
        let video = viewModel.videos[indexPath.item]
        cell.configure(with: viewModel.videos[indexPath.item], isLiked: viewModel.isLiked(video))
        cell.onUsernameTap = { [weak self] in
            guard let user = video.user else { return }
            let profileVC = ProfileViewController(user: user)
            self?.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        cell.onLikeTap = { [weak self] in
            self?.viewModel.toggleLike(for: video)
            cell.updateLikeAppearance(isLiked: self?.viewModel.isLiked(video) ?? false, animated: true)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        view.bounds.size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let current = currentIndexPath,
           let oldCell = collectionView.cellForItem(at: current) as? VideoCell {
            oldCell.pause()
        }

        (cell as? VideoCell)?.play()
        currentIndexPath = indexPath
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? VideoCell)?.pause()
    }
}

