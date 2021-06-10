//
//  ProfileViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/14/21.
//

import UIKit
import SwiftUI
import FirebaseAuth

class ProfileViewController: UIViewController {

    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        return collectionView
    }()
    
    private var user: RHUser = RHUser()
    
    private var posts: [UserPost]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Profile"
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        collectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        collectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        //tiffany------
        addPostButton()
    }
    
    //tiffany------
    private func addPostButton(){
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .done, target: self, action: #selector(didTapAddPostButton))
        barButtonItem.accessibilityLabel = "barButtonItem"
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func didTapAddPostButton(){
        print("it's pressed")
        let vc = NewPostViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    //end: tiffany------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleNotAuthenticated()
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Email not set")
            return
        }
        
        if currentEmail != user.safeEmail {
            fetchPosts()
        }
        else {
            DatabaseManager.shared.getAllUserPosts(with: user.safeEmail, completion: { [weak self] posts in
                guard let posts = posts else {
                    return
                }

                if posts.count != self?.posts?.count {
                    self?.fetchPosts()
                }
            })
        }
    }
    
    func handleNotAuthenticated() {
        if Auth.auth().currentUser == nil {
            // Show Log In
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height - view.safeAreaInsets.top)
    }
    
    @objc private func didTapEditButton() {
        let vc = SettingsViewController(user: user)
        vc.title = "Settings"
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchPosts() {
      
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("failed")
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("Fetching Posts")
        DatabaseManager.shared.getAllUserPosts(with: safeEmail, completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts

            DatabaseManager.shared.getDataForUser(user: safeEmail, completion: {
                [weak self] user in
                guard let user = user else {
                    return
                }
                self?.user = user

                self?.collectionView.reloadData()
            })
        })
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    
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
        
        let vc = ViewPostViewController(post: model, user: user, postNumber: posts.count - indexPath.row - 1)
        
        vc.title = "Post"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts else {
            return 0
        }
        
        if section != 2 {
            return 0
        }
        
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let posts = posts else {
            return UICollectionViewCell()
        }
        let thumbnailUrl = posts[posts.count - indexPath.row - 1].thumbnailImage
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: thumbnailUrl)
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
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String, email != "" {
           
            DatabaseManager.shared.getDataForUser(user: email.safeDatabaseKey(), completion: {
                result in
                guard let result = result else {
                    return
                }
                
                profileHeader.configure(user: result, hideFollowButton: true)
            })
        }
        return profileHeader
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        if section == 1 {
            return CGSize(width: view.width, height: 50)
        }
        
        if section == 2 {
            return CGSize(width: view.width, height: 70)
        }
        
        return CGSize(width: view.width, height: ProfileHeader.getHeight(isYourProfile: true))
    }
}

extension ProfileViewController: ProfileHeaderDelegate {

}

extension ProfileViewController: ProfileTabsDelegate {
    func didTapInfoButtonTab() {
        let vc = ContactInformationViewController(user: user)
        vc.title = "Contact Information"
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapScoutButtonTab() {
        print("Tapped scout")
        let vc = ScoutViewController(user: user)
        vc.title = "Scout Info"
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: ProfileConnectionsDelegate {
    func didTapEndorsementsButton(_ profileConnections: ProfileConnections) {
        // TODO
        DatabaseManager.shared.getUserEndorsementsSingleEvent(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] endorsers in
            var data:[[String:String]] = []
            if let endorsers = endorsers {
                for endorser in endorsers {
                    let newElement = ["email": endorser.email]
                    data.append(newElement)
                }
            }
            let vc = ListsViewController(data: data)
            vc.title = "Endorsers"
            self?.navigationController?.pushViewController(vc, animated: true)
            return
        })
    }
    

    func didTapFollowingButton(_ profileConnections: ProfileConnections) {
        print("Did tap following")
        DatabaseManager.shared.getUserFollowingSingleEvent(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                for follower in followers {
                    let newElement = ["email": follower.email]
                    data.append(newElement)
                }
            }
            let vc = ListsViewController(data: data)
            vc.title = "Following"
            self?.navigationController?.pushViewController(vc, animated: true)
            return
        })
    }
    
    func didTapFollowersButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowersSingleEvent(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[[String:String]] = []
            if let followers = followers {
                for follower in followers {
                    let newElement = ["email": follower.email]
                    data.append(newElement)
                }
            }
            let vc = ListsViewController(data: data)
            vc.title = "Followers"
            self?.navigationController?.pushViewController(vc, animated: true)
            return
        })
    }
}
