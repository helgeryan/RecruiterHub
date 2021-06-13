//
//  ReferenceTableViewCell.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/11/21.
//

import UIKit

class ReferenceTableViewCell: UITableViewCell {

    static let identifier = "ReferenceTableViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Last"
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "123-456-7890"
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email@gmail.com"
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        addSubview(nameLabel)
        addSubview(phoneLabel)
        addSubview(emailLabel)
        addSubview(infoLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 10, y: contentView.top + 10, width: width - 10, height: 20)
        phoneLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 5, width: width - 10, height: 20)
        emailLabel.frame = CGRect(x: 10, y: phoneLabel.bottom + 5, width: width - 10, height: 20)
        infoLabel.frame = CGRect(x: 10, y: emailLabel.bottom + 5, width: width - 10, height: 20)
    }
    
    public func configure(reference: Reference) {
        nameLabel.text = reference.name
        phoneLabel.text = reference.phone
        emailLabel.text = reference.emailAddress
        
        DatabaseManager.shared.userExists(with: reference.safeEmail.lowercased(), completion: {
            [weak self] exists in
            var text = ""
            if exists {
                text = "Tap to view profile"
            }
            else {
                text = "Not a user"
            }
            
            DispatchQueue.main.async {
                self?.infoLabel.text = text
            }
        })
    }
}

public struct Reference {
    var emailAddress: String
    var phone: String
    var name: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
