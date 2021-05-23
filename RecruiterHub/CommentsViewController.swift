//
//  CommentsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/27/21.
//

import UIKit

class CommentsViewController: UIViewController {

    private var comments: [PostComment]?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.register(CommentsCell.self, forCellReuseIdentifier: CommentsCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    init(email: String, url: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String, url: String) {
        DatabaseManager.shared.getUserPost(with: email, url: url, completion: { [weak self]
            post in
            guard let post = post else {
                return
            }

            DatabaseManager.shared.getComments(with: email, index: post.identifier, completion: {
                [weak self] comments in
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
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = comments,
              comments.count != 0 else {
            return 0
        }
        print(comments.count)
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCell.identifier, for: indexPath) as! CommentsCell

        guard let comments = comments else {
            return UITableViewCell()
        }
        let model = comments[indexPath.row]
        
        cell.configure(email: model.email, comment: model.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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

