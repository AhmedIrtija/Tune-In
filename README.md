# Tune-In

@ashanisinha
@ahmedirtija
@bertjosephp
@nivrithikrishnan
@kav3569

# About TuneIn 
---

TuneIn is a platform that allows users to view what music people around them are listening to in real-time using data sourced from Spotify. The purpose of the app is to help satisfy user curiosity, foster a sense of community, and encourage further music discovery. 

# Installation
1. Clone this repository and place it inside a directory.
2. Download ios-auth and place it inside the same directory: https://github.com/spotify/ios-auth
3. Download PopupView package and place it inside the same directory: https://github.com/exyte/PopupView

# How To Run Without Spotify Premium
---

To use Tune In, you need a Spotify premium account to see live changes on your phone. This can only be done on hardware not simulator.

However you can see other people's music through the simulator. You can also create an account and change your profile etc. through the simulator. The only missing functionality here is sharing your music to others on the map.
To do this, you must bypass the Spotify Authentication process.

1. Go to SpotifyLoginView and replace 
viewModel.startAuthorizationCodeProcess()
with 
rootViewType = .mapView

This allows the user to make an account and go through the firebase authentication process, without hacing to authenticate through spotify.

2. Change the simulator's location by going to Features > Location > Custom Location
Latitude: 38.54154423305109, 
Longitude: -121.75219109590482

Use this one:
User: tunein189@gmail.com
Password: Time2TuneIn!

3. Go to the RootView and change the case to show the .MapView first. The Spotify premium account to use on your phone has these credentials. Please do not use your own as it must be registered as a developer test user.
Use Xcode 15.2

If dependencies are not running correctly, install 
PopUpView : https://github.com/exyte/PopupView.git
use this bundle ID to build : (insert ID)


# Technical Stack
---
## Frameworks

| |  |
| --- | --- |
| Programming Language | Swift |
| Frameworks/APIs | SwiftUI, SpotifyWebAPI, Firebase|
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
1. From the map view, there are several buttons in white to adjust the visual layout. On the bottom left, includes a map icon to change the current map style and radius selector. On the bottom right, click the arrow to center your current view, '3D' to change the dimension of the map between 2D to 3D, and the compass. 
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
