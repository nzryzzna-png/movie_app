# Movie App

A Flutter mobile movie application developed as an ITI Flutter Graduation Project.

## Project Overview

Movie App is a mobile application that uses the TMDB API to retrieve real movie information and Firebase Authentication to manage users.

The application allows users to browse movies, search for movies, view movie details, and manage personal movie lists.

## Features

- User Registration
- User Login
- User Logout
- Authentication State Handling
- Popular Movies
- Now Playing Movies
- Top Rated Movies
- Upcoming Movies
- Trending Movies
- Movie Search
- Movie Details
- Favorites List
- Watched List
- Watching List
- Want to Watch List
- Persistent movie lists using Cloud Firestore
- Loading, Empty, and Error Handling

## Technologies

- Flutter
- Dart
- Provider
- Firebase Authentication
- Cloud Firestore
- TMDB API
- HTTP

## Architecture

The project follows the MVVM architecture.

### Model
Contains movie data models used to convert API responses into Dart objects.

### View
Contains the Flutter screens and UI.

### ViewModel / Provider
Manages application state and connects the UI with the services.

### Services
Handles external operations such as TMDB API requests, Firebase Authentication, and Firestore database operations.

## State Management

Provider is used for state management.

It manages:

- Authentication state
- Movie data
- Search results
- Loading states
- Error states
- Movie lists

## TMDB API

The application uses TMDB as the primary movie-data service.

Movie data includes:

- Popular Movies
- Now Playing
- Top Rated
- Upcoming
- Trending
- Movie Details
- Search Results

API requests are separated from the UI through the TMDB service.

## Firebase Authentication

Firebase Authentication is used for:

- Registration
- Login
- Logout
- Authentication state handling
- Authentication error handling
- Input validation

Email and password authentication are used.

## Database

Cloud Firestore is used to store the user's movie lists.

Each authenticated user has their own movie data.

The application supports:

- Favorites
- Watched
- Watching
- Want to Watch

Movies can be added to and removed from every list, and the data persists after restarting the application.

## Project Structure

```text
lib/
├── models/
│   └── movie_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   └── movie_provider.dart
│
├── services/
│   ├── auth_service.dart
│   ├── tmdb_service.dart
│   └── firestore_service.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── movie_details_screen.dart
│   ├── search_screen.dart
│   ├── movie_list_screen.dart
│   ├── favorites_screen.dart
│   ├── watched_screen.dart
│   ├── watching_screen.dart
│   ├── want_to_watch_screen.dart
│   └── profile_screen.dart
│
├── firebase_options.dart
└── main.dart