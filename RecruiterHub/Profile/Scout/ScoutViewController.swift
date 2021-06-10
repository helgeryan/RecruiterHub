//
//  ScoutViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/4/21.
//

import UIKit

class ScoutViewController: UIViewController {

    private let user: RHUser
    
    private var scoutInfo: ScoutInfo = ScoutInfo()
    
    private var collectionView: UICollectionView
    
    init(user: RHUser) {
        self.user = user
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(ScoutInfoCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ScoutInfoCollectionReusableView.identifier)
        
        collectionView.register(ScoutCollectionViewCell.self, forCellWithReuseIdentifier: ScoutCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        if user.safeEmail == UserDefaults.standard.value(forKey: "email") as? String {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc private func didTapEditButton() {
        
        DatabaseManager.shared.getScoutInfoForUser(user: user.safeEmail, completion: { [weak self]
            scoutInfo in
            
            guard let scoutInfo = scoutInfo else {
                let vc = EditScoutInfoViewController(scoutInfo: ScoutInfo())
                
                self?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            print(scoutInfo)
            let vc = EditScoutInfoViewController(scoutInfo: scoutInfo)
            
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension ScoutViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: ScoutInfoCollectionReusableView.getHeight())
    }
}

extension ScoutViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ScoutInfoCollectionReusableView.identifier, for: indexPath) as! ScoutInfoCollectionReusableView
        header.delegate = self
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: user.safeEmail, completion: {
            result in
            guard let result = result else {
                return
            }
            
            header.configure(user: result, hideFollowButton: true)
        })

        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScoutCollectionViewCell.identifier, for: indexPath) as! ScoutCollectionViewCell
        
        
        switch indexPath.row {
        case 0:
            cell.configure(email: user.safeEmail, attribute: .fastball)
            break
        case 1:
            cell.configure(email: user.safeEmail, attribute: .curveball)
            break
        case 2:
            cell.configure(email: user.safeEmail, attribute: .slider)
            break
        case 3:
            cell.configure(email: user.safeEmail, attribute: .changeup)
            break
        case 4:
            cell.configure(email: user.safeEmail, attribute: .sixty)
            break
        case 5:
            cell.configure(email: user.safeEmail, attribute: .infield)
            break
        case 6:
            cell.configure(email: user.safeEmail, attribute: .outfield)
            break
        case 7:
            cell.configure(email: user.safeEmail, attribute: .exitVelo)
            break
        default:
            print("Default")
        }
        return cell
    }
}

extension ScoutViewController: ScoutInfoDelegate {
    func didTapGameLog(_ header: ScoutInfoCollectionReusableView) {
        let vc = GameLogViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}
