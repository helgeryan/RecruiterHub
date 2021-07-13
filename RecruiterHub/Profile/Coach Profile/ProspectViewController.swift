//
//  ProspectViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/12/21.
//

import UIKit

class ProspectViewController: UIViewController {

    private let prospect: Prospect
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        nameLabel.text = prospect.name
        view.addSubview(nameLabel)
        // Do any additional setup after loading the view.
    }
    
    init(prospect: Prospect) {
        self.prospect = prospect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameLabel.frame = CGRect(x: 10, y: 10, width: view.width - 20, height: 20)
    }
}
