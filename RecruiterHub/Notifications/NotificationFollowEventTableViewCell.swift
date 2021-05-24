//
//  NotificationFollowEventTableViewCell.swift
//  Instagram
//
//  Created by Ryan Helgeson on 1/9/21.
//

import UIKit

protocol NotificationFollowEventTableViewCellDelegate: AnyObject {
    func didTapFollowUnfollowButton(model: UserNotification)
    func didTapProfilePic(model: UserNotification)
}

class NotificationFollowEventTableViewCell: UITableViewCell {
    static let identifier = "NotificationFollowEventTableViewCell"
    
    weak var delegate: NotificationFollowEventTableViewCellDelegate?
    
    private var model: UserNotification?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "@kanyeWest started following you."
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        contentView.addSubview(followButton)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        profileImageView.addGestureRecognizer(gesture)
        
        followButton.addTarget(self,
                               action: #selector(didTapFollowButton),
                               for: .touchUpInside)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapFollowButton() {
        guard let model = model else {
            return
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.follow(email: model.user.safeEmail, followerEmail: email.safeDatabaseKey(), completion: {
            
        })
   

    }
    
    @objc private func didTapProfilePic() {
        guard let model = model else {
            return
        }
        delegate?.didTapProfilePic(model: model)
    }
    
    public func configure(with model: UserNotification) {
        self.model = model
        switch model.type {
        case .like(_):
            break
        case .follow(_):
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            
            DatabaseManager.shared.getUserFollowing(email: email, completion: { [weak self] following in
                
                guard let following = following else {
                    self?.followButton.setTitle("Follow", for: .normal)
                    self?.followButton.setTitleColor(.white, for: .normal)
                    self?.followButton.layer.borderWidth = 0
                    self?.followButton.backgroundColor = .link
                    return
                }
                if following.contains(["email": model.user.safeEmail]) {
                    self?.configureForUnfollow()
                }
                else {
                    self?.followButton.setTitle("Follow", for: .normal)
                    self?.followButton.setTitleColor(.white, for: .normal)
                    self?.followButton.layer.borderWidth = 0
                    self?.followButton.backgroundColor = .link
                }
            })
        }
        
        label.text = model.text
        
        guard let url = URL(string: model.user.profilePicUrl) else {
            return
        }
        
        profileImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func configureForUnfollow() {
        followButton.setTitle("Unfollow", for: .normal)
        followButton.setTitleColor(.label, for: .normal)
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        followButton.backgroundColor = .lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
        followButton.layer.borderWidth = 0
        label.text = nil
        profileImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // photo, text, post button
        profileImageView.frame = CGRect(x: 3,
                                        y: 3,
                                        width: contentView.height-6,
                                        height: contentView.height-6)
        profileImageView.layer.cornerRadius = profileImageView.height/2
     
        let size: CGFloat = 100
        let buttonHeight: CGFloat = 40
        followButton.frame = CGRect(x: contentView.width - 5 - size,
                                    y: (contentView.height - 44) / 2,
                                    width: size,
                                    height: buttonHeight)
        
        label.frame = CGRect(x: profileImageView.right+5,
                             y: 0,
                             width: contentView.width-size-profileImageView.width-16,
                             height: contentView.height)
    }
}
