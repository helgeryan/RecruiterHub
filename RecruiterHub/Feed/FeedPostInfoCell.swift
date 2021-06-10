//
//  FeedPostInfoCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/3/21.
//

import UIKit

class FeedPostInfoCell: UITableViewCell {
    static let identifier = "FeedPostInfoCell"
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = 150
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
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
    
    public func configure(email: String, url: String) {
        // Configure the cell
        
        DatabaseManager.shared.getUserPost(with: email, url: url, completion: { [weak self]
            post in
            guard let post = post else {
                return
            }
            
            DatabaseManager.shared.getComments(with: email, index: post.identifier, completion: { comments in
                if let comments = comments {
                    
                    DatabaseManager.shared.getDataForUserSingleEvent(user: email, completion: {
                        user in
                        
                        guard let user = user else {
                            return
                        }
                        
                        guard var boldText = user.username as String? else {
                            return
                        }
                        
                        boldText = boldText + " "
                        let fontSize = 14.0
                        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: CGFloat(fontSize)), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
                        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
                        
                        let attrsnormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: CGFloat(fontSize))]
                        let normalString = NSMutableAttributedString(string:comments[0].text, attributes: attrsnormal)
                        
                        attributedString.append(normalString)
                        self?.commentLabel.attributedText = attributedString
                    })
                }
            })
        })
//
//        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
//            posts in
//            guard let posts = posts else {
//                return
//            }
//
//            var index = 0
//            for post in posts {
//                guard let postUrl = post["url"] as? String else {
//                    return
//                }
//
//                if postUrl == url {
//                    print("Found url")
//                    break
//                }
//                else {
//                    index += 1
//                }
//            }
//
//        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.frame = CGRect(x: 10 , y: 0, width: contentView.width - 20 , height: 50)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.attributedText = NSMutableAttributedString(string: "")
    }
}
