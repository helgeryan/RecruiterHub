//
//  FeedViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/30/21.
//

import UIKit
import AVFoundation

class FeedViewController: UIViewController {

    private var posts: [FeedPost] = []
    
    private let NUMBEROFCELLS = 4
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FeedPostInfoCell.self, forCellReuseIdentifier: FeedPostInfoCell.identifier)
        
        tableView.register(FeedActionsCell.self, forCellReuseIdentifier: FeedActionsCell.identifier)
        
        tableView.register(FeedHeaderCell.self, forCellReuseIdentifier: FeedHeaderCell.identifier)
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)
        
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
        
        DatabaseManager.shared.newGetFeedPosts( completion: { [weak self] feedPosts in
            guard let feedPosts = feedPosts else {
                return
            }
            
            self?.posts = feedPosts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let model = posts[posts.count - (indexPath.row/4) - 1]
        
        if indexPath.row % 4 == 0 {
            DatabaseManager.shared.getDataForUser(user: model.email, completion: {
                [weak self] user in
                guard let user = user else {
                    return
                }
                
                let vc = OtherUserViewController(user: user)
                vc.title = "\(user.firstName) \(user.lastName)"
                self?.navigationController?.pushViewController(vc, animated: true)

            })
        }
        else if indexPath.row % 4 == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
            tableView.deselectRow(at: indexPath, animated: false)
            cell.play()
        }
        
        else if indexPath.row % 4 == 3 {
            tableView.deselectRow(at: indexPath, animated: false)
            let vc = CommentsViewController(email: model.email, url: model.url)
            vc.configure(email: model.email, url: model.url)
            vc.title = "Comments"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count * 4

    }
    
    /// Create cells based off the following:
    /// Header: Profile picture and username
    /// Post: Video content
    /// Actions: Set of buttons to interact with the post
    /// Comments
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = posts[posts.count - (indexPath.row / 4) - 1]

        if indexPath.row % 4 == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedActionsCell.identifier, for: indexPath) as! FeedActionsCell
            cell.configure(with: model.url, email: model.email)
            cell.delegate = self
            return cell
        }
        else if indexPath.row % 4 == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedHeaderCell.identifier, for: indexPath) as! FeedHeaderCell
            let temp = posts[posts.count - (indexPath.row / 4) - 1]
            
            cell.configure( email: temp.email)
            cell.delegate = self

            return cell
        }
        else if indexPath.row % 4 == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedPostInfoCell.identifier, for: indexPath) as! FeedPostInfoCell
            cell.configure(email: model.email, url: model.url)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as! FeedTableViewCell
            
            
            let temp = posts[posts.count - (indexPath.row / 4) - 1]
            cell.configure(url: temp.player)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 4 == 3 {
            return 50
        }
        if indexPath.row % 4 == 2 {
            return 50
        }
        else if indexPath.row % 4 == 0 {
            return 50
        }
        else {
            return view.height * 3.0 / 4.0
        }
    }
}

extension FeedViewController: FeedTableViewCellDelegate {
    func didTapUsername(_ feedTableViewCell: FeedTableViewCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension FeedViewController: FeedHeaderCellDelegate {
    func didTapUsername(_ feedHeaderCell: FeedHeaderCell, user: RHUser) {
        print("TappedUsername")
        let vc = OtherUserViewController(user: user)
        vc.title = "\(user.firstName) \(user.lastName)"
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension FeedViewController: FeedActionsCellDelegate {
    func didTapCommentButton(email: String, url: String) {
        let newCommentVC = NewCommentViewController(email: email, url: url)
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

public struct FeedPost {
    var email: String
    let player: AVPlayer
    let image: String
    let url: String
}
