//
//  CoachScoutViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/9/21.
//

import UIKit

class CoachScoutViewController: UIViewController {

    private let user: RHUser
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let barButtonItem = UIBarButtonItem(title: "Prospects", style: .done, target: self, action: #selector(didTapProspects))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func didTapProspects() {
        let vc = CoachProspectsViewController(user: user)
        vc.title = "Prospects"
        navigationController?.pushViewController(vc, animated: true)
    }
}
