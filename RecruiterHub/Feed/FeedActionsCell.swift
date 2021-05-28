//
//  FeedActionsCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/3/21.
//

import UIKit

protocol FeedActionsCellDelegate: AnyObject {
    func didTapLikeButton()
    func didTapCommentButton(email: String, url: String)
    func didTapSendButton(otherUserEmail: String, id: String?)
}

class FeedActionsCell: UITableViewCell {
   
    weak var delegate: FeedActionsCellDelegate?
    
    static let identifier = "FeedActionsCell"
    
    private var url: String?
    
    private var post: UserPost?
    
    private var email: String?
    
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

    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(sendButton)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapLikeButton() {
        guard let email = email else {
            return
        }
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUsername = UserDefaults.standard.value(forKey: "username") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String,
              let post = post
        else {
            print("Failed to get User Defaults")
            return
        }
        
        // Create Post Like
        let postLike = PostLike(username: currentUsername, email: currentEmail.safeDatabaseKey(), name: currentName)
        
        DatabaseManager.shared.like(with: email, likerInfo: postLike, post: post, completion: {
        })
        
        delegate?.didTapLikeButton()
    }
    
    @objc private func didTapCommentButton() {
        
        guard let email = email else {
            return
        }
        
        guard let url = url else {
            return
        }
        
        delegate?.didTapCommentButton(email: email, url: url)
    }
    
    @objc private func didTapSendButton() {
        
        guard let otherUserEmail = email else {
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
                    DatabaseManager.shared.getDataForUser(user: otherUserEmail.safeDatabaseKey(), completion: { [weak self]
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
                    DatabaseManager.shared.getDataForUser(user: otherUserEmail.safeDatabaseKey(), completion: { [weak self]
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
    
    public func configure( with urlString: String, email: String) {
        // Configure the cell
        url = urlString
        self.email = email
        
        DatabaseManager.shared.getUserPost(with: email, url: urlString, completion: {
            [weak self] post in
            guard let post = post else {
                return
            }
            self?.post = post

            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
            else {
                print("Failed to get User Defaults")
                return
            }
            
            DatabaseManager.shared.getLikes(with: email, index: post.identifier, completion: {
                [weak self] likes in
                guard let likes = likes else {
                    self?.defaultButton()
                    return
                }
                for like in likes {
                    if like["email"] == currentEmail {
                        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
                        let image = UIImage(systemName: "heart.fill", withConfiguration: config)
                        self?.likeButton.setImage(image, for: .normal)
                        self?.likeButton.tintColor = .red
                        return
                    }
                }
                
                self?.defaultButton()
            })
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // like comment send
        let buttonSize = contentView.height-10
        
        let buttons =  [likeButton, commentButton, sendButton]
        
        for x in 0..<buttons.count {
            let button = buttons[x]
            button.frame = CGRect(x: (CGFloat(x) * buttonSize) + (10*CGFloat(x+1)),
                                  y: 5,
                                  width: buttonSize,
                                  height: buttonSize)
        }
    }

    private func defaultButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        self.likeButton.setImage(image, for: .normal)
        self.likeButton.tintColor = .label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultButton()
    }
}
