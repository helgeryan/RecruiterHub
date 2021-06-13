//
//  ManagePostsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/13/21.
//

import UIKit

class ManagePostsViewController: UIViewController {
    
    private var posts: [UserPost] = []
    
    private var user: RHUser
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (UIScreen.main.bounds.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
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
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        
        
        fetchPosts(email: user.safeEmail)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchPosts(email: String) {

        DatabaseManager.shared.getAllUserPosts(with: email, completion: { [weak self] fetchedPosts in
            guard let fetchedPosts = fetchedPosts else {
                return
            }
            
            self?.posts = fetchedPosts
            self?.collectionView.reloadData()
        })
    }
}

extension ManagePostsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let thumbnailUrl = posts[posts.count - indexPath.row - 1].thumbnailImage
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: thumbnailUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let alert = UIAlertController(title: "Manage Post", message: "What action do you want to take?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
           
            let deleteAlert = UIAlertController(title: "Are you sure you want to delete?", message: "Cannot undo this action!", preferredStyle: .alert)
            
            deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
                guard let posts = self?.posts else {
                    return
                }
                
                DatabaseManager.shared.deletePost(index: posts.count - indexPath.row - 1, completion: {
                    success in
                    if !success {
                        print("Failed to delete")
                    }
                })
            }))
            self?.present(deleteAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
