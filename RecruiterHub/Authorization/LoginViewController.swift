//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/14/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .darkGray
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .darkGray
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
     }()
    
    private let loginButton:UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    private let registerButton:UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let imageBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen")
        return imageView
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Log In"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(imageBackgroundView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        Keyboard.keyboardWillShow(vc: self, notification: notification)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        Keyboard.keyboardWillHide(vc: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageBackgroundView.frame = view.bounds
        emailField.frame = CGRect(x:30 , y: view.height / 2, width: view.width-60, height: 52)
        passwordField.frame = CGRect(x:30 , y: emailField.bottom + 10, width: view.width-60, height: 52)
        loginButton.frame = CGRect(x:30 , y: passwordField.bottom + 10, width: view.width-60, height: 52)
        registerButton.frame = CGRect(x:30 , y: loginButton.bottom + 10, width: view.width-60, height: 52)
        
    }
    
    @objc private func didTap() {
        view.endEditing(true)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError(message: "Invalid Credentials")
            return
        }
    
        UserDefaults.standard.set(emailField.text?.safeDatabaseKey(), forKey: "email")
        //Firebase log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                self?.alertUserLoginError(message: "Invalid Credentials")
                print("Failed to login user with email: \(email)")
                return
            }
            
            let user = result.user
            
            DatabaseManager.shared.getDataForUserSingleEvent(user: email.safeDatabaseKey(), completion: { result in
                guard let result = result else {
                    print("Failed to cast user result")
                    return
                }
                
                UserDefaults.standard.set(result.safeEmail, forKey: "email")
                UserDefaults.standard.setValue(result.username, forKey: "username")
                UserDefaults.standard.setValue("\(result.firstName) \(result.lastName)", forKey: "name")
                UserDefaults.standard.setValue("Yes", forKey: "isLoggedIn")
            })
            
            print("Logged In \(user)")
            
            strongSelf.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func registerButtonTapped() {
        print("Register tapped")
        let vc = RegisterViewController()
        vc.title = "Register"
        
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
        
    }
    
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Failed to Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            print("Password Field is first responder")
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
        textField.textColor = .label
    }
}


