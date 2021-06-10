//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/29/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        
        usernameLabel.frame = CGRect(x: userImageView.right, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20) / 2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: usernameLabel.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20) / 2)
    }
    
    public func configure( with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        usernameLabel.text = model.name
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: model.otherUserEmail.safeDatabaseKey(), completion: { [weak self] user in
            
            guard let user = user else {
                return
            }
            
            let url = URL(string: user.profilePicUrl)
            self?.userImageView.sd_setImage(with: url, completed: nil)
        })
    }
}

public struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
    
}

public struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
