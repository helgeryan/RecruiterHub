//
//  FeedViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit
import AVFoundation

class NewFeedViewController: UIViewController {

    private var feedPosts: [NewFeedPost] = []
    
    private let NUMBEROFCELLS = 4
    
    private let noVideosLabel: UILabel = {
        let label = UILabel()
        label.text = "No new videos"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.autoresizesSubviews = true
        table.separatorStyle = .singleLine
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Under The Radar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.2.circlepath"), style: .plain, target: self, action: #selector(didTapReset))
        
        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: FeedPostTableViewCell.identifier)
        
        view.addSubview(tableView)
        view.addSubview(noVideosLabel)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = nil
        tableView.rowHeight = view.height - 50
        
        fetchPosts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    /*  layoutSubviews()
        Override layoutSubviews() to organize all subviews on the viewController.
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noVideosLabel.frame = view.bounds
    }
    
    @objc private func didTapReset() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let group = DispatchGroup()
    
        group.enter()
        var feedPosts: [NewFeedPost] = []
        var followingIndex = 0
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getUserFollowingSingleEvent(email: safeEmail, completion: { [weak self] following in
            guard let following = following else {
                self?.noVideosLabel.isHidden = false
                self?.tableView.isHidden = true
                return
            }
            
            self?.noVideosLabel.isHidden = true
            self?.tableView.isHidden = false
            
            for follow in following {
                DatabaseManager.shared.getAllUserPostsSingleEvent(with: follow.email, completion: { posts in
                    
                    guard let posts = posts else {
                        print("No Posts")
                        return
                    }
                    for post in posts {
                        let feedPost = NewFeedPost(post: post, player: nil)
                        feedPosts.append(feedPost)
                    }
                    followingIndex += 1
                    if followingIndex == following.count {
                        group.leave()
                    }
                })
            }
        })
        group.notify(queue: DispatchQueue.main, execute: {
            
            if feedPosts.count == 0 {
                self.noVideosLabel.isHidden = false
                self.tableView.isHidden = true
            }
            
            var sortedFeedPosts = feedPosts.sorted(by: {  $0.post.createdDate.compare($1.post.createdDate) == .orderedDescending })
            
            if sortedFeedPosts.count < 10 {
                for (index, sortedPost) in sortedFeedPosts.enumerated() {
                    let asset = AVAsset(url: sortedPost.post.postURL)
                    let playerItem = AVPlayerItem(asset: asset)
                    let player = AVPlayer(playerItem: playerItem)
                    sortedFeedPosts[index].player = player
                }
                
                self.feedPosts = [NewFeedPost](sortedFeedPosts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else {
                var trimmedFeedPosts = sortedFeedPosts[0..<10]
                for (index, trimmedPost) in trimmedFeedPosts.enumerated() {
                    let asset = AVAsset(url: trimmedPost.post.postURL)
                    let playerItem = AVPlayerItem(asset: asset)
                    let player = AVPlayer(playerItem: playerItem)
                    trimmedFeedPosts[index].player = player
                }
                
                self.feedPosts = [NewFeedPost](trimmedFeedPosts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

extension NewFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedPosts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /// Create cells based off the following:
    /// Header: Profile picture and username
    /// Post: Video content
    /// Actions: Set of buttons to interact with the post
    /// Comments
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = feedPosts[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostTableViewCell.identifier, for: indexPath) as! FeedPostTableViewCell
        cell.configure(post: model)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (view.height * 3 / 4)
    }
}

extension NewFeedViewController: FeedPostTableViewCellDelegate {
    func didTapLikesLabel(_ feedHeaderCell: FeedPostTableViewCell, post: NewFeedPost) {
        var data: [[String: String]] = []
        for like in post.post.likeCount {
            let newElement = ["email": like.email]
            data.append(newElement)
        }
        
        let vc = ListsViewController(data: data)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapUsername(_ feedTableViewCell: FeedPostTableViewCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapCommentButton(email: String, post: UserPost) {
        let newCommentVC = NewCommentViewController(email: email, post: post)
        newCommentVC.title = "Add Comment"
        navigationController?.pushViewController(newCommentVC, animated: true)
    }
    
    func didTapLikeButton() {
        print("Tapped Like")
    }
    
    func didTapSendButton(otherUserEmail: String, id: String?) {
        print("Tapped Send")
        if let id = id {
            let vc = ChatViewController(with: otherUserEmail, id: id)
            vc.isNewConversation = false
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = ChatViewController(with: otherUserEmail, id: nil)
            vc.isNewConversation = true
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
