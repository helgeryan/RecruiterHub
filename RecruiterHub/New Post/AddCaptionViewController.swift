//
//  AddCaptionViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/7/21.
//

import UIKit

class AddCaptionViewController: UIViewController {
    
    private let data: Data
    
    private let email: String
    
    private let filename: String
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .justified
        textView.layer.borderWidth = 2
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.label.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .lightGray
        textView.text = "Video Caption..."
        return textView
    }()
    
    init(email: String, data: Data, filename: String) {
        self.email = email
        self.data = data
        self.filename = filename
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Caption"
        
        //tiffany: change back -> cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        
        textView.delegate = self
        view.addSubview(textView)
    }
    
 
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.width - 20, height: view.height / 2)
    }
    //tiffany: cancel function
    @objc private func didTapCancel(){
        print("Cancel button tapped")
        self.navigationController?.popToRootViewController(animated: true);
        
    }
    
    @objc private func didTapDone() {
        print("Tapped Done")
        StorageManager.shared.uploadVideo(with: data, email: email, filename: filename, completion: { [weak self] result in

            guard let email = self?.email else {
                return
            }

            guard var caption = self?.textView.text else {
                return
            }
            
            if caption == "Video Caption..." {
                caption = ""
            }

            switch result {
            case .success(let urlString):
                DatabaseManager.shared.insertNewPost(with: email, url: urlString, caption: caption)
                //tiffany: change it to popToRootView
                self?.navigationController?.popToRootViewController(animated: true)
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension AddCaptionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Caption..."
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
}
