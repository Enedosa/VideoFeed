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
    private var isLiked = false
    var onUsernameTap: (() -> Void)?

    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?

    private let videoContainer = UIView()
    
    private let placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let btn = createActionButton(icon: "heart.fill")
        btn.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return btn
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 25
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(with video: Video, isLiked: Bool, likeAction: (() -> Void)? = nil) {
  
        self.likeButton.isSelected = isLiked
        usernameLabel.text = "@\(video.user?.name?.replacingOccurrences(of: " ", with: "_").lowercased() ?? "user")"
        
        captionLabel.text = formatCaption(from: video.url)

        if let imageUrl = video.image, let url = URL(string: imageUrl) {
            loadPlaceholder(from: url)
        }
        
        if let videoURLString = video.videoFiles?.first(where: { $0.quality?.rawValue ?? "" == "hd" })?.link ?? video.videoFiles?.first?.link,
           let url = URL(string: videoURLString) {
            setupPlayer(with: url)
        }
    }
    
    private func formatCaption(from urlString: String?) -> String {
        guard let urlString = urlString, let slug = urlString.split(separator: "/").last else {
            return "Discover amazing content on Pexels"
        }
        let words = slug.split(separator: "-").dropLast()
        return words.joined(separator: " ").capitalized
    }
    
    private func setupPlayer(with url: URL) {
        let item = AVPlayerItem(url: url)
        player = AVQueuePlayer(playerItem: item)
        playerLooper = AVPlayerLooper(player: player!, templateItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let layer = playerLayer {
            videoContainer.layer.addSublayer(layer)
        }
    }

    func play() {
        player?.play()
        UIView.animate(withDuration: 0.3) {
            self.placeholderImageView.alpha = 0
        }
    }
    
    func pause() {
        player?.pause()
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        isLiked = false
        likeButton.tintColor = .white
        likeButton.transform = .identity
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLooper = nil
        placeholderImageView.image = nil
        placeholderImageView.alpha = 1
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        usernameLabel.addGestureRecognizer(tap)
    }
    
    @objc private func handleUserTap() {
        onUsernameTap?()
    }
    
    private func setupLayout() {
        contentView.backgroundColor = .black
        
        [videoContainer, placeholderImageView, usernameLabel, captionLabel, actionStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        let comment = createActionButton(icon: "message.fill")
        let share = createActionButton(icon: "arrowshape.turn.up.right.fill")
        [likeButton, comment, share].forEach { actionStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            placeholderImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholderImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeholderImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeholderImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            actionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            usernameLabel.bottomAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -10),
            
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            captionLabel.trailingAnchor.constraint(equalTo: actionStack.leadingAnchor, constant: -20),
            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    @objc private func didTapLike() {
        isLiked.toggle()
        updateLikeAppearance(animated: true)
        //haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func updateLikeAppearance(animated: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        let heartImage = UIImage(systemName: "heart.fill", withConfiguration: config)
        
        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .white
        
        if animated && isLiked {
            likeButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.6,
                           options: .allowUserInteraction,
                           animations: {
                self.likeButton.transform = .identity
            }, completion: nil)
        }
    }
    
   
    private func createActionButton(icon: String) -> UIButton {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        btn.setImage(UIImage(systemName: icon, withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        return btn
    }
    
    private func loadPlaceholder(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                DispatchQueue.main.async { self?.placeholderImageView.image = img }
            }
        }.resume()
    }
}
