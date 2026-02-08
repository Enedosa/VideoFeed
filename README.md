
# 🎬 VideoPlayer (iOS • UIKit • AVPlayer)

This is a high-performance, TikTok-like vertical video feed built using **UIKit** and **AVPlayer**.  
Supports autoplay, smooth paging, graceful error handling, and local state management.

---

## 📱 Preview
<img width="150" height="400" alt="Screenshot 2026-02-08 at 6 38 32 PM" src="https://github.com/user-attachments/assets/e5a56592-6498-4526-a046-bd949480a6bc" />

### Feed autoplay & swipe
![Feed Demo](assets/FeedAndProfile.gif)

![FeedAndProfile](https://github.com/user-attachments/assets/ea3b66e4-4e0a-424c-8f28-73bc7a16dab9)


### Error & retry state
![Error State](assets/RetryFeature.gif)

![RetryFeature](https://github.com/user-attachments/assets/408008b9-0545-40a5-807e-74af34e68171)


> 📌 All assets live in the `/assets` folder.

---

## ✨ Features
### Core Functionality
- Fetches a video object from the pexels API endpoint.
- Parses the JSON response using Codable.
- Displays the videos in a full screen, vertically scrolling collection view with a clean, user-friendly UI.
- Autoplays the currently visible video.
- Allows user swipe up/down to navigate between videos.
- Pauses/stops playing when the user leaves a video (scrolls away) 
- Navigates to a profile view when a username is tapped, showing additional information about the user and random videos.
- The app also presents a tab viewcontroller that allows navigation to the profile view directly
- Unit tests to validate the app’s functionalities.

### Feed Behavior
- Full-screen vertical feed (1 video per page)
- Swipe up / down navigation
- Autoplay **only** the visible video
- Pause & release when scrolled away
- Smooth paging with `UICollectionView`

### Loading & Error States
- Loading indicator while buffering
- Error overlay if playback fails
- Retry button (re-creates the player cleanly)

### Performance
- Only visible cells play video
- Players are released in `prepareForReuse`
- No preloading of hundreds of videos
- Memory-safe scrolling

### Tech Stack
- Programming Language: Swift
- Frameworks: UIKit, Foundation, AVPlayer
- Networking: URLSession
- Data Parsing: Codable

---

## 🧠 Architecture
- MVVM

## Bonus Functionality
- Pagination: Dynamically loads more items as the user scrolls to the bottom of the collection view.
- offline data: Implements local data via a json file to support offline usage. Previously local data is displayed if the app is launched without an internet connection.

## How to Run the Project
- Clone the repository or download the ZIP file.
- Open the .xcodeproj file in Xcode.
- Ensure your environment is set up with the latest version of Xcode.
- Build and run the app on a simulator or physical device.


## Future Improvements
- Extend caching to allow data expiration and refresh automatically.

