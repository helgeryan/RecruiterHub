//
//  ReferencesViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/11/21.
//

import UIKit

class ReferencesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private let referenecsTableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.register(PitcherGameLogTableViewCell.self, forCellReuseIdentifier: PitcherGameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        return table
    }()
}
