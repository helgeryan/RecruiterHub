//
//  CoachProfileHeaderCollectionReusableView.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/18/21.
//

import UIKit

protocol CoachProfileHeaderDelegate: AnyObject {
    
}

final class CoachProfileHeader: UICollectionReusableView, UINavigationControllerDelegate {
    static let identifier = "CoachProfileHeader"
    
    public weak var delegate: ProfileHeaderDelegate?
    
    public var size = 0
    
    private var user = RHUser()
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.layer.borderWidth = 5
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let organizationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.isHidden = true
        button.setTitleColor( .label, for: .normal)
        button.setTitle("Follow", for: .normal)
        return button
    }()
    
//    private let endorseButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = .link
//        button.isHidden = true
//        button.setTitleColor( .label, for: .normal)
//        button.setTitle("Endorse", for: .normal)
//        return button
//    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        clipsToBounds = true
        backgroundColor = .systemBackground
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
//        endorseButton.addTarget(self, action: #selector(didTapEndorseButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapFollowButton() {
        guard let email =  UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        DatabaseManager.shared.follow(email: user.safeEmail, followerEmail: email.safeDatabaseKey(), completion: {})
    }
    
    @objc private func didTapEndorseButton() {
        guard let email =  UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }

        DatabaseManager.shared.endorse(email: user.safeEmail, endorserEmail: email.safeDatabaseKey(), completion: {})
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(titleLabel)
        addSubview(organizationLabel)
        addSubview(followButton)
//        addSubview(endorseButton)
    }
    
    public func configure(user: RHUser, hideFollowButton: Bool) {
        self.user = user
        if !hideFollowButton {
            followButton.isHidden = false
//            endorseButton.isHidden = false
        }
        
        nameLabel.text = user.firstName + " " + user.lastName
        titleLabel.text = user.title
        organizationLabel.text = user.school
        
        if let url = URL(string: user.profilePicUrl) {
            profilePhotoImageView.sd_setImage(with: url, completed: nil)
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.getUserFollowing(email: email.safeDatabaseKey(), completion: { [weak self]
            result in
            guard let result = result else {
                self?.followButton.setTitle("Follow", for: .normal)
                self?.followButton.backgroundColor = .link
                return
            }
            if result.contains(Following(email: user.safeEmail)) {
                self?.followButton.setTitle("Unfollow", for: .normal)
                self?.followButton.backgroundColor = .lightGray
            }
            else {
                self?.followButton.setTitle("Follow", for: .normal)
                self?.followButton.backgroundColor = .link
            }
        })
        
//        DatabaseManager.shared.getUserEndorsements(email: user.safeEmail, completion: { [weak self]
//            result in
//
//            guard let result = result else {
//                self?.endorseButton.setTitle("Endorse", for: .normal)
//                self?.endorseButton.backgroundColor = .link
//                return
//            }
//            if result.contains(Following(email: email.safeDatabaseKey())) {
//                self?.endorseButton.setTitle("Endorsing..", for: .normal)
//                self?.endorseButton.backgroundColor = .lightGray
//            }
//            else {
//                self?.endorseButton.setTitle("Endorse", for: .normal)
//                self?.endorseButton.backgroundColor = .link
//            }
//
//        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profilePhotoSize = width/3
        profilePhotoImageView.frame = CGRect(x: profilePhotoSize,
                                             y: 5,
                                             width: profilePhotoSize,
                                             height: profilePhotoSize).integral
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.width / 4.0
        
        nameLabel.frame = CGRect(x: 10,
                                 y: profilePhotoImageView.bottom + 5,
                                 width: width - 20 ,
                                 height: 20)
        organizationLabel.frame = CGRect(x: 10,
                                             y: nameLabel.bottom + 5,
                                             width: width - 20,
                                             height: 20)
        titleLabel.frame = CGRect(x: 10,
                                             y: organizationLabel.bottom + 5,
                                             width: width - 20,
                                             height: 20)
        
        followButton.frame = CGRect(origin: CGPoint(x: width / 3, y: titleLabel.bottom + 5), size: CGSize(width: width / 3 , height: 30))
        followButton.layer.cornerRadius = 3.0
        
//        endorseButton.frame = CGRect(x: (width / 2) + 10,
//                                             y: titleLabel.bottom + 5,
//                                             width: width / 2 - 20,
//                                             height: 50)
//        endorseButton.layer.cornerRadius = 3.0
    }
    
    public static func getHeight(isYourProfile: Bool) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        if isYourProfile {
            return screenSize.width / 3 + 85
        }
        return screenSize.width / 3 + 115
    }
}
