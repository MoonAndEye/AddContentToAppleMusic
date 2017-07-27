//
//  MediaLibraryManager.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/27.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation
import MediaPlayer

@objc
class MediaLibraryManager: NSObject {
    
    static let playlistUUIDKey = "playlistUUIDKey"
    
    static let libraryDidUpdate = Notification.Name("libraryDidUpdate")
    
    let authorizationManager: AuthorizationManager
    
    var mediaPlaylist: MPMediaPlaylist!
    
    init(authorizationManager: AuthorizationManager) {
        self.authorizationManager = authorizationManager
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAuthorizationManagerAuthorizationDidUpdateNotification),
                                       name: AuthorizationManager.authorizationDidUpdateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMediaLibraryDidChangeNotification),
                                       name: .MPMediaLibraryDidChange,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMediaLibraryDidChangeNotification),
                                       name: .UIApplicationWillEnterForeground,
                                       object: nil)
        
        handleAuthorizationManagerAuthorizationDidUpdateNotification()
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMediaLibraryDidChange, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func createPlaylistIfNeeded() {
        
        guard mediaPlaylist == nil else { return }
        
        let playlistUUID: UUID
        
        var playlistCreationMetadata: MPMediaPlaylistCreationMetadata!
        
        let userDefaults = UserDefaults.standard
        
        if let playlistUUIDString = userDefaults.string(forKey: MediaLibraryManager.playlistUUIDKey) {
            
            //這個選擇分支，是在 playlist 已經存在的狀況下，直接看以前的 uuid 是多少
            guard let uuid = UUID(uuidString: playlistUUIDString) else {
                fatalError("Failed to create UUID from existing UUID string: \(playlistUUIDString)")
            }
            
            playlistUUID = uuid
        } else {
            
            //這個選擇分支，是在沒開過 playlist 的狀況下，直接開一個新的
            playlistUUID = UUID()
            
            playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: "Test Playlist")
            
            playlistCreationMetadata.descriptionText = "This playlist was created using \(Bundle.main.infoDictionary!["CFBundleName"]!) to demonstrate how to use the Apple Music APIs"
            
            userDefaults.setValue(playlistUUID.uuidString, forKey: MediaLibraryManager.playlistUUIDKey)
            userDefaults.synchronize()
        }
        
        //要求一個新的或已經存在的 playlist (在 device 上)
        MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) {
            (playlist, error) in
            guard error == nil else {
                fatalError("An error occurred while retrieving/creating playlist: \(error!.localizedDescription)")
                
            }
            
            self.mediaPlaylist = playlist
            
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
        }
        
    }
    
    func addItem(with identifier: String) {
        
        guard let mediaPlaylist = mediaPlaylist else {
            fatalError("Playlist has not been created")
        }
        
        mediaPlaylist.addItem(withProductID: identifier, completionHandler: { (error) in
            guard error == nil else {
                fatalError("An error occurred while adding an item to the playlist: \(error!.localizedDescription)")
            }
            
            NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
            
        })
    }
    
    func handleAuthorizationManagerAuthorizationDidUpdateNotification() {
        
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
    }
    
    func handleMediaLibraryDidChangeNotification() {
        
        if MPMediaLibrary.authorizationStatus() == .authorized {
            createPlaylistIfNeeded()
        }
        
        NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
    }
}
