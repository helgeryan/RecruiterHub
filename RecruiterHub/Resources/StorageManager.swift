//
//  StorageManager.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/21/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import Foundation
import FirebaseStorage

public struct Upload {
    let videoUrl: String
    let thumbnailUrl: String
}

/// Allows you to get, fetch and upload files to firebase storage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public typealias UploadVideoCompletion = (Result<Upload, Error>) -> Void
    
    // Uploads a picture to firebase and returns a completion with url string to download
    public func uploadProfilePic(with data: Data,
                                 email: String,
                                 completion: @escaping UploadPictureCompletion) {
        storage.child("\(email)/profile_pic").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                //Failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            strongSelf.storage.child("\(email)/profile_pic").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    //  Upload image that will be sent in a conversation message
    public func uploadPhoto(with data: Data,
                                 filename: String,
                                 completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(filename)").putData(data, metadata: nil, completion: { [weak self]  metadata, error in
            
            guard error == nil else {
                //Failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(filename)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    //  Upload video that will be sent in a conversation message
    public func uploadVideo(with data: Data,
                            email: String,
                                 filename: String,
                                 completion: @escaping UploadVideoCompletion) {
        print("Attempting to store video ")
        storage.child("\(email)/videos/\(filename).mov").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            
            guard error == nil else {
                //Failed
                completion(.failure(StorageError.failedToUpload))
                print("Failed to upload data to Firebase")
                return
            }
            
            self?.storage.child("\(email)/videos/\(filename).mov").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    print("Failed to get download url")
                    return
                }
                let videoThumbnail = DatabaseManager.createThumbnail(url: url)
                guard let thumbnail = videoThumbnail.pngData() else {
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                
                self?.storage.child("\(email)/thumbnails/\(filename).png").putData(thumbnail, metadata: nil, completion: { [weak self] metadata, error in
                    
                    self?.storage.child("\(email)/thumbnails/\(filename).png").downloadURL(completion: {
                        thumbnailUrl, error in
                        
                        guard let thumbnail = thumbnailUrl else {
                            print("Failed to get thumbnail url")
                            return
                        }
                        
                        let uploadResults = Upload(videoUrl: urlString, thumbnailUrl: thumbnail.absoluteString)
                        
                        completion(.success(uploadResults))
                    })
                })
            })
        })
    }

    public func downloadURL( for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageError.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    
    //  Upload file that will be sent in a conversation message
    public func uploadMessageFile(with fileUrl: URL,
                                 filename: String,
                                 completion: @escaping UploadPictureCompletion) {
        storage.child("message_files/\(UserDefaults.standard.value(forKey: "email") ?? "misc")/\(filename)").putFile(from: fileUrl, metadata: nil, completion: { [weak self]  metadata, error in
            
            guard error == nil else {
                //Failed
                print("Failed to upload data to firebase")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self?.storage.child("message_files/\(UserDefaults.standard.value(forKey: "email") ?? "misc")/\(filename)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageError: Error {
        case failedToUpload              // Failed to Upload Data
        case failedToGetDownloadUrl
        
        public var localizedDescription: String {
            switch self {
            case .failedToUpload:
                return "Upload failed"
            case .failedToGetDownloadUrl:
                return "Failed to get download url."
            }
        }
    }
}
