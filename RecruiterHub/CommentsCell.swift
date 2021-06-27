//
//  CommentsCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/28/21.
//

import UIKit

class CommentsCell: UITableViewCell {
    
    // Identifier for CommentsCell
    static let identifier = "CommentsCell"
    
    // commentLabel
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 150
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .natural
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(commentLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.frame = CGRect(x: 10 , y: 10, width: contentView.width - 20 , height: 20)
        
    }
    
    // Prepare the Cell For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = ""
    }
    
    // MARK: - Configure
    
    /// configure(email: String, comment: String)
    ///
    /// Description: Get the user who made the comment and the comment and append them to a single label.
    ///
    public func configure(email: String, comment: String) {
        
        // Get the User Data
        DatabaseManager.shared.getDataForUserSingleEvent(user: email, completion: { [weak self]
            user in

            // Check to see if we got the user and comment
            guard let user = user,
                  var boldText = user.username as String?,
                  let normalText = comment as String? else {
                return
            }
            
            boldText = boldText + " "
            let fontSize = 14.0
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: CGFloat(fontSize)), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
            let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
            
            let attrsnormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize))]
            let normalString = NSMutableAttributedString(string:normalText, attributes: attrsnormal)
            
            attributedString.append(normalString)
            self?.commentLabel.attributedText = attributedString
            self?.commentLabel.sizeToFit()
        })
    }
}

