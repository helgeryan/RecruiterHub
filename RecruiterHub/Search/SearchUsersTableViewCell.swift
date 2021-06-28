//
//  SearchUsersTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/25/21.
//

import UIKit

class SearchUsersTableViewCell: UITableViewCell {

    static let identifier = "SearchUsersTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = ""
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = ""
        return label
    }()
    
    private let schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = ""
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add Subviews
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(schoolLabel)
        addSubview(profileImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 2
        let leftPadding: CGFloat = 5
        let labelHeight: CGFloat = 20
        nameLabel.frame = CGRect(x: leftPadding,
                                 y: 5,
                                 width: width * 2 / 3,
                                 height: labelHeight)
        usernameLabel.frame = CGRect(x: leftPadding,
                                     y: nameLabel.bottom + padding,
                                     width: width/2, height:
                                        labelHeight)
        schoolLabel.frame = CGRect(x: leftPadding,
                                   y: usernameLabel.bottom + padding,
                                   width: width/2,
                                   height: labelHeight)
        schoolLabel.frame = CGRect(x: leftPadding,
                                   y: usernameLabel.bottom + padding,
                                   width: width/2,
                                   height: labelHeight)
        
        let imageViewDim = contentView.height - (leftPadding * 2)
        profileImageView.frame = CGRect(x: contentView.width - contentView.height - leftPadding,
                                   y: 5,
                                   width: imageViewDim,
                                   height: imageViewDim)
        profileImageView.layer.cornerRadius = profileImageView.width / 2
    }
    
    public func configure(user: RHUser) {
        if user.profileType == "player" {
            nameLabel.text = "\(user.name) - \(user.gradYear) - \(user.positions)"
        }
        else {
            nameLabel.text = "\(user.name) - \(user.title)"
        }
        usernameLabel.text = user.username
        schoolLabel.text = user.highSchool
        
        guard let profilePicUrl = URL(string: user.profilePicUrl) else {
            return
        }
        
        profileImageView.sd_setImage(with: profilePicUrl, completed: nil)
    }
    
}
