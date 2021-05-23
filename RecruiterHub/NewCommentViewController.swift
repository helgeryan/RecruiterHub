//
//  NewCommentViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/28/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class NewCommentViewController: UIViewController {

    private let email: String
    
    private let url: String
    
    private var comments: [PostComment]?
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "New Comment..."
        textView.textColor = .lightGray
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.label.cgColor
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.returnKeyType = .default
        return textView
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.register(CommentsCell.self, forCellReuseIdentifier: CommentsCell.identifier)
        return table
    }()
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Init
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    init(email: String, url: String) {
        self.email = email
        self.url = url
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// View did load
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    override func viewDidLoad() {
        super.viewDidLoad()

        let uiToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        uiToolBar.items = [flexibleSpace, doneButton]
        uiToolBar.sizeToFit()
        textView.inputAccessoryView = uiToolBar
        
        fetchComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        self.tabBarController?.tabBar.isHidden = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapgesture)
        view.addSubview(tableView)
        view.addSubview(textView)
        tableView.delegate = self
        tableView.dataSource = self
        textView.delegate = self
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Handle Generic tap on the screen
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @objc private func didTap() {
        textView.resignFirstResponder()
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Layout the subviews on the view controller
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y:  view.safeAreaInsets.top , width: view.width , height: view.height - 100)
        textView.frame = CGRect( x: 10, y: view.bottom - 100, width: view.width - 20 , height: 100)
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function that occurs when the keyboard will show
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @objc private func keyboardWillShow(notification: NSNotification) {
        Keyboard.keyboardWillShow(vc: self, notification: notification)
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function that occurs when the keyboard will show
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @objc private func keyboardWillHide(notification: NSNotification) {
        Keyboard.keyboardWillHide(vc: self)
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Fetch the Comments for a post
    /// Steps
    /// - Get all user posts
    /// - Find index of the post url
    /// - Get Comments
    /// - Reload table data
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    private func fetchComments() {
        
        guard let email = email as String? else {
            return
        }
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self]
            posts in
            guard let posts = posts else {
                return
            }
            
            guard let postUrl = self?.url as String? else {
                return
            }
            
            let index = DatabaseManager.findPost(posts: posts, url: postUrl)
            if index >= posts.count {
                return
            }
            
            DatabaseManager.shared.getComments(with: email, index: index, completion: { [weak self] comments in
                guard let comments = comments else {
                    return
                }
                
                self?.comments = comments
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        })
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Occurs when view will disappear
    /// Unhide the tabbar
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Handle for when the keyboard done button is tapped.
    ///
    /// Steps:
    /// - Grab comment from text view
    /// - Create new comment to be uploaded to Firebase
    /// - Update the comments
    /// - Reload the table data
    /// - Get all user posts
    /// - Find post index
    /// - Upload the new comments array
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    @objc private func didTapDone() {
        textView.resignFirstResponder()
        
        guard let newComment = textView.text else {
            return
        }
        
        guard let email = email as String?,
              let url = url as String? else {
            return
        }
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let newElement = PostComment(identifier: 0, email: currentEmail, text: newComment, createdDate: Date(), likes: [])
        
        comments?.append(newElement)
        
        tableView.reloadData()
        
        textView.text = "New Comment..."
        textView.textColor = .lightGray
        
        DatabaseManager.shared.getAllUserPosts(with: email, completion: { posts in
            guard let posts = posts else {
                return
            }
            
            let index = DatabaseManager.findPost(posts: posts, url: url)
            if index >= posts.count {
                return
            }
            
            DatabaseManager.shared.newComment(email: email, commenterEmail: currentEmail, comment: newComment, index: index )
        })
    }
}

extension NewCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = comments else {
            return 0
        }
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comments = comments else {
            return UITableViewCell()
        }
        
        let model = comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.identifier, for: indexPath) as! CommentsCell
        
        cell.configure(email: model.email, comment: model.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let comments = comments else {
            return 20
        }
        
        let model = comments[indexPath.row]
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.width - 20 , height: 10))
        label.text = model.text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.height + 10
    }
}

extension NewCommentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "New Comment..."
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
}


