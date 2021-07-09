//
//  ProfileConnections.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/31/21.
//

import UIKit

protocol ProfileConnectionsDelegate: AnyObject {
    func didTapFollowingButton(_ profileConnections: ProfileConnections)
    func didTapFollowersButton(_ profileConnections: ProfileConnections)
    func didTapEndorsementsButton(_ profileConnections: ProfileConnections)
}

class ProfileConnections: UICollectionReusableView {
    static let identifier = "ProfileConnections"
    
    public weak var delegate: ProfileConnectionsDelegate?
    
    struct Constants {
        static let padding: CGFloat = 8
    }
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.text = "Followers\n"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 5
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.text = "Following\n"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.layer.cornerRadius = 5
        return label
    }()
    
    private let connectionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "References\n"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(followingLabel)
        addSubview(connectionsLabel)
        addSubview(followersLabel)
        
        followersLabel.isUserInteractionEnabled = true
        var gesture = UITapGestureRecognizer(target: self, action: #selector(didTapFollowers))
        followersLabel.addGestureRecognizer(gesture)
        
        
        followingLabel.isUserInteractionEnabled = true
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTapFollowing))
        followingLabel.addGestureRecognizer(gesture)
        
        connectionsLabel.isUserInteractionEnabled = true
        gesture = UITapGestureRecognizer(target: self, action: #selector(didTapEndorsements))
        connectionsLabel.addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = height - 30
        let thirdWidth = width / 3
        let buttonWidth = width / 3 - 20
        followingLabel.frame = CGRect(x: 10,
                                  y: Constants.padding,
                                  width: buttonWidth,
                                    height: size)
        followersLabel.frame = CGRect(x: thirdWidth + 10 ,
                                    y: Constants.padding,
                                    width: buttonWidth,
                                    height: size)
        connectionsLabel.frame = CGRect(x: thirdWidth * 2 + 10,
                                         y: Constants.padding,
                                         width: buttonWidth,
                                         height: size)
        
    }
    
    @objc private func didTapFollowing() {
        delegate?.didTapFollowingButton(self)
    }
    
    @objc private func didTapFollowers() {
        delegate?.didTapFollowersButton(self)
    }
    
    @objc private func didTapEndorsements() {
        delegate?.didTapEndorsementsButton(self)
    }
    
    public func configure(email: String) {
        DatabaseManager.shared.getNumberOf(email: email, connection: .follower, completion: { [weak self] count in
            self?.followersLabel.text = "Followers\n\(count)"
        })
        DatabaseManager.shared.getNumberOf(email: email, connection: .following, completion: { [weak self] count in
            self?.followingLabel.text = "Following\n\(count)"
        })
        DatabaseManager.shared.getNumberOf(email: email, connection: .references, completion: { [weak self] count in
            self?.connectionsLabel.text = "References\n\(count)"
        })
    }
}

