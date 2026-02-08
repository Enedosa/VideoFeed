//
//  VideoCell.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 05/02/2026.
//


import UIKit
import AVFoundation

final class VideoCell: UICollectionViewCell {

    static let identifier = "VideoCell"

    var onUsernameTap: (() -> Void)?
    var onLikeTap: (() -> Void)?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private let videoContainer = UIView()

    private let placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let btn = makeButton("heart.fill")
        btn.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return btn
    }()

    private let actionStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with video: Video, isLiked: Bool) {
        cleanup()
        updateLikeAppearance(isLiked: isLiked, animated: false)
        usernameLabel.text = "@\(video.user?.name?.lowercased() ?? "user")"
        captionLabel.text = video.url ?? ""

        if let preview = video.image,
           let url = URL(string: preview) {
            loadPlaceholder(url: url)
        }

        guard let url = video.bestPlayableURL else {
            print("❌ No playable URL")
            return
        }

        preparePlayer(url: url)
    }

    private func preparePlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = contentView.bounds

        videoContainer.layer.addSublayer(layer)

        self.player = player
        self.playerLayer = layer
    }

    func play() {
        player?.play()
        UIView.animate(withDuration: 0.25) {
            self.placeholderImageView.alpha = 0
        }
    }

    func pause() {
        player?.pause()
    }

    private func cleanup() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        placeholderImageView.alpha = 1
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }

    private func setupLayout() {
        contentView.backgroundColor = .black

        actionStack.axis = .vertical
        actionStack.spacing = 24
        actionStack.addArrangedSubview(likeButton)
        actionStack.addArrangedSubview(makeButton("message.fill"))
        actionStack.addArrangedSubview(makeButton("arrowshape.turn.up.right.fill"))

        [videoContainer, placeholderImageView, usernameLabel, captionLabel, actionStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        usernameLabel.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            placeholderImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            placeholderImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            usernameLabel.bottomAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -8),

            captionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            captionLabel.trailingAnchor.constraint(equalTo: actionStack.leadingAnchor, constant: -12),

            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionStack.bottomAnchor.constraint(equalTo: captionLabel.bottomAnchor)
        ])
    }
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        usernameLabel.addGestureRecognizer(tap)
    }
    
    @objc private func handleUserTap() { onUsernameTap?() }
    
    @objc private func didTapLike() {
        onLikeTap?()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func updateLikeAppearance(isLiked: Bool, animated: Bool) {
        likeButton.tintColor = isLiked ? .systemRed : .white
        
        if animated && isLiked {
            likeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: .allowUserInteraction) {
                self.likeButton.transform = .identity
            }
        }
    }
    private func makeButton(_ icon: String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        button.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }

    private func loadPlaceholder(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.placeholderImageView.image = img
            }
        }.resume()
    }
}

