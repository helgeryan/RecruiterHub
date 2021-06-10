//
//  Models.swift
//  Instagram
//
//  Created by Ryan Helgeson on 1/5/21.
//

import Foundation
import AVKit

enum Gender {
    case male, female, other
}

struct User {
    let username: String
    let bio: String
    let name: (first:String, last: String)
    let profilePhoto: URL
    let birthDate: Date
    let gender: Gender
    let counts: UserCount
    let joinedDate: Date
}

struct UserCount {
    let followers: Int
    let following: Int
    let posts: Int
}


public enum UserPostType: String {
    case photo = "Photo"
    case video = "Video"
}

/// Represents a user post
public struct UserPost {
    let identifier: Int
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL // Either video url or full resolution photo
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdDate: Date
    let taggedUsers: [RHUser]
    let owner: RHUser
}

public struct NewFeedPost {
    let post: UserPost
    var player: AVPlayer?
}

struct CommentLike {
    let username: String
    let commentIdentifier: String
}

public struct PostComment {
    let identifier: Int
    let email: String
    let text: String
    let createdDate: Date
    let likes: [CommentLike]
}

public struct Following: Equatable {
    let email: String
}
