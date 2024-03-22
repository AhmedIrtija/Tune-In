# Tune-In

@ashanisinha
@ahmedirtija
@bertjosephp
@nivrithikrishnan
@kav3569

# About TuneIn 
---

TuneIn is a platform that allows users to view what music people around them are listening to in real-time using data sourced from Spotify. The purpose of the app is to help satisfy user curiosity, foster a sense of community, and encourage further music discovery. 

# Technical Stack
---
## Frameworks

| |  |
| --- | --- |
| Programming Language | Swift |
| Frameworks/APIs | SwiftUI, SpotifyWebAPI, GoogleMapsAPI, Firebase|
| Prototyping | Figma |

# Features
- View currently playing track, artist, and album, and profile of users near you
- Control radius to display more or less users 
- 'Vibe Check' feature to analyze user's current mood
- Customize user profile including adding a profile picture, display name, and bio

# User Flow Walkthrough
## SignInView, SpotifyLoginView, LoadingView
1. Create an account on TuneIn. New users can enter any desired email and passowrd and a new account will be automatically created. Returning users can Log In using their previous credentials. 
2. Connect using spotify. TuneIn will automatically authenticate your account, users should ensure they are logged into their Spotify accounts. 
3. Wait for your map view to load. This should take 2-5 seconds. 
4. You're Tuned In! 

## MapView
1. From the map view, there are several buttons to adjust the visual layout. On the bottom left, includes a map icon to change the current visual map and radius selector. On the bottom right, click the arrow to center your current view, '3D' to change the dimension of the map between 2D to 3D, and the compass. 
2. Click on surrounding users profile icons to view their profile. A pop-up will display from the bottom of the screen with the desired info. 
2. Click the play button next to a user's profile 'to play a snippet of the selected user's track. This will also trigger a pop-up at the top of the user's screen displaying the track info and allowing users to play and pause the current media.
3. Click the dancing icon on the left header to view you're current vibe!
4. Click the settings icon on the right header to view and edit current user's settings
5. Click 'Explore Music' to transition to the List View

## ListView
The list view will include a scrollable menu listing all surrounding user's currently playing tracks 

## ProfileView
The profile view will include current information about the user profile including their current profile picture, display name, pronouns, location, and bio 

## SettingsView
The settings view allows users to edit their current profile settings. This includes 
1. ProfilePicker to edit user's profile picture
2. Display name
3. Pronouns (from a selected menu)
4. Bio

When all desired changes are made, user's can click 'Save Changes' to commit new edits. There is also a button to Log Out. 
