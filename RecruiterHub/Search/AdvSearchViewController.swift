//
//  AdvSearchUserViewController.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/14/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import UIKit

class AdvSearchUserViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private var users = [[String: String]]()
    
    // Variable to store search results
    private var results = [AdvSearchResult]()
    
    // Whether the table has fetched
    private var hasFetched = false
    
    // Initialize search bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Searching for Users.. "
        return searchBar
    }()
    
    // Initialize tableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(AdvSearchTableViewCell.self, forCellReuseIdentifier: AdvSearchTableViewCell.identifier)
       
        return table
    }()
    
    private let searchTypes = ["--", "FB", "CH", "CB", "SL", "OF", "IF", "Exit Velo", "60",
                               "Ve. FB", "Ve. CH", "Ve. CB", "Ve. SL", "Ve. OF", "Ve. IF", "Ve. Exit Velo", "Ve. 60"]
    
    private let searchType: UIPickerView = {
        let spinner = UIPickerView(frame: .zero)
        spinner.backgroundColor = .lightGray
        spinner.layer.cornerRadius = 8
        return spinner
    }()
    
    private let minField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Min"
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let maxField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Max"
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let yearField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Year"
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let stateField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "State"
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let schoolField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "School"
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let posField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pos."
        textField.returnKeyType = .done
        textField.layer.masksToBounds = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    // Initialize the no results label
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results.. "
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        view.addSubview(searchType)
        view.addSubview(minField)
        view.addSubview(maxField)
        view.addSubview(yearField)
        view.addSubview(schoolField)
        view.addSubview(stateField)
        view.addSubview(posField)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName:                                                        "magnifyingglass"), style: .plain, target: self,                                              action: #selector(didTapSearch)),
                                              UIBarButtonItem(image: UIImage(systemName: "arrow.2.circlepath"), style: .plain, target: self, action: #selector(didTapReset))
        ]
        
        // Add delegates and data sources
        tableView.delegate = self
        tableView.dataSource = self
        searchType.delegate = self
        searchType.dataSource = self
        
        minField.delegate = self
        maxField.delegate = self
        yearField.delegate = self
        stateField.delegate = self
        schoolField.delegate = self
        posField.delegate = self
        
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            case .success(let userCollection):
                self?.hasFetched = true
                self?.users = userCollection
                break
            case .failure(let error):
                print("Failed to get users: \(error)")
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchType.frame = CGRect(x: 5, y: view.safeAreaInsets.top + 10, width: view.width / 3, height: 50)
        let padding: CGFloat = 5
        minField.frame = CGRect(x: searchType.right + padding, y: view.safeAreaInsets.top + 10, width: (view.width / 9 * 2) - padding * 2, height: 50)
        maxField.frame = CGRect(x: minField.right + padding, y: view.safeAreaInsets.top + 10, width: (view.width / 9 * 2) - padding * 2, height: 50)
        yearField.frame = CGRect(x: maxField.right + padding, y: view.safeAreaInsets.top + 10, width: (view.width / 9 * 2) - padding * 2, height: 50)
        schoolField.frame = CGRect(x: 5, y: searchType.bottom + 5, width: (view.width / 9 * 4) - padding * 2, height: 50)
        stateField.frame = CGRect(x: schoolField.right + 5, y: searchType.bottom + 5, width: (view.width / 9 * 2) - padding * 2, height: 50)
        posField.frame = CGRect(x: stateField.right + 5, y: searchType.bottom + 5, width: (view.width / 9 * 2) - padding * 2, height: 50)
        
        tableView.frame = CGRect(x: 0,
                                 y: stateField.bottom + 5,
                                 width: view.width,
                                 height: view.height - stateField.bottom - 20)
        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height-200) / 2, width: view.width / 2, height: 200)
    }
    
    
    @objc private func didTapReset() {
        searchType.selectRow(0, inComponent: 0, animated: true)
        minField.text = ""
        maxField.text = ""
        yearField.text = ""
        stateField.text = ""
        schoolField.text = ""
        posField.text = ""
        results.removeAll()
        tableView.reloadData()
    }
    
    @objc private func didTapSearch() {
        print("Tapped Search")
        navigationItem.rightBarButtonItems?[0].isEnabled = false
        minField.resignFirstResponder()
        maxField.resignFirstResponder()
        yearField.resignFirstResponder()
        stateField.resignFirstResponder()
        schoolField.resignFirstResponder()
        posField.resignFirstResponder()
        results.removeAll()
        tableView.reloadData()
        
        let type = searchTypes[searchType.selectedRow(inComponent: 0)]
        
        let group = DispatchGroup()
        group.enter()
        for (index, user) in users.enumerated() {
            guard let email = user["email"], let name = user["name"] else {
                print("User does not exist")
                return
            }
            DatabaseManager.shared.getDataForUserSingleEvent(user: email, completion: {
                userData in
                guard let userData = userData else {
                    print(email)
                    return
                }
                
                DatabaseManager.shared.getScoutInfoForUserSingleEvent(user: email, completion: { [weak self]
                    scoutInfo in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard let scoutInfo = scoutInfo else {
                        let newElement = AdvSearchResult(name: name, email: email, value: 0)
                        if strongSelf.filter(element: newElement, data: userData) {
                                self?.results.append(newElement)
                        }
                        if index == strongSelf.users.count - 1 {
                            group.leave()
                        }
                        return
                    }
                    
                    var value: Double = 0
                    switch type {
                    case "FB":
                        value = scoutInfo.fastball
                        break
                    case "CB":
                        value = scoutInfo.curveball
                        break
                    case "CH":
                        value = scoutInfo.changeup
                        break
                    case "SL":
                        value = scoutInfo.slider
                        break
                    case "OF":
                        value = scoutInfo.outfield
                        break
                    case "IF":
                        value = scoutInfo.infield
                        break
                    case "Exit Velo":
                        value = scoutInfo.exitVelo
                        break
                    case "60":
                        value = scoutInfo.sixty
                        break
                    case "Ve. FB":
                        value = scoutInfo.verifiedfastball
                        break
                    case "Ve. CB":
                        value = scoutInfo.verifiedcurveball
                        break
                    case "Ve. CH":
                        value = scoutInfo.verifiedchangeup
                        break
                    case "Ve. SL":
                        value = scoutInfo.verifiedslider
                        break
                    case "Ve. OF":
                        value = scoutInfo.verifiedoutfield
                        break
                    case "Ve. IF":
                        value = scoutInfo.verifiedinfield
                        break
                    case "Ve. Exit Velo":
                        value = scoutInfo.verifiedexitVelo
                        break
                    case "Ve. 60":
                        value = scoutInfo.verifiedsixty
                        break
                    default:
                        break
                    }
                    
                    let newElement = AdvSearchResult(name: name, email: email, value: value)
                    if strongSelf.filter(element: newElement, data: userData) {
                            self?.results.append(newElement)
                    }
                    
                    if index == strongSelf.users.count - 1 {
                        group.leave()
                    }
                })
            })
        }
        group.notify(queue: .main, execute: {
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItems?[0].isEnabled = true
        })
    }
    
    private func filter(element: AdvSearchResult, data: RHUser) -> Bool {

        if let minText = minField.text, minText != "" {
            if let min = Double(minText), min > element.value {
                return false
            }
        }
        
        if let maxText = maxField.text, maxText != "" {
            if let max = Double(maxText), max < element.value {
                return false
            }
        }
        
        if let gradYearText = yearField.text, gradYearText != "" {
            if let year = Int(gradYearText), year != data.gradYear {
                return false
            }
        }
        
        if let stateText = stateField.text, stateText != "" {
            if !data.state.lowercased().contains(stateText.lowercased()) {
                return false
            }
        }
        
        if let schoolText = schoolField.text, schoolText != "" {
            if !data.school.lowercased().contains(schoolText.lowercased()) {
                return false
            }
        }
        
        if let posText = posField.text, posText != "" {
            if !data.positions.lowercased().contains(posText.lowercased()) {
                return false
            }
        }
        
        return true
    }
}

extension AdvSearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AdvSearchTableViewCell.identifier, for: indexPath) as! AdvSearchTableViewCell
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: model.email.safeDatabaseKey(), completion: {
            user in
            guard let user = user else {
                return
            }
            cell.configure(user: user, value: model.value)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Start Conversation
        let targetUserData  = results[indexPath.row]
        DatabaseManager.shared.getDataForUserSingleEvent(user: targetUserData.email.safeDatabaseKey(), completion: { [weak self] user in
            
            guard let user = user else {
                return
            }
            
            let vc = OtherUserViewController(user: user)
            vc.title = user.name
            self?.navigationController?.pushViewController(vc, animated: true)
        })

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
}

extension AdvSearchUserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return searchTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return searchTypes[row]
    }
}

extension AdvSearchUserViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == stateField || textField == posField || textField == schoolField {
            return true
        }
        let charSet = CharacterSet.decimalDigits
        let input = CharacterSet(charactersIn: string)
        return charSet.isSuperset(of: input)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
