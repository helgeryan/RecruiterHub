//
//  ViewPostViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/22/21.
//

import UIKit
import AVKit
import AVFoundation

class ViewPostViewController: UIViewController {

    private var post: UserPost
    private let user: RHUser
    private let postNumber: Int
    
    private var comments: [PostComment]?
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.isScrollEnabled = true 
        return scroll
    }()
    
    // Like button
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    // Comment button
    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "message", withConfiguration: config)
        button.tintColor = .label
        button.setImage(image, for: .normal)
        return button
    }()
    
    // Likes label
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.numberOfLines = 1
        return label
    }()
    
    // Likes label
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.numberOfLines = 1
        return label
    }()
    
    // Likes label
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    // Player
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    // Occurs then the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        //
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.backward.and.arrow.down.forward"), style: .plain, target: self, action: #selector(zoom))
        NotificationCenter.default.addObserver(self, selector: #selector(replay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        // Add like button function call
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
        let asset = AVAsset(url: post.postURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayer Layer Configuration
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Add subviews and layers
        view.addSubview(scrollView)
        scrollView.layer.addSublayer(playerLayer)
        scrollView.addSubview(likeButton)
        scrollView.addSubview(commentButton)
        scrollView.addSubview(likesLabel)
        scrollView.addSubview(commentLabel)
        scrollView.addSubview(captionLabel)
        
        // Configure Caption
        captionLabel.preferredMaxLayoutWidth = view.width - 20
        if let caption = post.caption {
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
            let attributedString = NSMutableAttributedString(string: "\(post.owner.username) ", attributes:attrs)
            
            let attrsnormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)]
            let normalString = NSMutableAttributedString(string: caption, attributes: attrsnormal)
            
            attributedString.append(normalString)
            
            captionLabel.attributedText = attributedString
        }
        else {
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
            let attributedString = NSMutableAttributedString(string: "\(post.owner.username)", attributes:attrs)
            captionLabel.attributedText = attributedString
        }
        captionLabel.sizeToFit()
        
        // Configure likes label
        likesLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikesLabel))
        likesLabel.addGestureRecognizer(gesture)
        configureLikesLabel()
        
        commentLabel.text = "\(post.comments.count) comments"
        // Fetch Comments
        fetchComments()
        
        // Listen for updates
        listenForUpdates()
        
        // Add player and start playing
        playerLayer.player = player
        player?.play()
    }
    
    // Design layout
    override func viewDidLayoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: view.top, width: view.width, height: view.height)
        // Place player layer
        playerLayer.frame = CGRect(x: 0, y: scrollView.top, width: scrollView.width, height: view.height * 2 / 3)
        
        // Place like button
        likeButton.frame = CGRect(x: 10,
                                  y: scrollView.top + playerLayer.frame.height + 5,
                                  width: 40,
                                  height: 40)
        // Place comment button
        commentButton.frame = CGRect(x: likeButton.right + 10,
                                     y: scrollView.top + playerLayer.frame.height + 5,
                                     width: 40,
                                     height: 40)
        
        // Place likes label
        likesLabel.frame = CGRect(x: 10, y: likeButton.bottom + 10, width: view.width / 2, height: 20)
        likesLabel.sizeToFit()
        commentLabel.frame = CGRect(x: likesLabel.right + 10, y: likeButton.bottom + 10, width: view.width / 2, height: 20)
        commentLabel.sizeToFit()
        
        captionLabel.frame = CGRect(x: 10, y: likesLabel.bottom + 10, width: view.width - 10, height: 50)
        captionLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: view.width, height: captionLabel.bottom - view.top + 10)
