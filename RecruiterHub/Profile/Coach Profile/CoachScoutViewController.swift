//
//  CoachScoutViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/9/21.
//

import UIKit

class CoachScoutViewController: UIViewController {

    private let user: RHUser
    
    
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
    
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        addSubviews()
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String, email == user.safeEmail else {
            return
        }
        
        let barButtonItem = UIBarButtonItem(title: "Prospects", style: .done, target: self, action: #selector(didTapProspects))
        navigationItem.rightBarButtonItem = barButtonItem
        
    }
    
    private func addSubviews() {
        view.addSubview(profilePhotoImageView)
        view.addSubview(nameLabel)
        view.addSubview(titleLabel)
        view.addSubview(organizationLabel)
    }
    
    private func configure() {

        nameLabel.text = user.firstName + " " + user.lastName
        titleLabel.text = user.title
        organizationLabel.text = user.school
        
        if let url = URL(string: user.profilePicUrl) {
            profilePhotoImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let profilePhotoSize = view.width/3
        profilePhotoImageView.frame = CGRect(x: profilePhotoSize,
                                             y: view.safeAreaInsets.top + 5,
                                             width: profilePhotoSize,
                                             height: profilePhotoSize).integral
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.width / 4.0
        
        nameLabel.frame = CGRect(x: 10,
                                 y: profilePhotoImageView.bottom + 5,
                                 width: view.width - 20 ,
                                 height: 20)
        organizationLabel.frame = CGRect(x: 10,
                                             y: nameLabel.bottom + 5,
                                             width: view.width - 20,
                                             height: 20)
        titleLabel.frame = CGRect(x: 10,
                                             y: organizationLabel.bottom + 5,
                                             width: view.width - 20,
                                             height: 20)
        
    }
    
    @objc private func didTapProspects() {
        let vc = CoachProspectsViewController(user: user)
        vc.title = "Prospects"
        navigationController?.pushViewController(vc, animated: true)
    }
}
