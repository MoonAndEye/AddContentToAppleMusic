# Adding Content to Apple Music

這一個檔案是為拆解 Apple 放出的 sample code 而開的

## Overview

這一份 sample code 主要內含 MediaPlayer 和 StoreKit 的框架，同時，他也試範了怎麼和 Apple Music Web Service 做互動:

* Request acces
* 如果使用者已經登入 iTune 的話，則會跳出 Apple Music subscriber setup flow
* 從 Apple music catalog 中找出特定歌曲或是特定歌手
* 在 app 裡面開一個 MPMediaPlaylist，或者開在使用者的 iCloud music 音樂庫上，當然，新增歌曲也是可以的。
* 播放 Apple Music 裡面的歌或是 MPMediaPlaylist，或是這個 app 產生的 playlist。

## Getting Started

你需要有 Developer token 才可以繼續存取資料。

當你已經有 developer token 之後，你需要 update `AppleMusicManager.fetchDeveloperToken()` 才行

這個 func 做在 AppleMusicManager 裡面

就是把這一段

func fetchDeveloperToken() -> String? {

// MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD
let developerAuthenticationToken: String? = nil
return developerAuthenticationToken
}

`注意!`
不要把 developer token 寫在你的裝置裡面，這樣你可避免換 token 的時候，你需要 update 你的 app。

## Request Authorization

在開始串 API 前，你的 app 需要先 request 權限，才能和 media library 還有 Apple Music.

有兩種不同的權限，你可以依照需求 request，不用兩個都做。

### Media Library Authorization