//        tableView.frame = CGRect(x: 0, y: likesLabel.bottom + 10, width: view.width , height: view.height - likesLabel.bottom - 10)
    }
    
    /// ViewPostViewController initializer, sets the post, user, and postnumber
    init(post: UserPost, user: RHUser, postNumber: Int) {
        self.post = post
        self.user = user
        self.postNumber = postNumber
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
    }
    
    // Required init function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func listenForUpdates() {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        DatabaseManager.shared.getLikes(with: post.owner.safeEmail, index: post.identifier, completion: {
            [weak self] likes in
            guard let likes = likes else {
                DispatchQueue.main.async {
                    self?.likesLabel.text = "0 likes"
                    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
                    let image = UIImage(systemName: "heart", withConfiguration: config)
                    self?.likeButton.setImage(image, for: .normal)
                    self?.likeButton.tintColor = .label
                }
                return
            }

            DispatchQueue.main.async {
                self?.likesLabel.text = "\(likes.count) likes"
            }

            for like in likes {
                if like.email == currentEmail {
                    DispatchQueue.main.async {
                        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
                        let image = UIImage(systemName: "heart.fill", withConfiguration: config)
                        self?.likeButton.setImage(image, for: .normal)
                        self?.likeButton.tintColor = .red
                        return
                    }
                } // end if
            } // end for

            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            self?.likeButton.setImage(image, for: .normal)
            self?.likeButton.tintColor = .label
        })
    }
    
    private func fetchComments() {
        
        guard let email = user.safeEmail as String? else {
            return
        }
 
        DatabaseManager.shared.getComments(with: email, index: post.identifier, completion: { [weak self] comments in
            
            guard let comments = comments else {
                return
            }
            
            self?.comments = comments
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
        })
    }
    
    // Function that is called when the like button is tapped
    @objc private func didTapLike() {
        print("Tapped Like")
        
        // Cast the user info to Strings
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        // Create Post Like
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        // Update the like status
        DatabaseManager.shared.like(with: user.emailAddress.safeDatabaseKey(), likerInfo: postLike, post: post, completion: { })
    }
    
    // Function that is called when the like button is tapped
    @objc private func didTapComment() {
        let newCommentVC = NewCommentViewController(email: user.safeEmail, post: post)
        newCommentVC.title = "Add Comment"
        navigationController?.pushViewController(newCommentVC, animated: true)
    }
    
    // Function that is called when the like button is tapped
    @objc private func zoom() {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    // Function that is called when the like button is tapped
    @objc private func replay() {
        if player?.rate == 0 {
            player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
            player?.play()
        }
    }
    
    // Configure the like button
    private func configureLikesLabel() {
        likesLabel.text = "\(post.likeCount.count) likes"
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            print("Failed to get User Defaults")
            return
        }
        
        for like in post.likeCount {
            if like.email == currentEmail {
                let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
                let image = UIImage(systemName: "heart.fill", withConfiguration: config)
                likeButton.setImage(image, for: .normal)
                likeButton.tintColor = .red
                return
            } // end if
        } // end for

        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = .label
    }

    
    // Callback for like label interaction
    @objc private func didTapLikesLabel() {
        var likes: [[String:String]] = []
        for like in post.likeCount {
            let newElement = ["email": like.email]
            likes.append(newElement)
        }
        let vc = ListsViewController(data: likes)
        vc.title = "Likes"
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ViewPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            print("Caption")
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.identifier, for: indexPath) as! CommentsCell
            
            cell.configure(email: post.owner.safeEmail, comment: post.caption ?? "")
            return cell
        }
        
        let model = post.comments[indexPath.row - 1]
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.identifier, for: indexPath) as! CommentsCell
        
        cell.configure(email: model.email, comment: model.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.width - 20 , height: 10))
            label.text = post.caption
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = false
            label.lineBreakMode = .byWordWrapping
            label.sizeToFit()
            return label.height + 10
        }
        
        let model = post.comments[indexPath.row - 1]
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.width - 20 , height: 10))
        label.text = model.text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.height + 10
    }
}

// Structure that holds all information related to a post
struct Post {
    let likes: [PostLike]
    let title: String
    let url: URL
    let number: Int
}

public struct PostLike: Equatable {
    let username: String
    let email: String
    let name: String
}
