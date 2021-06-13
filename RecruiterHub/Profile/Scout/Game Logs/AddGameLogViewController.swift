//
//  AddGameLogViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/27/21.
//

import UIKit
import NotificationBannerSwift

class AddGameLogViewController: UIViewController {

    private var models = [EditProfileFormModel]()
    
    private let type: GameLog
    
    private var gameLog: PitcherGameLog = PitcherGameLog()
    
    private var batterGameLog = BatterGameLog()
    
    private var data: Data?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()
    
    init(type: GameLog) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    private func configureModels() {
        
        if type == .pitching {
            var model = EditProfileFormModel(label: "Date", placeholder: "DD-MM-YYYY", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Opponent", placeholder: "Opponent", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "IP", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Hits", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Runs", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "ER", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "K", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "BB", placeholder: "0", value: nil)
            models.append(model)
        }
        else {
            var model = EditProfileFormModel(label: "Date", placeholder: "DD-MM-YYYY", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Opponent", placeholder: "Opponent", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "AB", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Hits", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Runs", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "RBI", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "2B", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "3B", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "HR", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "K", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "BB", placeholder: "0", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "SB", placeholder: "0", value: nil)
            models.append(model)
        }
    }
    
    @objc private func didTap() {
        tableView.frame = view.bounds
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Scout Info"
    }
    
    // MARK: -Action
    
    @objc private func didTapSave() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        if type == .pitching {
            DatabaseManager.shared.addGameLogForUser(email: email, gameLog: gameLog)
        }
        else {
            DatabaseManager.shared.addBatterGameLogForUser(email: email, gameLog: batterGameLog)
        }
        
        let banner = NotificationBanner(title: "Successfully updated game log!", subtitle: nil, leftView: nil, rightView: nil, style: .success, colors: nil)
        
        banner.dismissOnTap = true
        banner.show()
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView

extension AddGameLogViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
}

extension AddGameLogViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell) {
        if tableView.top < view.top {
            tableView.frame = view.bounds
            return
        }
        
        if cell.center.y > (view.height / 2) {
            tableView.frame = CGRect(x: tableView.left, y: tableView.top - (view.height / 2), width: tableView.width, height: tableView.height)
        }
    }

    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        
        guard let value = updatedModel.value else {
            return
        }
        if type == .pitching {
            switch updatedModel.label {
            case "Date":
                gameLog.date = value
                break
            case "Opponent":
                gameLog.opponent = value
                break
            case "IP":
                guard let value = Int(value) else {
                    return
                }
                gameLog.inningsPitched = Double(value)
                break
            case "Hits":
                guard let value = Int(value) else {
                    return
                }
                gameLog.hits = Int(value)
                break
            case "R":
                guard let value = Int(value) else {
                    return
                }
                gameLog.runs = Int(value)
                break
            case "ER":
                guard let value = Int(value) else {
                    return
                }
                gameLog.earnedRuns = Int(value)
                break
            case "K":
                guard let value = Int(value) else {
                    return
                }
                gameLog.strikeouts = Int(value)
                break
            case "BB":
                guard let value = Int(value) else {
                    return
                }
                gameLog.walks = Int(value)
                break
            default:
                print("Field doesn't exist")
                break
            }
        }
        else {
            switch updatedModel.label {
            case "Date":
                batterGameLog.date = value
                break
            case "Opponent":
                batterGameLog.opponent = value
                break
            case "AB":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.atBats = Int(value)
                break
            case "Hits":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.hits = Int(value)
                break
            case "R":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.runs = Int(value)
                break
            case "RBI":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.rbis = Int(value)
                break
            case "2B":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.doubles = Int(value)
                break
            case "3B":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.triples = Int(value)
                break
            case "HR":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.homeRuns = Int(value)
                break
            case "K":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.strikeouts = Int(value)
                break
            case "BB":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.walks = Int(value)
                break
            case "SB":
                guard let value = Int(value) else {
                    return
                }
                batterGameLog.stolenBases = Int(value)
                break
            default:
                print("Field doesn't exist")
                break
            }
        }
        //Update the mdoel
        print(updatedModel.value ?? "nil")
    }
}

