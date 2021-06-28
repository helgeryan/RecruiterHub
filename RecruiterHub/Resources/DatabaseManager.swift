//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/25/20.
//

import Foundation
import FirebaseDatabase
import AVFoundation
import MessageKit

// Class DatabaseManger - Store all Functions that are to connect to Firebase Database
public class DatabaseManager {
    static let shared = DatabaseManager()
    
    // Creates a database reference
    private let database = Database.database().reference()
    
    // Create a safe database key. AKA a email with no '@' or '.' as firebase does not allow them for keys
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    // Creates a thumbnail (image) of the video. Takes the first frame and saves the image
    static func createThumbnail(url: URL) -> UIImage {
        // Create the asset
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        // Attempt to make the image, if failed return a default image
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return  uiImage
        }
        catch {
            return UIImage(systemName: "person.circle")!
        }
    }

    // MARK: - Users
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function Name: userExists
    ///
    /// Inputs:
    /// - email: Safe database email key
    /// - completion: closure to run at completion
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        // Ensure that the email is database safe
        let safeEmail = email.safeDatabaseKey()
        print("Checking if user exists")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            // Check if user exists
            guard snapshot.value as? [String: Any] != nil else {
                print("User doesn't exist")
                completion(false)
                return
            }
            
            print("User exists")
            completion(true)
        })
    }

    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function Name: canCreateNewUser
    ///
    /// Inputs:
    /// - email: Safe database email key
    /// - username: user's username
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    public func canCreateNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        
        // Ensure that the email is database safe
        let safeEmail = email.safeDatabaseKey()
        print("Checking if user exists")
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            
            // Check if user exists
            guard let users = snapshot.value as? [[String: String]] else {
                print("User doesn't exist")
                completion(false)
                return
            }
            
            if users.contains(where: { ($0["email"] == safeEmail) || ($0["username"] == username) } ) {
                print("User exists")
                completion(true)
            }
            else {
                print("User doesn't exist")
                completion(false)
            }
        })
    }


    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function Name: insertNewUser
    ///
    /// Inputs:
    /// - email: Safe database email key
    /// - username: user's username
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    public func insertNewUser(with email: String, user: RHUser, completion: @escaping (Bool) -> Void) {
        database.child(email.safeDatabaseKey()).child("username").setValue(user.username)
        database.child(email.safeDatabaseKey()).child("firstname").setValue(user.firstName)
        database.child(email.safeDatabaseKey()).child("lastname").setValue(user.lastName)
        database.child(email.safeDatabaseKey()).child("positions").setValue(user.positions)
        database.child(email.safeDatabaseKey()).child("heightFeet").setValue(user.heightFeet)
        database.child(email.safeDatabaseKey()).child("heightInches").setValue(user.heightInches)
        database.child(email.safeDatabaseKey()).child("highschool").setValue(user.highSchool)
        database.child(email.safeDatabaseKey()).child("state").setValue(user.state)
        database.child(email.safeDatabaseKey()).child("weight").setValue(user.weight)
        database.child(email.safeDatabaseKey()).child("arm").setValue(user.arm)
        database.child(email.safeDatabaseKey()).child("bats").setValue(user.bats)
        database.child(email.safeDatabaseKey()).child("gradYear").setValue(user.gradYear)
        database.child(email.safeDatabaseKey()).child("phone").setValue(user.phone)
        database.child(email.safeDatabaseKey()).child("profileType").setValue(user.profileType)
        database.child(email.safeDatabaseKey()).child("title").setValue(user.title)

        // Grab the database users reference
        database.child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            // Check to see if the value exists
            if var usersCollection = snapshot.value as? [[String: String]] {
                
                // Create a new User element
                let newElement = [
                    "name": "\(user.firstName) \(user.lastName)",
                    "email": user.emailAddress.safeDatabaseKey(),
                    "username": "\(user.username)"
                ]
                
                // Append the new element
                usersCollection.append(newElement)
                
                // Set the new user Collection
                self?.database.child("users").setValue(usersCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                //Create a new Collection
                let newCollection: [[String: String]] = [
                    [
                        "name": "\(user.firstName) \(user.lastName)",
                        "email": "\(user.emailAddress)",
                        "username": "\(user.username)"
                    ]
                ]
                
                // Set the new user Collection
                self?.database.child("users").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
        })
        
        completion(true)
    }
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Function Name: getAllUsers
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    public func getAllUsers( completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: String]] else {
                print("Failure")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public func deleteUser(index: Int, completion: @escaping (Bool) -> Void) {

        let ref = database.child("users")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var users = snapshot.value as? [[String: Any]] {

                users.remove(at: index)
                ref.setValue(users, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write post array")
                        return
                    }
                    print("Deleted Post")
                    completion(true)
                })
            }
        }
    }
    
    //MARK: - Posts

    public func newPost(post: UserPost) {
        database.child("\(post.owner.safeEmail)/Posts").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            var caption: String
            
            if post.caption != nil {
                caption = post.caption ?? ""
            }
            else {
                caption = ""
            }
            var type: String
            switch post.postType {
            case .photo:
                type = "photo"
                break
            case .video:
                type = "video"
                break
            }
            
            let newElement: [String : Any] = [
                "url": post.postURL.absoluteString,
                "thumbnail": post.thumbnailImage.absoluteString,
                "likes": "",
                "caption": caption,
                "comments": "",
                "date": ChatViewController.dateFormatter.string(from: post.createdDate),
                "type": type,
                "taggedUsers": ""
            ]
            
            if var usersCollection = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                usersCollection.append(newElement)
                
                self?.database.child("\(post.owner.safeEmail)/Posts").setValue(usersCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(post.owner.safeEmail)/Posts").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
        })
    }
    
    public func getAllUserPosts( with email: String, completion: @escaping (([UserPost]?) -> Void)) {
        
        database.child("\(email)/Posts").observe( .value, with: { snapshot in
           
            var userPosts: [UserPost] = []
            guard let posts = snapshot.value as? [[String:Any]] else {
                print("Failed to get all user posts")
                completion(nil)
                return
            }
            
            let group = DispatchGroup()
            group.enter()
            for (index, post) in posts.enumerated() {
                
                var caption: String
                if let postCaption = post["caption"] as? String {
                    caption = postCaption
                }
                else {
                    caption = ""
                }
                
                guard let thumbnailString = post["thumbnail"] as? String,
                    let thumbnail = URL(string: thumbnailString),
                    let videoUrlString = post["url"] as? String,
                        let videoUrl = URL(string: videoUrlString) else {
                    return
                }
                
                var likeCount: [PostLike] = []
                if let likes = post["likes"] as? [[String:String]] {
                    for like in likes {
                        guard let username = like["username"],
                              let name = like["name"],
                              let email = like["email"] else {
                            return
                        }
                        let postLike = PostLike(username: username, email: email, name: name)
                        likeCount.append(postLike)
                    }
                }
                
                var postComments: [PostComment] = []
                if let comments = post["comments"] as? [[String:String]] {
                    for comment in comments {
                        guard let email = comment["email"],
                              let text = comment["comment"]
                        else {
                            completion(nil)
                            return
                        }
                        
                        let newElement = PostComment(identifier: index, email: email, text: text, createdDate: Date(), likes: [])
                        
                        postComments.append(newElement)
                    }
                }
                
                self.getDataForUserSingleEvent(user: email, completion: { user in
                    guard let user = user else {
                        print("Failed to get User")
                        return
                    }
                    
                    let temp = UserPost( identifier: index,
                                         postType: .video,
                                         thumbnailImage: thumbnail,
                                         postURL: videoUrl,
                                         caption: caption,
                                         likeCount: likeCount,
                                         comments: postComments,
                                         createdDate: Date(),
                                         taggedUsers: [],
                                         owner: user)
                    userPosts.append(temp)
                    
                    // If the array is complete leave the function
                    if index == (posts.count - 1) {
                        group.leave()
                    }
                })
            }
            // Wait until the Array is assembled
            group.notify(queue: DispatchQueue.main, execute: {
                completion(userPosts)
            })
        })
        completion(nil)
    }
    
    public func getAllUserPostsSingleEvent( with email: String, completion: @escaping (([UserPost]?) -> Void)) {
        
        database.child("\(email)/Posts").observeSingleEvent( of: .value, with: { snapshot in
           
            var userPosts: [UserPost] = []
            guard let posts = snapshot.value as? [[String:Any]] else {
                print("Failed to get all user posts")
                completion(userPosts)
                return
            }
            
            let group = DispatchGroup()
            group.enter()
            for (index, post) in posts.enumerated() {
                
                var caption: String
                if let postCaption = post["caption"] as? String {
                    caption = postCaption
                }
                else {
                    caption = ""
                }
                
                var date = Date()
                if let dateString = post["date"] as? String {
                    date = ChatViewController.dateFormatter.date(from: dateString) ?? Date()
                }
                   
                
                guard let thumbnailString = post["thumbnail"] as? String,
                    let thumbnail = URL(string: thumbnailString),
                    let videoUrlString = post["url"] as? String,
                        let videoUrl = URL(string: videoUrlString) else {
                    return
                }
                
                var likeCount: [PostLike] = []
                if let likes = post["likes"] as? [[String:String]] {
                    for like in likes {
                        guard let username = like["username"],
                              let name = like["name"],
                              let email = like["email"] else {
                            return
                        }
                        let postLike = PostLike(username: username, email: email, name: name)
                        likeCount.append(postLike)
                    }
                }
                
                var postComments: [PostComment] = []
                if let comments = post["comments"] as? [[String:String]] {
                    for comment in comments {
                        
                        guard let email = comment["email"],
                              let text = comment["comment"]
                        else {
                            completion(userPosts)
                            return
                        }
                        
                        let newElement = PostComment(identifier: index, email: email, text: text, createdDate: Date(), likes: [])
                        
                        postComments.append(newElement)
                    }
                }
                
                self.getDataForUserSingleEvent(user: email, completion: { user in
                    guard let user = user else {
                        print("Failed to get User")
                        return
                    }
                    
                    let temp = UserPost( identifier: index,
                                         postType: .video,
                                         thumbnailImage: thumbnail,
                                         postURL: videoUrl,
                                         caption: caption,
                                         likeCount: likeCount,
                                         comments: postComments,
                                         createdDate: date,
                                         taggedUsers: [],
                                         owner: user)
                    userPosts.append(temp)
                    
                    // If the array is complete leave the function
                    if index == (posts.count - 1) {
                        group.leave()
                    }
                })
            }
            // Wait until the Array is assembled
            group.notify(queue: DispatchQueue.main, execute: {
                completion(userPosts)
            })
        })
    }
    
    public func getUserPost( with email: String, url: String, completion: @escaping ((UserPost?) -> Void)) {
        
        database.child("\(email)/Posts").observeSingleEvent( of: .value, with: { [weak self] snapshot in
           
            guard let posts = snapshot.value as? [[String:Any]] else {
                print("Failed to get all user posts")
                completion(nil)
                return
            }
            
            for (index, post) in posts.enumerated() {
                if url == post["url"] as? String {
                    guard let thumbnailString = post["thumbnail"] as? String,
                          let thumbnail = URL(string: thumbnailString),
                          let videoUrlString = post["url"] as? String,
                          let videoUrl = URL(string: videoUrlString) else {
                        print("Couldn't get post URLs")
                        return
                    }
                    
                    if videoUrlString != url {
                        continue
                    }
                    
                    var caption: String
                    if let postCaption = post["caption"] as? String {
                        caption = postCaption
                    }
                    else {
                        caption = ""
                    }
                    
                    self?.getDataForUserSingleEvent(user: email, completion: { user in
                        guard let user = user else {
                            print("Failed to get User")
                            return
                        }
                        
                        let userPost = UserPost( identifier: index,
                                                 postType: .video,
                                                 thumbnailImage: thumbnail,
                                                 postURL: videoUrl,
                                                 caption: caption,
                                                 likeCount: [],
                                                 comments: [],
                                                 createdDate: Date(),
                                                 taggedUsers: [],
                                                 owner: user)
                        
                        completion(userPost)
                        return
                    })
                }
            }
        })
    }
    
    public func like(with email: String, likerInfo: PostLike, post: UserPost, completion: @escaping () -> Void ) {
        print("Like")
        
        let ref = database.child("\(email.safeDatabaseKey())/Posts/\(post.identifier)/likes")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": likerInfo.email,
                "name": likerInfo.name,
                "username": likerInfo.username
            ]
            // No likes
            guard var likes = snapshot.value as? [[String:String]] else {
                ref.setValue([element])
                self.newLikeNotification(likerEmail: likerInfo.email, notifiedEmail: email, post: post, completion: {})
                completion()
                return
            }
            
            // Person already liked, delete their like
            if likes.contains(element) {
                print("Already liked")
                if let index = likes.firstIndex(of: element) {
                    likes.remove(at: index)
                    ref.setValue(likes)
                }
                completion()
                return
            }
            
            // Add new like
            let newElement = element
            likes.append(newElement)
            ref.setValue(likes)
            
            self.newLikeNotification(likerEmail: likerInfo.email, notifiedEmail: email, post: post, completion: {})
            completion()
        })
    }
    
    public func setProfilePic(with email: String, url: String) {
        database.child("\(email.safeDatabaseKey())/profilePicUrl").setValue(url)
    }
    
    public func getFeedPosts(completion: @escaping (([[String:String]]?) -> Void))  {
        database.child("FeedPosts").observeSingleEvent(of: .value, with: { snapshot in
            guard let feedPosts = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            
            completion(feedPosts)
        })
    }
    
    public func deletePost(index: Int, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/Posts")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var posts = snapshot.value as? [[String: Any]] {

                posts.remove(at: index)
                ref.setValue(posts, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write post array")
                        return
                    }
                    print("Deleted Post")
                    completion(true)
                })
            }
        }
    }
    
    // MARK: - User Info
    public func getDataForUserSingleEvent(user: String, completion: @escaping ((RHUser?) -> Void)) {
        
        database.child(user).observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let info = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let username = info["username"] as? String,
                  let heightInches =  info["heightInches"] as? Int,
                  let heightFeet = info["heightFeet"] as? Int,
                  let weight =  info["weight"] as? Int,
                  let gradYear =  info["gradYear"] as? Int,
                  let state = info["state"] as? String,
                  let highSchool = info["highschool"] as? String,
                  let positions = info["positions"] as? String,
                  let arm = info["arm"] as? String,
                  let bats = info["bats"] as? String,
                  let lastname = info["lastname"] as? String,
                  let firstname = info["firstname"] as? String,
                  let phone = info["phone"] as? String,
                  let profilePicUrl = info["profilePicUrl"] as? String else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            
            var profileType: String
            if let temp = info["profileType"] as? String {
                profileType = temp
            }
            else {
                profileType = "player"
            }
            
            var title: String
            if let temp = info["title"] as? String {
                title = temp
            }
            else {
                title = "player"
            }
            
            var userData = RHUser()
            userData.username = username
            userData.firstName = firstname
            userData.lastName = lastname
            userData.emailAddress = user
            userData.phone = phone
            userData.gpa = 0
            userData.positions = positions
            userData.highSchool = highSchool
            userData.state = state
            userData.gradYear = gradYear
            userData.heightFeet = heightFeet
            userData.heightInches = heightInches
            userData.weight = weight
            userData.arm = arm
            userData.bats = bats
            userData.profilePicUrl = profilePicUrl
            userData.profileType = profileType
            userData.title = title
            
            completion(userData)
        })
    }
    
    public func getDataForUser(user: String, completion: @escaping ((RHUser?) -> Void)) {
        
        database.child(user).observe( .value, with:  { snapshot in
            
            guard let info = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let username = info["username"] as? String,
                  let heightInches =  info["heightInches"] as? Int,
                  let heightFeet = info["heightFeet"] as? Int,
                  let weight =  info["weight"] as? Int,
                  let gradYear =  info["gradYear"] as? Int,
                  let state = info["state"] as? String,
                  let highSchool = info["highschool"] as? String,
                  let positions = info["positions"] as? String,
                  let arm = info["arm"] as? String,
                  let bats = info["bats"] as? String,
                  let lastname = info["lastname"] as? String,
                  let firstname = info["firstname"] as? String,
                  let phone = info["phone"] as? String,
                  let profilePicUrl = info["profilePicUrl"] as? String else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            
            var profileType: String
            if let temp = info["profileType"] as? String {
                profileType = temp
            }
            else {
                profileType = "player"
            }
            
            var title: String
            if let temp = info["title"] as? String {
                title = temp
            }
            else {
                title = "player"
            }
            
            var userData = RHUser()
            userData.username = username
            userData.firstName = firstname
            userData.lastName = lastname
            userData.emailAddress = user
            userData.phone = phone
            userData.gpa = 0
            userData.positions = positions
            userData.highSchool = highSchool
            userData.state = state
            userData.gradYear = gradYear
            userData.heightFeet = heightFeet
            userData.heightInches = heightInches
            userData.weight = weight
            userData.arm = arm
            userData.bats = bats
            userData.profilePicUrl = profilePicUrl
            userData.profileType = profileType
            userData.title = title
            
            completion(userData)
        })
    }
    
    public func getProfileType(email: String, completion: @escaping ((String?) -> Void)) {
        
        database.child("\(email)/profileType").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let profileType = snapshot.value as? String else {
                completion(nil)
                return
            }
            
            completion(profileType)
        })
    }
    
    public func updateUserInfor( user: RHUser) {
        let email = user.emailAddress.safeDatabaseKey()
        
        database.child(email).child("username").setValue(user.username)
        database.child(email).child("firstname").setValue(user.firstName)
        database.child(email).child("lastname").setValue(user.lastName)
        database.child(email).child("positions").setValue(user.positions)
        database.child(email).child("heightFeet").setValue(user.heightFeet)
        database.child(email).child("heightInches").setValue(user.heightInches)
        database.child(email).child("highschool").setValue(user.highSchool)
        database.child(email).child("state").setValue(user.state)
        database.child(email).child("weight").setValue(user.weight)
        database.child(email).child("arm").setValue(user.arm)
        database.child(email).child("bats").setValue(user.bats)
        database.child(email).child("gradYear").setValue(user.gradYear)
        database.child(email).child("title").setValue(user.title)
        database.child(email).child("phone").setValue(user.phone)
    }
    
    public func getScoutInfoForUser(user: String, completion: @escaping ((ScoutInfo?) -> Void)) {
        database.child("\(user)/scoutInfo").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let info = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let fastball = info["fastball"] as? Double,
                  let curveball =  info["curveball"] as? Double,
                  let slider = info["slider"] as? Double,
                  let changeup =  info["changeup"] as? Double,
                  let sixty =  info["sixty"] as? Double,
                  let infield = info["infield"] as? Double,
                  let outfield = info["outfield"] as? Double,
                  let exitVelo = info["exitVelo"] as? Double else {
               print("Failed to get user data")
                completion(nil)
                return
            }
            
            var scoutInfo = ScoutInfo()
            scoutInfo.fastball = fastball
            scoutInfo.curveball = curveball
            scoutInfo.slider = slider
            scoutInfo.changeup = changeup
            scoutInfo.sixty = sixty
            scoutInfo.infield = infield
            scoutInfo.outfield = outfield
            scoutInfo.exitVelo = exitVelo
            
            if let verifiedFastball = info["verifiedFastball"] as? Double,
                  let verifiedCurveball =  info["verifiedCurveball"] as? Double,
                  let verifiedSlider = info["verifiedSlider"] as? Double,
                  let verifiedChangeup =  info["verifiedChangeup"] as? Double,
                  let verifiedSixty =  info["verifiedSixty"] as? Double,
                  let verifiedInfield = info["verifiedInfield"] as? Double,
                  let verifiedOutfield = info["verifiedOutfield"] as? Double,
                  let verifiedExitVelo = info["verifiedExitVelo"] as? Double {
                scoutInfo.verifiedfastball =    verifiedFastball
                scoutInfo.verifiedcurveball =   verifiedCurveball
                scoutInfo.verifiedslider =      verifiedSlider
                scoutInfo.verifiedchangeup =    verifiedChangeup
                scoutInfo.verifiedsixty =       verifiedSixty
                scoutInfo.verifiedinfield =     verifiedInfield
                scoutInfo.verifiedoutfield =    verifiedOutfield
                scoutInfo.verifiedexitVelo =    verifiedExitVelo
            }
    
            completion(scoutInfo)
        })
    }
    
    public func updateScoutInfoForUser(email: String, scoutInfo: ScoutInfo) {
        database.child("\(email)/scoutInfo").child("fastball").setValue(scoutInfo.fastball)
        database.child("\(email)/scoutInfo").child("curveball").setValue(scoutInfo.curveball)
        database.child("\(email)/scoutInfo").child("slider").setValue(scoutInfo.slider)
        database.child("\(email)/scoutInfo").child("changeup").setValue(scoutInfo.changeup)
        database.child("\(email)/scoutInfo").child("sixty").setValue(scoutInfo.sixty)
        database.child("\(email)/scoutInfo").child("infield").setValue(scoutInfo.infield)
        database.child("\(email)/scoutInfo").child("outfield").setValue(scoutInfo.outfield)
        database.child("\(email)/scoutInfo").child("exitVelo").setValue(scoutInfo.exitVelo)
    }
    
    public func getPitcherGameLogsForUser(user: String, completion: @escaping (([PitcherGameLog]?) -> Void)) {
        database.child("\(user)/PitcherGameLogs").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let pitcherGameLogsDictionary = snapshot.value as? [[String: Any]] else {
                completion(nil)
                return
            }
            var pitcherGameLogs: [PitcherGameLog] = []
            
            for log in pitcherGameLogsDictionary {
                guard let date = log["date"] as? String,
                      let opponent =  log["opponent"] as? String,
                      let inningsPitched = log["inningsPitched"] as? Double,
                      let hits =  log["hits"] as? Int,
                      let runs =  log["runs"] as? Int,
                      let earnedRuns = log["earnedRuns"] as? Int,
                      let strikeouts = log["strikeouts"] as? Int,
                      let walks = log["walks"] as? Int else {
                   print("Failed to get user data")
                    completion(nil)
                    return
                }
                var pitcherGameLog = PitcherGameLog()
                pitcherGameLog.date = date
                pitcherGameLog.opponent = opponent
                pitcherGameLog.inningsPitched = inningsPitched
                pitcherGameLog.hits = hits
                pitcherGameLog.runs = runs
                pitcherGameLog.earnedRuns = earnedRuns
                pitcherGameLog.strikeouts = strikeouts
                pitcherGameLog.walks = walks
                pitcherGameLogs.append(pitcherGameLog)
            }
            
            completion(pitcherGameLogs)
        })
    }
    
    public func getBatterGameLogsForUser(user: String, completion: @escaping (([BatterGameLog]?) -> Void)) {
        database.child("\(user)/BatterGameLogs").observeSingleEvent(of: .value, with:  { snapshot in
            
            guard let batterGameLogsDictionary = snapshot.value as? [[String: Any]] else {
                completion(nil)
                return
            }
            var batterGameLogs: [BatterGameLog] = []
            
            for log in batterGameLogsDictionary {
                guard let date = log["date"] as? String,
                      let opponent =  log["opponent"] as? String,
                      let atBats = log["atBats"] as? Int,
                      let hits =  log["hits"] as? Int,
                      let runs =  log["runs"] as? Int,
                      let rbis =  log["rbis"] as? Int,
                      let doubles = log["doubles"] as? Int,
                      let triples = log["triples"] as? Int,
                      let homeruns = log["homeruns"] as? Int,
                      let strikeouts = log["strikeouts"] as? Int,
                      let walks = log["walks"] as? Int,
                      let stolenBases = log["stolenBases"] as? Int else {
                   print("Failed to get user data")
                    completion(nil)
                    return
                }
                var batterGameLog = BatterGameLog()
                batterGameLog.date = date
                batterGameLog.opponent = opponent
                batterGameLog.atBats = atBats
                batterGameLog.hits = hits
                batterGameLog.runs = runs
                batterGameLog.rbis = rbis
                batterGameLog.doubles = doubles
                batterGameLog.triples = triples
                batterGameLog.homeRuns = homeruns
                batterGameLog.strikeouts = strikeouts
                batterGameLog.walks = walks
                batterGameLog.stolenBases = stolenBases
                
                batterGameLogs.append(batterGameLog)
            }
            
            completion(batterGameLogs)
        })
    }
    
    public func addReferenceForUser( email: String, reference: Reference) {
        database.child("\(email)/References").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement: [String: String] = [
                "name": reference.name,
                "phone": reference.phone,
                "email": reference.emailAddress
            ]
            
            if var references = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                references.append(newElement)
                
                self?.database.child("\(email)/References").setValue(references, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/References").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
       })
    }
    
    public func deleteReference(reference: Reference, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Deleting the reference: \(reference)")
        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/References")
        
        let removedElement = [
            "name": reference.name,
            "email": reference.emailAddress,
            "phone": reference.phone
            
        ]
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var references = snapshot.value as? [[String: String]] {
                var positionToRemove = 0
                for reference in references {
                    if reference == removedElement {
                        print("Found reference to delete")
                        break
                    }
                    positionToRemove += 1
                }
                
                references.remove(at: positionToRemove)
                ref.setValue(references, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new reference array")
                        return
                    }
                    print("Deleted Reference")
                    completion(true)
                })
            }
        }
    }
    
    public func addGameLogForUser( email: String, gameLog: PitcherGameLog) {
        database.child("\(email)/PitcherGameLogs").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement: [String:Any] = [
                "date": gameLog.date,
                "opponent": gameLog.opponent,
                "inningsPitched": gameLog.inningsPitched,
                "hits": gameLog.hits,
                "runs": gameLog.runs,
                "earnedRuns": gameLog.earnedRuns,
                "strikeouts": gameLog.strikeouts,
                "walks": gameLog.walks
            ]
            
            if var gameLogs = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                gameLogs.append(newElement)
                
                self?.database.child("\(email)/PitcherGameLogs").setValue(gameLogs, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/PitcherGameLogs").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
       })
    }
    
    public func deletePitcherGameLog(index: Int, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/PitcherGameLogs")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var gameLogs = snapshot.value as? [[String: Any]] {

                gameLogs.remove(at: index)
                ref.setValue(gameLogs, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new pitcher game log array")
                        return
                    }
                    print("Deleted Pitcher Game Log")
                    completion(true)
                })
            }
        }
    }
    
    public func addBatterGameLogForUser( email: String, gameLog: BatterGameLog) {
        database.child("\(email)/BatterGameLogs").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement: [String:Any] = [
                "date": gameLog.date,
                "opponent": gameLog.opponent,
                "atBats": gameLog.atBats,
                "hits": gameLog.hits,
                "runs": gameLog.runs,
                "rbis": gameLog.rbis,
                "doubles": gameLog.doubles,
                "triples": gameLog.triples,
                "homeruns": gameLog.homeRuns,
                "strikeouts": gameLog.strikeouts,
                "walks": gameLog.walks,
                "stolenBases": gameLog.stolenBases
            ]
            
            if var gameLogs = snapshot.value as? [[String: Any]] {
                print("Collection Exists")
                gameLogs.append(newElement)
                
                self?.database.child("\(email)/BatterGameLogs").setValue(gameLogs, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
            else {
                print("New Collection")
                let newCollection: [[String: Any]] = [newElement]
                
                self?.database.child("\(email)/BatterGameLogs").setValue(newCollection, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        return
                    }
                })
            }
       })
    }
    
    public func deleteBatterGameLog( index: Int, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/BatterGameLogs")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var gameLogs = snapshot.value as? [[String: Any]] {
                
                gameLogs.remove(at: index)
                ref.setValue(gameLogs, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new pitcher game log array")
                        return
                    }
                    print("Deleted Pitcher Game Log")
                    completion(true)
                })
            }
        }
    }
    
    // MARK: - Messages
    
    public func sendMessage( to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //add new messag to messages
        // update sender latest message
        // update recipient latest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(let mediaItem):
                if let media = mediaItem as? MediaItem {
                    if let targetUrlString = media.url?.absoluteString {
                        message = targetUrlString
                    }
                }
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue:[String:Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        // we need to create conversation entry
                        var targetConversation: [String:Any]?
                        
                        var position = 0
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                   
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        
                        // update latest message for recipient
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            
                            var databaseEntryConversations = [[String: Any]]()
                            let updatedValue:[String:Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]

                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }

                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String:Any]?
                                
                                var position = 0
                                
                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // Failed to find the target conversation
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            
                            }
                            else {
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            
                           strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            })
        })
    }
    
    // Creates a new conversation with target user email and first message sent
    public func createNewConversation( with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void ) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child(safeEmail)
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                print(snapshot)
                
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })

            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation( name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)

                }
            }
            else {
                // Conversation array does not exist
                // Create it
                userNode["conversations"] = [
                    newConversationData
                ]

                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation( name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)

                })
            }
        })
    }
    
    // Fetches and returns all conversations for the user with passed in email
    public func getAllConversations( for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void ) {
        database.child("\(email)/conversations").observe( .value, with: { snapshot in
            
            if snapshot.exists() == false {
                completion(.failure(DatabaseError.conversationsEmpty))
                return
            }
            
            guard let value = snapshot.value as? [[String: Any]] else {
                print("Failed to get convos")
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation( id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
                
            })
            
            completion(.success(conversations))
        })
    }
    
    private func finishCreatingConversation( name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                //Get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                completion(.success(id))
                return
            }
            
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("Deleting the conversation with id: \(conversationId)")
        // Get all conversations for current User
        //Delete convesation with target id
        // Reset those conversations for use in database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationId {
                        print("Found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error,_ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new conversation array")
                        return
                    }
                    print("Deleted Conversation")
                    completion(true)
                })
            }
        }
    }
    
    // Get all messages for a given conversation
    public func getAllMessagesForConversations( for id: String, completion: @escaping (Result<[Message], Error>) -> Void ) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      //let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    // Photo
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    
                    kind = .photo(media)
                    
                }
                else if type == "video"  {
                    // Photo
                    guard let videoUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300, height: 300))
                    
                    kind = .video(media)
                }
                else if type == "location" {
//                    let locationComponents = content.components(separatedBy: ",")
//                    guard let longitude = Double(locationComponents[0]),
//                          let latitude = Double(locationComponents[1]) else {
//                        return nil
//                    }
//
//                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 300, height: 300))
//
//                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            })
            
            completion(.success(messages))
        })
    }
    
    
    // MARK: - Connections
    public func getUserFollowersSingleEvent( email: String, completion: @escaping (([Following]?) -> Void))  {
        database.child("\(email)/followers").observeSingleEvent(of: .value, with: { snapshot in
            guard let followers = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            
            var array: [Following] = []
            for follow in followers {
                guard let email = follow["email"] else {
                    return
                }
                
                let newElement = Following(email: email)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    public func getUserFollowing( email: String, completion: @escaping (([Following]?) -> Void))  {
        database.child("\(email)/following").observe( .value, with: { snapshot in
            guard let following = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Following] = []
            for follow in following {
                guard let email = follow["email"] else {
                    return
                }
                
                let newElement = Following(email: email)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    public func getUserFollowingSingleEvent( email: String, completion: @escaping (([Following]?) -> Void))  {
        database.child("\(email)/following").observeSingleEvent( of: .value, with: { snapshot in
            guard let following = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Following] = []
            for follow in following {
                guard let email = follow["email"] else {
                    return
                }
                
                let newElement = Following(email: email)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    public func getUserEndorsementsSingleEvent( email: String, completion: @escaping (([Following]?) -> Void))  {
        database.child("\(email)/endorsers").observeSingleEvent(of: .value, with: { snapshot in
            guard let endorsers = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Following] = []
            for endorser in endorsers {
                guard let email = endorser["email"] else {
                    return
                }
                
                let newElement = Following(email: email)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    public func getUserReferencesSingleEvent( email: String, completion: @escaping (([Reference]?) -> Void))  {
        database.child("\(email)/References").observeSingleEvent(of: .value, with: { snapshot in
            guard let references = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Reference] = []
            for reference in references {
                guard let email = reference["email"],
                      let name = reference["name"],
                      let phone = reference["phone"] else {
                    return
                }
                
                let newElement = Reference(emailAddress: email, phone: phone, name: name)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    public func getUserReferences( email: String, completion: @escaping (([Reference]?) -> Void))  {
        database.child("\(email)/References").observe( .value, with: { snapshot in
            guard let references = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Reference] = []
            for reference in references {
                guard let email = reference["email"],
                      let name = reference["name"],
                      let phone = reference["phone"] else {
                    return
                }
                
                let newElement = Reference(emailAddress: email, phone: phone, name: name)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    
    public func getUserEndorsements( email: String, completion: @escaping (([Following]?) -> Void))  {
        print("fetch Endorsements")

        database.child("\(email)/endorsers").observe( .value, with: { snapshot in
            guard let endorsers = snapshot.value as? [[String:String]] else {
                completion(nil)
                return
            }
            var array: [Following] = []
            for endorser in endorsers {
                guard let email = endorser["email"] else {
                    return
                }
                
                let newElement = Following(email: email)
                array.append(newElement)
            }
            
            completion(array)
        })
    }
    
    public func follow( email: String, followerEmail: String, completion: (() -> ())?) {
        
        let refFollower = database.child("\(email.safeDatabaseKey())/followers")
        
        refFollower.observeSingleEvent(of: .value, with: { [weak self] snapshot in
        
            let element = [
                "email": followerEmail
            ]
            
            // No followers
            guard var followers = snapshot.value as? [[String:String]] else {
                refFollower.setValue([element])
                self?.newFollowNotification(followerEmail: followerEmail, notifiedEmail: email, completion: {})
                return
            }
            
            // Person already followed, delete their follow
            if followers.contains(element) {
                print("Already followed")
                if let index = followers.firstIndex(of: element) {
                    followers.remove(at: index)
                    refFollower.setValue(followers)
                }
                return
            }
            
            // Add new follower
            let newElement = element
            followers.append(newElement)
            refFollower.setValue(followers)
            print("Follow Notification")
            self?.newFollowNotification(followerEmail: followerEmail, notifiedEmail: email, completion: {})
        })
        
        let refCurrentUser = database.child("\(followerEmail.safeDatabaseKey())/following")
        
        refCurrentUser.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": email
            ]
            // No followers
            guard var following = snapshot.value as? [[String:String]] else {
                refCurrentUser.setValue([element])
                return
            }
            
            // Person already following, delete their follow
            if following.contains(element) {
                print("Already followed")
                if let index = following.firstIndex(of: element) {
                    following.remove(at: index)
                    refCurrentUser.setValue(following)
                }
                return
            }
            
            // Add new following
            let newElement = element
            following.append(newElement)
            refCurrentUser.setValue(following)
        })
    }
    
    public func endorse( email: String, endorserEmail: String, completion: (() -> ())?) {
        
        let refFollower = database.child("\(email.safeDatabaseKey())/endorsers")
        
        refFollower.observeSingleEvent(of: .value, with: { snapshot in
        
            let element = [
                "email": endorserEmail
            ]
            
            // No endorsers
            guard var followers = snapshot.value as? [[String:String]] else {
                refFollower.setValue([element])
                return
            }
            
            // Person already endorsed, removeEndorsement
            if followers.contains(element) {
                print("Already endorsed")
                if let index = followers.firstIndex(of: element) {
                    followers.remove(at: index)
                    refFollower.setValue(followers)
                }
                return
            }
            
            // Add new endorsement
            let newElement = element
            followers.append(newElement)
            refFollower.setValue(followers)
            
        })
    }
    
    public func getCommentsSingleEvent(with email: String, index: Int, completion: @escaping (([PostComment]?) -> Void)) {
        database.child("\(email)/Posts/\(index)/comments").observeSingleEvent(of: .value, with: { snapshot in
            
            var postComments: [PostComment] = []
            guard let comments = snapshot.value as? [[String:String]] else {
                print("Failed to get comments")
                completion(nil)
                return
            }
            
            for (index, comment) in comments.enumerated() {
                
                guard let email = comment["email"],
                      let text = comment["comment"]
                    else {
                    completion(nil)
                    return
                }
                
                let newElement = PostComment(identifier: index, email: email, text: text, createdDate: Date(), likes: [])
                
                postComments.append(newElement)
            }

            completion(postComments)
        })
        completion(nil)
    }
    
    public func getComments(with email: String, index: Int, completion: @escaping (([PostComment]?) -> Void)) {
        database.child("\(email)/Posts/\(index)/comments").observe(.value, with: { snapshot in
            
            var postComments: [PostComment] = []
            guard let comments = snapshot.value as? [[String:String]] else {
                print("Failed to get comments")
                completion(nil)
                return
            }
            
            for (index, comment) in comments.enumerated() {
                
                guard let email = comment["email"],
                      let text = comment["comment"]
                    else {
                    completion(nil)
                    return
                }
                
                let newElement = PostComment(identifier: index, email: email, text: text, createdDate: Date(), likes: [])
                
                postComments.append(newElement)
            }

            completion(postComments)
        })
        completion(nil)
    }
    
    public func getLikes(with email: String, index: Int, completion: @escaping (([PostLike]?) -> Void)) {
        database.child("\(email)/Posts/\(index)/likes").observe( .value, with: { snapshot in
            
            guard let likes = snapshot.value as? [[String:String]] else {
                print("Failed to get likes")
                completion(nil)
                return
            }
            
            var likeCount: [PostLike] = []
            for like in likes {
                guard let username = like["username"],
                      let name = like["name"],
                      let email = like["email"] else {
                    return
                }
                let postLike = PostLike(username: username, email: email, name: name)
                likeCount.append(postLike)
            }
            
            completion(likeCount)
        })
        completion(nil)
    }
    
    public func newComment( email: String, postComment: PostComment, index: Int) {
        database.child("\(email)/Posts/\(index)/comments").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            let newElement = [
                "email": postComment.email,
                "comment": postComment.text,
                "date": ChatViewController.dateFormatter.string(from: Date())
            ]
            
            // Comments exist append the comment
            if var comments = snapshot.value as? [[String:String]] {
                
                comments.append(newElement)
                
                self?.database.child("\(email)/Posts/\(index)/comments").setValue(comments)
            }
            else {
                let newCommentsCollection = [newElement]
                
                self?.database.child("\(email)/Posts/\(index)/comments").setValue(newCommentsCollection)
            }
        })
    }
    
    
    public func getNumberOf( email: String, connection: Connections, completion: @escaping (Int) -> Void) {
        var attribute = ""
        switch connection {
        case .follower:
            attribute = "followers"
            break
        case .following:
            attribute = "following"
            break
        case .endorsers:
            attribute = "endorsers"
            break
        }
        database.child("\(email)/\(attribute)").observe( .value, with: {
            snapshot in
            
            guard let list = snapshot.value as? [[String: String]] else {
                completion(0)
                return
            }
            completion(list.count)
        })
    }
    
    // MARK: - Notification
    
    public func newFollowNotification( followerEmail: String, notifiedEmail: String, completion: @escaping (() -> Void)) {
        print("New Follow Notification")
        let ref = database.child("\(notifiedEmail)/Notifications")
        ref.observeSingleEvent( of: .value, with: { snapshot in
            
            self.getDataForUserSingleEvent(user: followerEmail, completion: {
                user in
                guard let user = user else {
                    return
                    
                }
                let element = [
                    "email": followerEmail,
                    "type": "follow",
                    "text": "\(user.username) followed you",
                    "date": ChatViewController.dateFormatter.string(from: Date())
                ]
                
                guard var notifications = snapshot.value as? [[String:String]] else {
                    print("Notifications don't exist")
                    ref.setValue([element])
                    completion()
                    return
                }
                
                // Person already liked, delete their like
                if notifications.contains(where: { ($0["email"] == followerEmail) && ($0["type"] == "follow") && ($0["text"] == "\(user.username) followed you")} ) {
                    
                    completion()
                    return
                }
                
                // Add new notifications
                let newElement = element
                notifications.append(newElement)
                ref.setValue(notifications)
                completion()
            })
        })
    }
    
    public func newLikeNotification( likerEmail: String, notifiedEmail: String, post: UserPost, completion: @escaping (() -> Void)) {
        let ref = database.child("\(notifiedEmail)/Notifications")
        ref.observeSingleEvent( of: .value, with: { snapshot in
            
            self.getDataForUserSingleEvent(user: likerEmail, completion: {
                user in
                guard let user = user else {
                    return
                    
                }
                let element = [
                    "email": likerEmail,
                    "type": "like",
                    "text": "\(user.username) liked your post",
                    "postID": post.postURL.absoluteString,
                    "date": ChatViewController.dateFormatter.string(from: Date())
                ]
                
                guard var notifications = snapshot.value as? [[String:String]] else {
                    print("Notifications don't exist")
                    ref.setValue([element])
                    completion()
                    return
                }
                
                // Person already liked, delete their like
                if notifications.contains(where: { ($0["email"] == likerEmail) && ($0["type"] == "like") && ($0["text"] == "\(user.username) liked your post") && ( $0["postID"] == post.postURL.absoluteString) } ) {
                    
                    completion()
                    return
                }
                
                // Add new notifications
                let newElement = element
                notifications.append(newElement)
                ref.setValue(notifications)
                completion()
            })
        })
    }
    
    public func getUserNotifications( user: String, completion: @escaping (([UserNotification]?) -> Void))  {
        database.child("\(user)/Notifications").observe( .value, with: { [weak self] snapshot in
            guard let notifications = snapshot.value as? [[String:String]] else {
                print("Notifications don't exist")
                completion(nil)
                return
            }
            var array = [UserNotification]()
            
            let group = DispatchGroup()
            group.enter()
            
            for notification in notifications {
                
                guard let email = notification["email"],
                      let text = notification["text"],
                      let type = notification["type"],
                      let dateString =  notification["date"],
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    print("Failed to get notification")
                    group.leave()
                    return
                }

                var notificationType: UserNotificationType = UserNotificationType.follow(state: .following)
                if type == "like" {
                    var RHuser = RHUser()
                    RHuser.emailAddress = user
                    guard let urlString = notification["postID"],
                          let url = URL(string: urlString) else {
                        group.leave()
                        return
                    }
                    notificationType = UserNotificationType.like(post: UserPost( identifier: 0,
                                                                                 postType: .video,
                                                                                thumbnailImage: url,
                                                                                postURL: url,
                                                                                caption: "Caption",
                                                                                likeCount: [],
                                                                                comments: [],
                                                                                createdDate: Date(),
                                                                                taggedUsers: [], owner: RHuser))
                    
                    self?.getDataForUserSingleEvent(user: email, completion: { user in
                        guard let user = user else {
                            group.leave()
                            print("Failed to get User")
                            return
                        }
                        
                        let temp = UserNotification(type: notificationType, text: text, user: user, date: date)
                        array.append(temp)
                        // If the array is complete leave the function
                        if array.count == notifications.count {
                            group.leave()
                        }
                    })
                }
                else {
                    self?.getUserFollowing(email: user, completion: { following in
                        guard let following = following  else {
                            
                            let notificationType = UserNotificationType.follow(state: .not_following )
                            
                            self?.getDataForUserSingleEvent(user: email, completion: { user in
                                guard let user = user else {
                                    group.leave()
                                    print("Failed to get User")
                                    return
                                }
                                
                                let temp = UserNotification(type: notificationType, text: text, user: user, date: date)
                                array.append(temp)
                                // If the array is complete leave the function
                                if array.count == notifications.count {
                                    group.leave()
                                }
                            })
                            return
                        }
                        
                        for follow in following {
                            
                            if follow.email == email {
                                notificationType = UserNotificationType.follow(state: .following )
                                break
                            }
                            else {
                                notificationType = UserNotificationType.follow(state: .not_following )
                            }
                        }
                        
                        self?.getDataForUserSingleEvent(user: email, completion: { user in
                            guard let user = user else {
                                group.leave()
                                print("Failed to get User")
                                return
                            }
                            
                            let temp = UserNotification(type: notificationType, text: text, user: user, date: date)
                            array.append(temp)
                            // If the array is complete leave the function
                            if array.count == notifications.count {
                                group.leave()
                            }
                        })
                    })
                }
            }
            
            // Wait until the Array is assembled
            group.notify(queue: DispatchQueue.main, execute: {
                
                let sortedNotifications = array.sorted(by: {  $0.date.compare($1.date) == .orderedDescending })

                completion(sortedNotifications)
            })
        })
    }
    // MARK: - Errors
    
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    /// Enum Name:  DatabaseError
    ///
    /// Descritption: Errors that can occur throughout database interactions
    ///
    //\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    public enum DatabaseError: Error {
        case failedToFetch              // Failed to Fetch Data
        case conversationsEmpty         // Conversations are empty
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Fetch failed"
            case .conversationsEmpty:
                return "Conversations Empty"
            }
        }
    }
}

