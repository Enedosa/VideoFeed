//
//  ProfileViewController.swift
//  VideoPlayer
//
//  Created by Ebele Nedosa on 04/02/2026.
//

import UIKit


final class ProfileViewControllerr: UIViewController {

    private let vm: ProfileViewModel

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let infoLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Init
    init(user: User, videos: [Video]) {
        self.vm = ProfileViewModel(user: user, videos: videos)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        configure()
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            // Info Label
            infoLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configure() {
        infoLabel.text = """
        \(vm.username)
        Videos: \(vm.videoCount)
        Likes: \(vm.totalLikes)
        """

        if let url = vm.avatarURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }.resume()
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}


final class ProfileViewController: UIViewController {

    private let user: User
    private let viewModel = FeedViewModel(network: URLSessionNetworkClient())
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ProfileGridCell.self, forCellWithReuseIdentifier: ProfileGridCell.identifier)
        cv.register(ProfileHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: ProfileHeaderView.identifier)
        return cv
    }()

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = user.name ?? "Profile"
        setupCollectionView()
        bindViewModel()
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.onVideosUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(200))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileGridCell.identifier, for: indexPath) as! ProfileGridCell
        let video = viewModel.videos[indexPath.item]
        cell.configure(with: video.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.identifier, for: indexPath) as! ProfileHeaderView
            header.configure(with: user.name)
            return header
        }
        return UICollectionReusableView()
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedViewController()
        
        feedVC.setInitialVideos(viewModel.videos, at: indexPath.item)
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
}



final class ProfileHeaderView: UICollectionReusableView {
    static let identifier = "ProfileHeaderView"
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .systemGray3
        iv.layer.cornerRadius = 45
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with name: String?) {
        nameLabel.text = name ?? "Anonymous User"
    }
    
    private func setupUI() {
        [avatarImageView, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 90),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}



final class ProfileGridCell: UICollectionViewCell {
    static let identifier = "ProfileGridCell"
    
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with imageUrl: String?) {
        guard let urlString = imageUrl, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.thumbnailImageView.image = image
                }
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}
