//
//  GameLogViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/26/21.
//

import UIKit

class GameLogViewController: UIViewController {

    private let user: RHUser
    
    private var showPitcherLog = true
    
    private var pitcherGameLogs: [PitcherGameLog] = []
    
    private var batterGameLogs: [BatterGameLog] = []
    
    private let opponentLabel: UILabel = {
        let label = UILabel()
        label.text = "Opponent"
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.textColor = .label
        return label
    }()
    
    private let pitcherTableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = true
        table.register(PitcherGameLogTableViewCell.self, forCellReuseIdentifier: PitcherGameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        return table
    }()
    
    private let batterTableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = true
        table.register(BatterGameLogTableViewCell.self, forCellReuseIdentifier: BatterGameLogTableViewCell.identifier)
        table.separatorStyle = .singleLine
        table.isHidden = true
        return table
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let headerView: GameLogHeaderView = {
        let view = GameLogHeaderView()
        return view
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
        title = "Game Logs"
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        headerView.delegate = self
        scrollView.addSubview(pitcherTableView)
        pitcherTableView.delegate = self
        pitcherTableView.dataSource = self
        pitcherTableView.reloadData()
        scrollView.addSubview(batterTableView)
        batterTableView.delegate = self
        batterTableView.dataSource = self
        batterTableView.reloadData()
        // Do any additional setup after loading the view.
        
        if user.safeEmail == UserDefaults.standard.value(forKey: "email") as? String {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        }
        else {
            batterTableView.allowsSelection = false
            pitcherTableView.allowsSelection = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        scrollView.contentSize = CGSize(width: view.width + 130, height: view.safeAreaInsets.bottom - view.safeAreaInsets.top)
        headerView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: 50)
        pitcherTableView.frame = CGRect(x: 0, y: headerView.bottom, width: scrollView.contentSize.width, height: scrollView.height - headerView.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseManager.shared.getPitcherGameLogsForUser(user: user.safeEmail, completion: {
            [weak self] gameLogs in
            
            guard let gameLogs = gameLogs else {
                return
            }
            
            DispatchQueue.main.async {
                self?.pitcherGameLogs = gameLogs
                self?.pitcherTableView.reloadData()
            }
        })

        DatabaseManager.shared.getBatterGameLogsForUser(user: user.safeEmail, completion: {
            [weak self] gameLogs in
            
            guard let gameLogs = gameLogs else {
                return
            }
            
            DispatchQueue.main.async {
                self?.batterGameLogs = gameLogs
                self?.batterTableView.reloadData()
            }
        })
    }
    
    @objc private func didTapAddButton() {
        var vc: AddGameLogViewController
        if showPitcherLog {
            vc = AddGameLogViewController(type: .pitching)
        }
        else {
            vc = AddGameLogViewController(type: .batting)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GameLogViewController: UITableViewDelegate, UITableViewDataSource, GameLogHeaderViewDelegate {
    
    func didTapSwitch(_ view: GameLogHeaderView) {
        if pitcherTableView.isHidden == true {
            pitcherTableView.isHidden = false
            batterTableView.isHidden = true
            showPitcherLog = true
            scrollView.contentSize = CGSize(width: self.view.width + 130, height: self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top)
            headerView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: 50)
            pitcherTableView.frame = CGRect(x: 0, y: headerView.bottom, width: scrollView.contentSize.width, height: scrollView.height - headerView.height)
        }
        else {
            pitcherTableView.isHidden = true
            batterTableView.isHidden = false
            showPitcherLog = false
            scrollView.contentSize = CGSize(width: self.view.width + 290, height: self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top)
            headerView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: 50)
            batterTableView.frame = CGRect(x: 0, y: headerView.bottom, width: scrollView.contentSize.width, height: scrollView.height - headerView.bottom)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pitcherTableView {
            return pitcherGameLogs.count + 2
        }
        return batterGameLogs.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == pitcherTableView {
            let cell = pitcherTableView.dequeueReusableCell(withIdentifier: PitcherGameLogTableViewCell.identifier, for: indexPath) as! PitcherGameLogTableViewCell
            
            if indexPath.row == 0 {
                return cell
            }
        
            if indexPath.row == (pitcherGameLogs.count + 1) {
                
                var pitchingTotals = PitcherGameLog()
                for log in pitcherGameLogs {
                    pitchingTotals.inningsPitched = pitchingTotals.inningsPitched + log.inningsPitched
                    pitchingTotals.hits = pitchingTotals.hits + log.hits
                    pitchingTotals.runs = pitchingTotals.runs + log.runs
                    pitchingTotals.earnedRuns = pitchingTotals.earnedRuns + log.earnedRuns
                    pitchingTotals.strikeouts = pitchingTotals.strikeouts + log.strikeouts
                    pitchingTotals.walks = pitchingTotals.walks + log.walks
                }
                cell.configure(game: pitchingTotals)
                cell.dateLabel.text = "Total"
                cell.opponentLabel.text = ""
                
                return cell
            }
            
            let model = pitcherGameLogs[indexPath.row - 1]
            
            cell.configure(game: model)
            return cell
        }
        else {
            let cell = batterTableView.dequeueReusableCell(withIdentifier: BatterGameLogTableViewCell.identifier, for: indexPath) as! BatterGameLogTableViewCell
            
            if indexPath.row == 0 {
                return cell
            }
            
            if indexPath.row == (batterGameLogs.count + 1) {
                
                var battingTotals = BatterGameLog()
                for log in batterGameLogs {
                    battingTotals.atBats = battingTotals.atBats + log.atBats
                    battingTotals.hits = battingTotals.hits + log.hits
                    battingTotals.runs = battingTotals.runs + log.runs
                    battingTotals.rbis = battingTotals.rbis + log.rbis
                    battingTotals.doubles = battingTotals.doubles + log.doubles
                    battingTotals.triples = battingTotals.triples + log.triples
                    battingTotals.homeRuns = battingTotals.homeRuns + log.homeRuns
                    battingTotals.strikeouts = battingTotals.strikeouts + log.strikeouts
                    battingTotals.walks = battingTotals.walks + log.walks
                    battingTotals.stolenBases = battingTotals.stolenBases + log.stolenBases
                }
                cell.configure(game: battingTotals)
                cell.dateLabel.text = "Total"
                cell.opponentLabel.text = ""
                
                return cell
            }
            
            let model = batterGameLogs[indexPath.row - 1]
            
            cell.configure(game: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return
        }
        let alert = UIAlertController(title: "Do you want to delete game log?", message: "Yes or No?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            if tableView == self?.pitcherTableView {
                //begin delete
                
                tableView.beginUpdates()
                self?.pitcherGameLogs.remove(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .left)
                
                DatabaseManager.shared.deletePitcherGameLog(index: indexPath.row - 1, completion: {
                    success in
                    if !success {
                        print("Failed to delete")
                    }
                })
                
                tableView.endUpdates()
                
                tableView.reloadData()
            }
            if tableView == self?.batterTableView {
                //begin delete
                tableView.beginUpdates()
                self?.batterGameLogs.remove(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .left)
                
                DatabaseManager.shared.deleteBatterGameLog( index: indexPath.row - 1, completion: {
                    success in
                    if !success {
                        print("Failed to delete")
                    }
                })
                
                tableView.endUpdates()
                
                tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
}
