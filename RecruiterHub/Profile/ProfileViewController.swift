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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (UIScreen.main.bounds.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var coachCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (UIScreen.main.bounds.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var user: RHUser = RHUser()
    
    private var posts: [UserPost]?
    
    private let noVideosLabel: UILabel = {
        let label = UILabel()
        label.text = "No new videos"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Your Profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
        
        collectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        collectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
       configureCoachCollectionView()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .secondarySystemBackground
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
    
    private func configureCoachCollectionView() {
        coachCollectionView.delegate = self
        coachCollectionView.dataSource = self
        
        coachCollectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        coachCollectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        coachCollectionView.register(CoachProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CoachProfileHeader.identifier)
        coachCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        view.addSubview(coachCollectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleNotAuthenticated()
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Email not set")
            return
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        if user.safeEmail == currentEmail {
            return
        }
        
        fetchPosts(email: currentEmail)
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
        coachCollectionView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height - view.safeAreaInsets.top)
        
    }
    
    @objc private func didTapEditButton() {
        let vc = SettingsViewController(user: user)
        vc.title = "Settings"
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchPosts(email: String) {

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

                if self?.user.profileType == "coach" {
                    self?.coachCollectionView.isHidden = false
                    self?.collectionView.isHidden = true
                    self?.coachCollectionView.reloadData()
                }
                else {
                    self?.coachCollectionView.isHidden = true
                    self?.collectionView.isHidden = false
                    self?.collectionView.reloadData()
                }
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

        let vc = ViewPostViewController(post: model, user: user, postNumber: posts.count - indexPath.row - 1)
        
        vc.title = "Post"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts, section == 2 else {
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
        
        if coachCollectionView == collectionView {
            // Dequeue reusable view of type ProfileHeader
            let coachProfileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CoachProfileHeader.identifier, for: indexPath) as! CoachProfileHeader
//            coachProfileHeader.delegate = self

            coachProfileHeader.configure(user: user, hideFollowButton: true)

            return coachProfileHeader
        }
        
        // Dequeue reusable view of type ProfileHeader
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        profileHeader.delegate = self

                profileHeader.configure(user: user, hideFollowButton: true)

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
        
        if coachCollectionView == collectionView {
            return CGSize(width: view.width, height: CoachProfileHeader.getHeight(isYourProfile: true))
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
        
        if user.profileType == "coach" {
            let vc = CoachScoutViewController()
            vc.title = "Scout"
            vc.modalTransitionStyle = .flipHorizontal
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let vc = ScoutViewController(user: user)
        vc.title = "Scout Info"
        vc.modalTransitionStyle = .flipHorizontal
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: ProfileConnectionsDelegate {
    func didTapEndorsementsButton(_ profileConnections: ProfileConnections) {
        // TODO
        let vc = ReferencesViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapFollowingButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowingSingleEvent(email: user.safeEmail, completion: { [weak self] followers in
            var data:[SearchResult] = []
            if let followers = followers {
                let group = DispatchGroup()
                group.enter()
                for (index, follower) in followers.enumerated() {
                    DatabaseManager.shared.getDataForUserSingleEvent(user: follower.email, completion: {
                        user in
                        guard let user = user else {
                            if index == followers.count - 1 {
                                group.leave()
                            }
                            return
                        }
                        
                        let newElement = SearchResult(name: user.name, email: user.safeEmail)
                        data.append(newElement)
                        
                        if index == followers.count - 1 {
                            group.leave()
                        }
                    })
                }
                group.notify(queue: .main, execute: {
                    let vc = ListsViewController(data: data)
                    vc.title = "Following"
                    self?.navigationController?.pushViewController(vc, animated: true)
                    return
                })
            }
        })
    }
    
    func didTapFollowersButton(_ profileConnections: ProfileConnections) {
        DatabaseManager.shared.getUserFollowersSingleEvent(email: user.emailAddress.safeDatabaseKey(), completion: { [weak self] followers in
            var data:[SearchResult] = []
            if let followers = followers {
                let group = DispatchGroup()
                group.enter()
                for (index, follower) in followers.enumerated() {
                    DatabaseManager.shared.getDataForUserSingleEvent(user: follower.email, completion: {
                        user in
                        guard let user = user else {
                            if index == followers.count - 1 {
                                group.leave()
                            }
                            return
                        }
                        
                        let newElement = SearchResult(name: user.name, email: user.safeEmail)
                        data.append(newElement)
                        
                        if index == followers.count - 1 {
                            group.leave()
                        }
                    })
                }
                group.notify(queue: .main, execute: {
                    let vc = ListsViewController(data: data)
                    vc.title = "Followers"
                    self?.navigationController?.pushViewController(vc, animated: true)
                    return
                })
            }
        })
    }
}
