# VideoFeed
This is an iOS app that presents a TikTok-style vertical video feed from a dataset of 200 videos, and includes a Profile screen that summarises the user’s content.

Core Functionality
Fetches a video object from the pexels API endpoint.
Parses the JSON response using Codable.
Displays the videos in a full screen, vertically scrolling collection view with a clean, user-friendly UI.
Autoplays the currently visible video.
Allows user swipe up/down to navigate between videos.
Pauses/stops playing when the user leaves a video (scrolls away) 
Navigates to a profile view when a username is tapped, showing additional information about the user and random videos.
The app also presents a tab viewcontroller that allows navigation to the profile view directly
Unit tests to validate the app’s functionalities.

Bonus Functionality
Pagination: Dynamically loads more items as the user scrolls to the bottom of the collection view.
offline data: Implements local data via a json file to support offline usage. Previously local data is displayed if the app is launched without an internet connection.
Screenshots 

dashboard

details

Tech Stack
Programming Language: Swift
Frameworks: UIKit, Foundation
Networking: URLSession
Data Parsing: Codable
UI Design: Based on the * No Figma design was provided...just freestyle*
Supported iOS Version: iOS 13 and above
Error Handling
Displays an alert with a meaningful error message if the API request fails or if there’s a connectivity issue.
Provides retry options for failed requests.
How to Run the Project
Clone the repository or download the ZIP file.
Open the .xcodeproj file in Xcode.
Ensure your environment is set up with the latest version of Xcode.
Build and run the app on a simulator or physical device.


Future Improvements
Extend caching to allow data expiration and refresh automatically.
