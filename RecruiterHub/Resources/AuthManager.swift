//
//  AuthManager.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/25/20.
//

import Foundation
import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    // MARK: - Public
    
    public func registerNewUser( username: String, email: String, password: String, user: RHUser, completion: @escaping (Bool) -> Void) {
        /*
         - Check if usernam is avaiable
         - Check if email is available
         - Create account
         - Insert account to database
         */
        print("Creating New User")
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { userExists in
            if !userExists {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        //Firebase auth could not create
                        print("Firebase could not create")
                        
                        completion(false)
                        return
                    }
                    
                    // Insert into database
                    print("Inserting New User")
                    DatabaseManager.shared.insertNewUser(with: email, user: user) { inserted in
                        if inserted {
                            completion(true)
                            return
                        }
                        else {
                            // Failed to insert to database
                            completion(false)
                            return
                        }
                    }
                }
            }
            else {
                //Either username or email does not exist
                print("Email Exists")
                completion(false)
            }
        }
    }
    
    public func login( username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let email = email {
            // email log in
            print(email)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Firebase signIn Failed")
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
        else if let username = username {
            //username log in
            print(username)
        }
    }
    
    /// Attempt to logout Firebase User
    public func logout(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
}
