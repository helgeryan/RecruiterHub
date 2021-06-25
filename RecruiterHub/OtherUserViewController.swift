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
        title = "\(user.firstName) \(user.lastName)"
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
        
        configureCoachCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        addPostButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        coachCollectionView.frame = view.bounds
        fetchPosts()
    }
    
    private func addPostButton(){
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .done, target: self, action: #selector(didTapMessageButton))
        barButtonItem.accessibilityLabel = "barButtonItem"
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func configureCoachCollectionView() {
        coachCollectionView.delegate = self
        coachCollectionView.dataSource = self
        
        coachCollectionView.register(ProfileTabs.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabs.identifier)
        
        coachCollectionView.register(ProfileConnections.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileConnections.identifier)
        
        coachCollectionView.register(CoachProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CoachProfileHeader.identifier)
        coachCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        view.addSubview(coachCollectionView)
    }
    
    @objc private func didTapMessageButton() {
        
        let otherUserEmail = user.safeEmail
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        DatabaseManager.shared.getAllConversations(for: currentEmail.safeDatabaseKey(), completion: { [weak self]
            conversations in

            switch conversations {
            case .success(let conversations):
                if let targetConversation = conversations.first(where: {
                    $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: otherUserEmail)
                }) {
                    print("Want to append conversation")
                    
                    let vc = ChatViewController(with: otherUserEmail, id: targetConversation.id)
                    vc.isNewConversation = false
                    vc.navigationItem.largeTitleDisplayMode = .never
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    print("Want to create a new conversation")
                    DatabaseManager.shared.getDataForUserSingleEvent(user: otherUserEmail.safeDatabaseKey(), completion: { [weak self]
                        user in
                        guard let user = user else {
                            return
                        }
                        let result = SearchResult(name: user.name, email: user.safeEmail)
                        self?.createNewConversation(result: result)
                    })
                }
                break
            case .failure(let error):
                switch error {
                case DatabaseManager.DatabaseError.failedToFetch:
                    print("Failed to Fetch")
                    break
                case DatabaseManager.DatabaseError.conversationsEmpty:
                    print("Convos Empty")
                    DatabaseManager.shared.getDataForUserSingleEvent(user: otherUserEmail.safeDatabaseKey(), completion: { [weak self]
                        user in
                        guard let user = user else {
                            return
                        }
                        let result = SearchResult(name: user.name, email: user.safeEmail)
                        self?.createNewConversation(result: result)
                    })
                    break
                default:
                    break
                }
                break
            }
        })
    }
    
    private func createNewConversation(result: SearchResult) {
        let email = result.email

        // Check in the database if the conversation with these two users exists
        // if it does, reuse conversationid
        // if not create new
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in

            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = true
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    private func fetchPosts() {
        DatabaseManager.shared.getAllUserPosts(with: self.user.emailAddress.safeDatabaseKey(), completion: { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            
            DispatchQueue.main.async {
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
        
        if coachCollectionView == collectionView {
            // Dequeue reusable view of type ProfileHeader
            let coachProfileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CoachProfileHeader.identifier, for: indexPath) as! CoachProfileHeader
//            coachProfileHeader.delegate = self

            coachProfileHeader.configure(user: user, hideFollowButton: false)

            return coachProfileHeader
        }
        
        // Dequeue reusable view of type ProfileHeader
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as! ProfileHeader
        
        profileHeader.delegate = self
        profileHeader.configure(user: user, hideFollowButton: false)
        
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
        
        if coachCollectionView == collectionView {
            return CGSize(width: view.width, height: CoachProfileHeader.getHeight(isYourProfile: false))
        }
        
        return CGSize(width: view.width, height: ProfileHeader.getHeight(isYourProfile: false))
    }
}

extension OtherUserViewController: ProfileHeaderDelegate {

}

extension OtherUserViewController: ProfileTabsDelegate {
    func didTapInfoButtonTab() {
        let vc = ContactInformationViewController(user: user)
        vc.title = "Contact Information"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapScoutButtonTab() {
        let vc = ScoutViewController(user: user)
        vc.title = "Scout Info"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OtherUserViewController: ProfileConnectionsDelegate {
    func didTapEndorsementsButton(_ profileConnections: ProfileConnections) {
        //TODO
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
