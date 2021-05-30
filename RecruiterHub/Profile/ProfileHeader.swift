//
//  ProfileHeader.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/14/21.
//
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    
}

final class ProfileHeader: UICollectionReusableView, UINavigationControllerDelegate {
    static let identifier = "ProfileHeader"
    
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
        label.numberOfLines = 1
        return label
    }()
    
    private let positionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let gradLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let handLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        clipsToBounds = true
        backgroundColor = .systemBackground
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
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
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(positionLabel)
        addSubview(gradLabel)
        addSubview(bodyLabel)
        addSubview(handLabel)
        addSubview(followButton)
    }
    
    public func configure(user: RHUser, hideFollowButton: Bool) {
        self.user = user
        if !hideFollowButton {
            followButton.isHidden = false
        }
        
        nameLabel.text = user.firstName + " " + user.lastName
        let gradYear = user.gradYear
        gradLabel.text = "Year: " + String(gradYear)
        
        let heightFeet = user.heightFeet
        let heightInches = user.heightInches
        let weight = user.weight
        let arm = user.arm
        let bats = user.bats
        bodyLabel.text = String(heightFeet) + "'" + String(heightInches) + "  "  + String(weight) + " lbs"
        handLabel.text = "Throws: " + String(arm) + "   Bats: " + String(bats)
        var positions = ""
        var x = 0
        for position in user.positions {
            x += 1
            if user.positions.count == x {
                positions.append(position)
            }
            else {
                positions.append(position + ", ")
            }
            
        }
        positionLabel.text = positions
        if let url = URL(string: user.profilePicUrl) {
            profilePhotoImageView.sd_setImage(with: url, completed: nil)
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if email == user.emailAddress.safeDatabaseKey() {
            followButton.isHidden = true
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
                                 y: profilePhotoImageView.bottom + 10,
                                 width: width - 20 ,
                                 height: 28)
        nameLabel.textAlignment = .center
        positionLabel.frame = CGRect(x: 10,
                                     y: nameLabel.bottom + 5,
                                     width: width - 20,
                                     height: 20)
        positionLabel.textAlignment = .center
        bodyLabel.frame = CGRect(x: 10,
                                 y: positionLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        bodyLabel.textAlignment = .center
        gradLabel.frame = CGRect(x: 10,
                                 y: bodyLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        gradLabel.textAlignment = .center
        
        handLabel.frame = CGRect(x: 10,
                                 y: gradLabel.bottom + 5,
                                 width: width - 20,
                                 height: 20)
        handLabel.textAlignment = .center
        
        followButton.frame = CGRect(x: 20,
                                             y: gradLabel.bottom + 5,
                                             width: width - 40,
                                             height: 50)
        followButton.layer.cornerRadius = 3.0
    }
    
    public static func getHeight(isYourProfile: Bool) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        if isYourProfile {
            return screenSize.width/3 + 160
        }
        return screenSize.width/3 + 175
    }
}
