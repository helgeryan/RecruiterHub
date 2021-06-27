//
//  FeedPostInfoCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/3/21.
//

import UIKit
import AVKit


protocol FeedPostTableViewCellDelegate: AnyObject {
    func didTapUsername(_ feedHeaderCell: FeedPostTableViewCell, user: RHUser)
    func didTapLikeButton()
    func didTapCommentButton(email: String, post: UserPost)
    func didTapSendButton(otherUserEmail: String, id: String?)
    func didTapLikesLabel(_ feedHeaderCell: FeedPostTableViewCell, post: NewFeedPost)
}


class FeedPostTableViewCell: UITableViewCell {
    static let identifier = "FeedPostTableViewCell"
    
    public weak var delegate: FeedPostTableViewCellDelegate?
    
    private var post: NewFeedPost?
    
    private var playerLayer: AVPlayerLayer = {
        let player = AVPlayerLayer()
        return player
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "message", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "paperplane", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.clipsToBounds = true
        backgroundColor = .systemBackground
        
        var gesture = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(gesture)
        profilePicImageView.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTapLikes))
        likesLabel.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentButton))
        commentsLabel.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(replay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: post?.player?.currentItem)
        
        //3. Create AVPlayerLayer object
        playerLayer.videoGravity = .resizeAspectFill
        
        contentView.addSubview(profilePicImageView)
        contentView.addSubview(usernameLabel)
        contentView.layer.addSublayer(playerLayer)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(sendButton)
        contentView.addSubview(likesLabel)
        contentView.addSubview(commentsLabel)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    @objc private func didTapLikes() {
        guard let post = post else {
            return
        }
        delegate?.didTapLikesLabel(self, post: post)
    }
    
    @objc private func didTapLikeButton() {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String,
              let post = post?.post
        else {
            print("Failed to get User Defaults")
            return
        }
        
        // Create Post Like
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        DatabaseManager.shared.like(with: post.owner.safeEmail, likerInfo: postLike, post: post, completion: {
        })
        
        delegate?.didTapLikeButton()
    }
    
    @objc private func didTapCommentButton() {
        
        guard let post = post else {
            return
        }
        
        delegate?.didTapCommentButton(email: post.post.owner.safeEmail, post: post.post)
    }
    
    @objc private func didTapSendButton() {
        
        guard let otherUserEmail = post?.post.owner.safeEmail else {
            return
        }
        
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
                    self?.delegate?.didTapSendButton(otherUserEmail: otherUserEmail, id: targetConversation.id)
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
        let name = result.name
        let email = result.email

        // Check in the database if the conversation with these two users exists
        // if it does, reuse conversatiionid
        // if not create new
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in

            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.delegate?.didTapSendButton(otherUserEmail: email, id: conversationId)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.delegate?.didTapSendButton(otherUserEmail: email, id: nil)
            }
        })
    }
    
    /*  layoutSubviews()
        Override layoutSubviews() to organize all subviews on the viewController.
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding:CGFloat = 5.0
        profilePicImageView.frame = CGRect(x: 10,
                                           y: padding,
                                           width: 40,
                                           height: 50 -  (padding * 2) )
        profilePicImageView.layer.cornerRadius = profilePicImageView.width / 2
        
        usernameLabel.frame = CGRect(x: profilePicImageView.right + 10,
                                     y: padding,
                                     width: contentView.width - profilePicImageView.right - 20,
                                     height: 50 -  (padding * 2) )
        playerLayer.frame = CGRect(x: 0,
                                   y: profilePicImageView.bottom + 5,
                                   width: contentView.width,
                                   height: contentView.height - profilePicImageView.bottom - 55)

        let buttonSize:CGFloat = contentView.height - playerLayer.bounds.maxY - 50
        
        let buttons =  [likeButton, commentButton, sendButton]
        
        for x in 0..<buttons.count {
            let button = buttons[x]
            let buttonSizes:CGFloat = (CGFloat(x) * buttonSize)
            let buttonPadding: CGFloat = CGFloat((10*(x+1)))
            let buttonX: CGFloat = buttonSizes + buttonPadding
            button.frame = CGRect(x: buttonX,
                                  y: usernameLabel.bottom + playerLayer.frame.height + 5,
                                  width: buttonSize,
                                  height: buttonSize)
        }
        
        likesLabel.frame = CGRect(x: sendButton.right, y: sendButton.top, width: (contentView.width - sendButton.right) / 2, height: sendButton.height)
        
        commentsLabel.frame = CGRect(x: likesLabel.right, y: sendButton.top, width: (contentView.width - sendButton.right) / 2, height: sendButton.height)
        
    }
 
    public func configure(post: NewFeedPost) {
        self.post = post
        
        likesLabel.text = "\(post.post.likeCount.count) likes"
        commentsLabel.text = "\(post.post.comments.count) comments"
        
        var feedLabel: String
        if post.post.owner.profileType == "coach" {
            feedLabel = "\(post.post.owner.username) - \(post.post.owner.highSchool)"
        }
        else {
            feedLabel = "\(post.post.owner.username) - \(post.post.owner.gradYear) - \(post.post.owner.positions)"
        }
        
        DispatchQueue.main.async {
            self.usernameLabel.text = feedLabel
        }
        
        
        if let url = URL(string: post.post.owner.profilePicUrl) {
            self.profilePicImageView.sd_setImage(with: url, completed: nil)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Do any additional setup after loading the view
            post.player?.isMuted = true
            self?.playerLayer.player = post.player
            self?.post?.player?.play()
        }
        
        DatabaseManager.shared.getLikes(with: post.post.owner.safeEmail, index: post.post.identifier, completion: {
            [weak self] likes in
            guard let likes = likes else {
                self?.defaultButton()
                return
            }
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            for like in likes {
                if like.email == currentEmail {
                    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
                    let image = UIImage(systemName: "heart.fill", withConfiguration: config)
                    self?.likeButton.setImage(image, for: .normal)
                    self?.likeButton.tintColor = .red
                    return
                }
            }
            
            self?.defaultButton()
        })
    }
    
    @objc private func replay() {
        if post?.player?.rate == 0 {
            post?.player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
            post?.player?.play()
        }
    }
    
    public func play() {
        post?.player?.play()
    }
    
    public func pause() {
        post?.player?.pause()
    }
    
    @objc private func didTapUsername() {
        print("tapped username")
        
        guard let user = post?.post.owner else {
            return
        }
        
        delegate?.didTapUsername(self, user: user)
    }
    
    private func defaultButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        self.likeButton.setImage(image, for: .normal)
        self.likeButton.tintColor = .label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
        playerLayer.player = nil
    }

    public func getUser() -> RHUser? {
        guard let post = post else {
            return nil
        }
        return post.post.owner
    }

}
