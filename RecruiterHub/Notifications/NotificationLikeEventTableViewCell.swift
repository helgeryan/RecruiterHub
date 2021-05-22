//
//  NotificationLikeEventTableViewCell.swift
//  Instagram
//
//  Created by Ryan Helgeson on 1/9/21.
//
import SDWebImage
import UIKit

protocol NotificationLikeEventTableViewCellDelegate: AnyObject {
    func didTapRelatedPostButton(model: UserNotification)
    func didTapProfilePic(model: UserNotification)
}

class NotificationLikeEventTableViewCell: UITableViewCell {
    static let identifier = "NotificationLikeEventTableViewCell"
    
    weak var delegate: NotificationLikeEventTableViewCellDelegate?
    
    private var model: UserNotification?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "@joe liked your photo"
        return label
    }()
    
    private let postButton: UIImageView = {
        let button = UIImageView()
        button.isUserInteractionEnabled = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        contentView.addSubview(postButton)
        
        var gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPostButton))
        postButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        profileImageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapPostButton() {
        guard let model = model else {
            return
        }
        delegate?.didTapRelatedPostButton(model: model)
    }
    
    @objc private func didTapProfilePic() {
        guard let model = model else {
            return
        }
        delegate?.didTapProfilePic(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: UserNotification) {
        self.model = model
        switch model.type {
        case .like(post: let post):
            print("made it here")
            DatabaseManager.shared.getAllUserPosts(with: post.owner.safeEmail, completion: { [weak self] posts in
                
                guard let posts = posts else {
                    return
                }
                let index = DatabaseManager.findPost(posts: posts, url: post.postURL.absoluteString)
                
                let post = posts[index]
                
                guard let thumbnail = post["thumbnail"] as? String,
                      let url = URL(string: thumbnail) else {
                    print("Failed")
                    return
                }
                print("Set image")
                DispatchQueue.main.async {
                    self?.postButton.sd_setImage(with: url, completed: nil)
                }
            })
            break
            
        case .follow:
            break

        }
        
        label.text = model.text
        
        guard let url = URL(string: model.user.profilePicUrl) else {
            return
        }
        
        profileImageView.sd_setImage(with: url, completed: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postButton.sd_setImage(with: nil, completed: nil)
        label.text = nil
        profileImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // photo, text, post button
        profileImageView.frame = CGRect(x: 3, y: 3, width: contentView.height-6, height: contentView.height-6)
        profileImageView.layer.cornerRadius = profileImageView.height/2
     
        let size = contentView.height - 4
        postButton.frame = CGRect(x: contentView.width - 5 - size, y: 2, width: size, height: size)
        
        label.frame = CGRect(x: profileImageView.right+5,
                             y: 0,
                             width: contentView.width-size-profileImageView.width-16,
                             height: contentView.height)
    }
}
