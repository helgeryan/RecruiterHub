//
//  CommentsCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/28/21.
//

import UIKit

class CommentsCell: UITableViewCell {
    static let identifier = "CommentsCell"
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 150
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .natural
        return label
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(commentLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String, comment: String) {
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: email, completion: { [weak self]
            user in
            
            guard let user = user else {
                return
            }
            
            guard var boldText = user.username as String? else {
                return
            }
            
            guard let normalText = comment as String? else {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.frame = CGRect(x: 10 , y: 10, width: contentView.width - 20 , height: 20)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = ""
    }
    
    public func getHeight() -> CGFloat {
        return 50
    }
}

