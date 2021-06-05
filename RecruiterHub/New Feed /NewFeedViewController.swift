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
        
        tableView.register(FeedPostTableViewCell.self, forCellReuseIdentifier: FeedPostTableViewCell.identifier)
        
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = view.height - 50
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
        DatabaseManager.shared.getUserFollowingSingleEvent(email: email, completion: { [weak self] following in
            guard let following = following else {
                return
            }
            
            for follow in following {
                DatabaseManager.shared.getAllUserPostsSingleEvent(with: follow.email, completion: { [weak self] posts in
                    
                    guard let posts = posts else {
                        print("No Posts")
                        return
                    }
                    for post in posts {
                        let asset = AVAsset(url: post.postURL)
                        let playerItem = AVPlayerItem(asset: asset)
                        let player = AVPlayer(playerItem: playerItem)
                        let feedPost = NewFeedPost(post: post, player: player)
                        feedPosts.append(feedPost)
                    }
                    followingIndex += 1
                    if followingIndex == following.count {
                        print("Leave")
                        group.leave()
                    }
                })
            }
        })
        group.notify(queue: DispatchQueue.main, execute: {
            print("Ended Grab")
            self.feedPosts = feedPosts.sorted(by: {  $0.post.createdDate.compare($1.post.createdDate) == .orderedDescending })
            print(feedPosts.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

extension NewFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(feedPosts.count)
        return feedPosts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        cell.backgroundColor = .systemBackground
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (view.height * 3 / 4)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 6))
        footerView.backgroundColor = .systemBackground
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
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
        navigationController?.pushViewController(vc, animated: false)
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