如果你需要使用使用者本機上的 media library ，那你需要要求 MPMediaLibray 的權限。
[`MPMediaLibrary`](https://developer.apple.com/documentation/mediaplayer/mpmedialibrary)

而他的權限請求，如下
[`MPMediaLibraryAuthorizationStatus`](https://developer.apple.com/documentation/mediaplayer/mpmedialibraryauthorizationstatus)

, you can call 
[`MPMediaLibrary.authorizationStatus()`](https://developer.apple.com/documentation/mediaplayer/mpmedialibrary/1621282-authorizationstatus)


swift
`guard MPMediaLibrary.authorizationStatus() == .notDetermined else { return }`



如果你的權限是 `.notDetermined` 那你要用下列的方式去拿請求




[`MPMediaLibrary.requestAuthorization(_:)`](https://developer.apple.com/documentation/mediaplayer/mpmedialibrary/1621276-requestauthorization).


MPMediaLibrary.requestAuthorization { (_) in
NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
}


### Cloud Service Authorization


如果你的 app 想要在使用者的 iCloud Music Library 播放 Apple Music 上的歌曲，那你需要要求的權限，就是 
`SKCloudServiceController` APIs.

[`SKCloudServiceAuthorizationStatus`](https://developer.apple.com/documentation/storekit/skcloudserviceauthorizationstatus), you can call [`SKCloudServiceController.authorizationStatus()`](https://developer.apple.com/documentation/storekit/skcloudservicecontroller/1620631-authorizationstatus).


swift
`guard SKCloudServiceController.authorizationStatus() == .notDetermined else { return }`


如果你的權限是 `.notDetermined` 那你可以要求 request。

[`SKCloudServiceController.requestAuthorization(_:)`](https://developer.apple.com/documentation/storekit/skcloudservicecontroller/1620609-requestauthorization)

SKCloudServiceController.requestAuthorization { [weak self] (authorizationStatus) in
switch authorizationStatus {
case .authorized:
self?.requestCloudServiceCapabilities()
self?.requestUserToken()
default:
break
}

NotificationCenter.default.post(name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
}

當你的 app 得到了 `.authorized` 狀態，那你可以 query 更多的資訊。

像是
[`SKCloudServiceCapability`](https://developer.apple.com/documentation/storekit/skcloudservicecapability)

[`requestCapabilities(completionHandler:)`](https://developer.apple.com/documentation/storekit/skcloudservicecontroller/1620610-requestcapabilities)

[`SKCloudServiceController`](https://developer.apple.com/documentation/storekit/skcloudservicecontroller)


let controller = SKCloudServiceController()
controller.requestCapabilities(completionHandler: { (cloudServiceCapability, error) in
guard error == nil else {
// Handle Error accordingly, see SKError.h for error codes.
}

if cloudServiceCapabilities.contains(.addToCloudMusicLibrary) {
// The application can add items to the iCloud Music Library.
}

if cloudServiceCapabilities.contains(.musicCatalogPlayback) {
// The application can playback items from the Apple Music catalog.
}

if cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) {
// The iTunes Store account is currently elgible for and Apple Music Subscription trial.
}
})


## Requesting a Music User Token

這個要 iOS 11 才可以用，先跳過



## 在 Media playlist 裡面創建 items

當你的 app 已經有 iCloud Music 的權限時，條就可以開始屬用 MPMediaLibrary API 去創造或是拿 MPMediaPlaylist 的 API

[`MPMediaPlaylist`](https://developer.apple.com/documentation/mediaplayer/mpmediaplaylist)

如下，這樣的
[`MPMediaLibrary.getPlaylist(with:creationMetadata:completionHandler:)`](https://developer.apple.com/documentation/mediaplayer/mpmedialibrary/1621273-getplaylist)

你可以創造一個 UUID() 給新的 playlist，這可以讓你在未來重新播放這些曲目

let playlistUUID = UUID()

// Create an instance of `MPMediaPlaylistCreationMetadata`, this represents the metadata to associate with the new playlist.
var playlistCreationMetadata = MPMediaPlaylistCreationMetadata(name: "My Playlist")
playlistCreationMetadata.descriptionText = "This playlist contains awesome items."

// Request the new or existing playlist from the device.
MPMediaLibrary.default().getPlaylist(with: playlistUUID, creationMetadata: playlistCreationMetadata) { (playlist, error) in
guard error == nil else {
// Handle Error accordingly, see MPError.h for error codes.
}

self.mediaPlaylist = playlist
}



當你產生了 MPMediaPlaylist (https://developer.apple.com/documentation/mediaplayer/mpmediaplaylist) 之後，你就可以把 item 加進去。

[`MPMediaPlaylist.addItem(withProductID:completionHandler:)`](https://developer.apple.com/documentation/mediaplayer/mpmediaplaylist/1618706-additem)

mediaPlaylist.addItem(withProductID: identifier, completionHandler: { (error) in
guard error == nil else {
fatalError("An error occurred while adding an item to the playlist: \(error!.localizedDescription)")
}

NotificationCenter.default.post(name: MediaLibraryManager.libraryDidUpdate, object: nil)
})


## 播放 Apple Music catalog 上面的 items

當你的 app 有權限，而且有 `SKCloudServiceCapability.musicCatalogPlayback` 這個能力之後。你就可以放一首或多首 Apple Music 的歌曲，使用的 api 是
`MPMusicPlayerController` APIs.

如果想播特定歌曲，而且你知道那一首歌的 ID，你可以這樣用
[`MPMusicPlayerController.setQueueWithStoreIDs(_:)`](https://developer.apple.com/documentation/mediaplayer/mpmusicplayercontroller/1624253-setqueuewithstoreids)

-----
musicPlayerController.setQueue(with: [itemID])

musicPlayerController.play()
-----

如果是某個 MPMediaPlaylist 你想播放，你可以用下面這樣個 api

[`MPMediaPlaylist`](https://developer.apple.com/documentation/mediaplayer/mpmediaplaylist) 

[`MPMusicPlayerController.setQueue(with:)`](https://developer.apple.com/documentation/mediaplayer/mpmusicplayercontroller/1624171-setqueue)

-----
musicPlayerController.setQueue(with: itemCollection)

musicPlayerController.play()

-----











