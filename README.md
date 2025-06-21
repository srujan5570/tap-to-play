# Client ID App

A Flutter iOS application that provides a clean and modern interface for entering client identification numbers.

## Features

- **Modern UI Design**: Clean, Material Design 3 interface with gradient background
- **Client ID Input**: Validated text input field for client identification
- **Form Validation**: Ensures client ID is at least 3 characters long
- **Loading States**: Shows loading indicator during submission
- **Success Feedback**: Displays confirmation message after successful submission
- **Responsive Design**: Works on all iOS device sizes

## Screenshots

The app features:
- Beautiful gradient background
- Circular app icon with shadow
- Clean input field with validation
- Modern submit button with loading state
- Helpful user guidance text

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Xcode (for iOS development)
- iOS Simulator or physical iOS device

### Installation

1. **Clone or navigate to the project directory:**
   ```bash
   cd my_time
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app on iOS:**
   ```bash
   flutter run
   ```

   Or specifically for iOS:
   ```bash
   flutter run -d ios
   ```

### Building for iOS

To build the app for iOS distribution:

1. **Build the app:**
   ```bash
   flutter build ios
   ```

2. **Open in Xcode for further configuration:**
   ```bash
   open ios/Runner.xcworkspace
   ```

## App Structure

- `lib/main.dart` - Main application entry point and UI
- `ios/` - iOS-specific configuration files
- `android/` - Android-specific configuration files

## Usage

1. Launch the app
2. Enter your client ID in the input field
3. Tap the "Submit" button
4. Wait for the confirmation message

## Customization

You can easily customize the app by modifying:

- **Colors**: Update the `seedColor` in `ThemeData`
- **Validation**: Modify the validation logic in the `validator` function
- **UI Elements**: Adjust styling in the `build` method
- **App Name**: Change the title in `MaterialApp` and `Info.plist`

## Dependencies

This app uses only Flutter's built-in packages:
- `flutter/material.dart` - Core Flutter UI components

## Support

For issues or questions, please contact the development team.

## License

This project is created for demonstration purposes.
