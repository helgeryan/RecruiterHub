//
//  CoachScoutViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/9/21.
//

import UIKit

class CoachScoutViewController: UIViewController {

    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Test", for: .normal)
        button.addTarget(self, action: #selector(didTapTest), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: 50, height: 50)
    }
    
    @objc private func didTapTest() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print(result)
        }
        vc.modalPresentationStyle = .formSheet
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}
