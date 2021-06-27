//
//  NotificationViewController.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/24/20.
//

import UIKit
import NotificationBannerSwift

enum UserNotificationType {
    case like(post: UserPost)
    case follow(state: FollowState)
}

public struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: RHUser
    let date: Date
}

class NotificationViewController: UIViewController {
 
    private let noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.isHidden = true
        tableView.register(NotificationLikeEventTableViewCell.self, forCellReuseIdentifier: NotificationLikeEventTableViewCell.identifier)
        tableView.register(NotificationFollowEventTableViewCell.self, forCellReuseIdentifier: NotificationFollowEventTableViewCell.identifier)
        return tableView
    }()

    private var models = [UserNotification]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch User Notifications
        fetchNotifications()
        
        // Configure the ViewController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .secondarySystemBackground
        title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noNotificationsLabel)
        
        // Add Delegate and DataSource
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    /*  layoutSubviews()
        Override layoutSubviews() to organize all subviews on the viewController.
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNotificationsLabel.frame = view.bounds
    }
    
    // MARK: - Fetch Notifications
    
    private func fetchNotifications() {
        print("Get Notificiations")
        guard let user = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.getUserNotifications(user: user, completion: { [weak self] notifications in
            guard let notifications = notifications else {
                self?.hideShowNotificationLabel(showLabel: false)
                print("Failed to get Notifications")
                return
            }
            
            self?.hideShowNotificationLabel(showLabel: true)
            
            let model = notifications[0]
            if model.date >= Date().addingTimeInterval(TimeInterval(-10)) {
                let banner = NotificationBanner(title: "\(model.text)", subtitle: nil, leftView: nil, rightView: nil, style: .info, colors: nil)
                
                banner.dismissOnTap = true
                banner.show()
            }
            
            DispatchQueue.main.async {
                self?.models = notifications
                self?.tableView.reloadData()
            }
            
        })
    }
    
    // Hide/Show No Notification Label
    private func hideShowNotificationLabel(showLabel: Bool) {
        if showLabel == true {
                noNotificationsLabel.isHidden = true
                tableView.isHidden = false
        }
        else {
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
}

    // MARK: - TableView Delegate and DataSource

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type {
        case .like(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationLikeEventTableViewCell.identifier, for: indexPath) as! NotificationLikeEventTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        case .follow:
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationFollowEventTableViewCell.identifier, for: indexPath) as! NotificationFollowEventTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}

    // MARK: - Like Notification Cell Delegate

extension NotificationViewController: NotificationLikeEventTableViewCellDelegate {
    func didTapRelatedPostButton(model: UserNotification) {
        
        switch model.type {
        case .like(let post):
            DatabaseManager.shared.getUserPost(with: post.owner.safeEmail, url: post.postURL.absoluteString, completion: { [weak self] post in
                
                guard let post = post else {
                    print("Post is bad")
                    return
                }
                let vc = ViewPostViewController(post: post, user: post.owner, postNumber: post.identifier)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            break
        case .follow(_):
            fatalError("Dev Issue: Should never get called")
        }
    }
    
    func didTapProfilePic(model: UserNotification) {
        switch model.type {
        case .like(_):
            let vc = OtherUserViewController(user: model.user)
            navigationController?.pushViewController(vc, animated: true)
            break
        case .follow(_):
            let vc = OtherUserViewController(user: model.user)
            navigationController?.pushViewController(vc, animated: true)
            break
        }
    }
}

// MARK: - Follow Notification Cell Delegate

extension NotificationViewController: NotificationFollowEventTableViewCellDelegate {
    func didTapFollowUnfollowButton(model: UserNotification) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.follow(email: model.user.safeEmail, followerEmail: email.safeDatabaseKey(), completion: {})
    }
    
   
}

