//
//  OtherUserViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/26/21.
//

import UIKit
import SwiftUI
import FirebaseAuth

class OtherUserViewController: UIViewController {

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collection
    }()
    
    private var user: RHUser
    
    private var posts: [UserPost]?

    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        collectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        collectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        fetchPosts()
    }
    
    private func fetchPosts() {
        DatabaseManager.shared.getAllUserPosts(with: self.user.emailAddress.safeDatabaseKey(), completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        })
    }
}

extension OtherUserViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("Selected Item")
        guard let posts = posts else {
            return
        }
        
        let model = posts[posts.count - indexPath.row - 1]
        
        var postLikes :[PostLike] = []
        
        for like in model.likeCount {
            let postLike = PostLike(username: like.username, email: like.email, name: like.name)
            postLikes.append(postLike)
        }
        print(model.postURL)
        
        let vc = ViewPostViewController(post: model, user: user, postNumber: posts.count - indexPath.row - 1)
        
        vc.title = "Post"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension OtherUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 0
        }
        
        guard let posts = posts else {
            return 0
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let posts = posts else {
            return UICollectionViewCell()
        }
        let model = posts[posts.count - indexPath.row - 1]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: model.thumbnailImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Check that the kind is of section header
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        if indexPath.section == 1 {
            let profileTabs = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileTabs.identifier, for: indexPath) as! ProfileTabs
            profileTabs.delegate = self
            return profileTabs
        }
        
        if indexPath.section == 2 {
            let profileConnections = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileConnections.identifier, for: indexPath) as! ProfileConnections
            profileConnections.delegate = self
            profileConnections.configure(email: user.safeEmail)
            return profileConnections
        }
        
        // Dequeue reusable view of type ProfileHeader
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        profileHeader.delegate = self
        
        let email = user.safeEmail
        
        DatabaseManager.shared.getDataForUser(user: email.safeDatabaseKey(), completion: {
            result in
            guard let result = result else {
                return
            }
            
            profileHeader.configure(user: result, hideFollowButton: false)
        })
        
        return profileHeader
    }
}

extension OtherUserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        if section == 1 {
            return CGSize(width: view.width, height: 50)
        }
        
        if section == 2 {
            return CGSize(width: view.width, height: 70)
        }
        
        return CGSize(width: view.width, height: ProfileHeader.getHeight(isYourProfile: false))
    }
}

extension OtherUserViewController: ProfileHeaderDelegate {
    func didTapFollowButton(_ header: ProfileHeader) {
        guard let email =  UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.follow(email: user.safeEmail, followerEmail: email.safeDatabaseKey())
    }
    
    func didTapReload(_ header: ProfileHeader) {
        fetchPosts()
    }
}

extension OtherUserViewController: ProfileTabsDelegate {
    func didTapInfoButtonTab() {
        let vc = ContactInformationViewController(user: user)
        vc.title = "Contact Information"
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func didTapScoutButtonTab() {
        let vc = ScoutViewController(user: user)
        vc.title = "Scout Info"
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension OtherUserViewController: ProfileConnectionsDelegate {
    func didTapEndorsementsButton(_ profileConnections: ProfileConnections) {
        //TODO
        DatabaseManager.shared.getUserEndorsements(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] endorsers in
            var data:[[String:String]] = []
            if let endorsers = endorsers {
                    data = endorsers
            }
            let vc = ListsViewController(data: data)
            vc.title = "Endorsers"
            self?.navigationController?.pushViewController(vc, animated: false)
            return
        })
    }
    
    func didTapFollowingButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowing(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                    data = followers
            }
            let vc = ListsViewController(data: data)
            vc.title = "Following"
            self?.navigationController?.pushViewController(vc, animated: false)
            return
        })
    }
    
    func didTapFollowersButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowers(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                    data = followers
            }
            let vc = ListsViewController(data: data)
            vc.title = "Followers"
            self?.navigationController?.pushViewController(vc, animated: false)
            return
        })
    }
}
