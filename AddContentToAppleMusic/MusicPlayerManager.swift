//
//  MusicPlayerManager.swift
//  AddContentToAppleMusic
//
//  Created by moon on 2017/7/27.
//  Copyright © 2017年 Marvin Lin. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

@objc
class MusicPlayerManager: NSObject {
    
    static let didUpdateState = NSNotification.Name("didUpdateState")
    
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    
    override init() {
        super.init()
        
        musicPlayerController().beginGeneratingPlaybackNotifications()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerNowPlayingItemDidChange),
                                       name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                       object: musicPlayerController)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: musicPlayerController)
    }
    
    deinit {
        
        /*
         It is important to call `MPMusicPlayerController.endGeneratingPlaybackNotifications()` so that
         playback notifications are no longer generated.
         */
        musicPlayerController().endGeneratingPlaybackNotifications()
        
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self,
                                          name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                          object: musicPlayerController)
        notificationCenter.removeObserver(self,
                                          name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                          object: musicPlayerController)

    }
    
    func beginPlayback(itemCollection: MPMediaItemCollection) {
        musicPlayerController().setQueue(with: itemCollection)
        
        musicPlayerController().play()
    }
    
    func beginPlayback(itemID: String) {
        
        //這個在 Swift4.0 之後要改成下面這一行
        musicPlayerController().setQueueWithStoreIDs([itemID])
//        musicPlayerController().setQueue(with: [itemID])
        
        musicPlayerController().play()
    }
    
    func togglePlayPause() {
        if musicPlayerController().playbackState == .playing {
            musicPlayerController().pause()
        } else {
            musicPlayerController().play()
        }
    }

    func skipToNextItem() {
        musicPlayerController().skipToNextItem()
    }
    
    func skipBackToBeginningOrPreviousItem() {
        
        //看起來是加強使用者體驗的，如果是在5秒前再按一次這個功能，跳到前一首
        if musicPlayerController().currentPlaybackTime < 5 {
            // If the currently playing `MPMediaItem` is less than 5 seconds into playback then skip to the previous item.
            musicPlayerController().skipToPreviousItem()
        } else {
            // Otherwise skip back to the beginning of the currently playing `MPMediaItem`.
            musicPlayerController().skipToBeginning()
        }
    }
    
    func handleMusicPlayerControllerNowPlayingItemDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
    
    
    func handleMusicPlayerControllerPlaybackStateDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
}

