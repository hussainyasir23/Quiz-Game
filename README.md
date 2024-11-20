# iOS Quiz Game

A modern, interactive quiz application built with Swift and UIKit, leveraging the MVVM architecture. This app fetches trivia questions from the Open Trivia Database API and presents them in an engaging, user-friendly interface.

[![Created by Yasir](https://img.shields.io/badge/Created_by-Yasir-blue?style=for-the-badge)](https://hussainyasir23.github.io/hussainyasir23/)

## Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [API Integration](#api-integration)
- [Future Improvements](#future-improvements)
- [Project Status](#project-status)
- [About the Developer](#about-the-developer)

## Features

- Dynamic question fetching from Open Trivia Database API
- Customizable quiz parameters:
  - Category selection
  - Difficulty level
  - Question type
  - Number of questions
- Real-time score tracking
- Timer for each question
- Interactive UI with animations and sound effects
- High score tracking using UserDefaults
- Detailed results screen after each game

## Technologies Used

- Swift 5
- UIKit
- Combine for reactive programming
- MVVM Architecture
- UserDefaults for local data persistence

## Getting Started

To run this project locally, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/hussainyasir23/Quiz-Game.git
   ```
2. Open the project in Xcode:
   ```
   cd Quiz Game
   open Quiz Game.xcodeproj
   ```
3. Build and run the project in Xcode using a simulator or connected device.

## Architecture

This project uses the MVVM (Model-View-ViewModel) architecture:

- **Models**: Represent the data structures used in the app.
- **Views**: UIViewControllers and custom UIViews that display the UI.
- **ViewModels**: Handle the business logic and data preparation for the views.

The app also uses Combine for reactive programming, enabling smooth data flow between components.

## API Integration

The app integrates with the Open Trivia Database API to fetch quiz questions. The `QuizService` class handles API requests and response parsing.  
For more details, visit the [Open Trivia Database API documentation](https://opentdb.com/api_config.php).

## Future Improvements

- Implement user accounts and online leaderboards
- Introduce difficulty progression as the player advances
- Implement local caching of questions for offline play
- Add accessibility features for a wider range of users

## Project Status

This project is a personal/learning project and is not currently licensed for distribution or use. The project creator reserves all rights. If you're interested in using or contributing to this project, please reach out to discuss possibilities.

Please note that while this project uses the Open Trivia Database API, it is not affiliated with or endorsed by the API providers. Make sure to comply with their terms of service when using the API.

## About the Developer

This project is created and maintained by [Yasir](https://hussainyasir23.github.io/hussainyasir23/).

Feel free to check out my other projects and get in touch!

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/hussainyasir23)
[![Email](https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:hussainyasir23@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/hussainyasir23/)
