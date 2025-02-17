# Backup Camera

## Overview

The Backup Camera is an iOS app that uses the camera and LiDAR sensors to detect obstacles while reversing. The app provides real-time distance measurements and alerts the user with beeps and visual cues when an object is detected within a threshold distance.

## Features

- Real-time distance measurement using camera and LiDAR data.
- Audio and visual alerts when objects are detected within a certain distance.
- User-friendly interface displaying distance and providing feedback.
- Progress bar showing the proximity to objects.

## Demo Video

https://github.com/user-attachments/assets/6f5d3a47-f5b3-46b5-ac6c-05c858a422ff

## Technologies Used

- **Swift** for iOS development
- **ARKit** for depth sensing and LiDAR integration
- **AVFoundation** for audio feedback (beeps and vibrations)
- **UIKit** for UI elements like labels and progress bars
- **CoreLocation** for potential future GPS integration

## Getting Started

### Prerequisites

- Xcode installed (latest version recommended)
- A physical iOS device (with LiDAR support) for testing
- Basic understanding of Swift and iOS app development

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/altaiiir/BackupCamera.git
   cd BackupCamera

2. Open the project in Xcode:
   ```bash
   open BackupCamera.xcodeproj
3. Setup your iOS device for testing:
   - Connect your iOS device to your Mac via USB or use wireless debugging in Xcode.
   - Select your device in the Xcode toolbar and click the Run button.

## Notes
- The app uses ARKit and LiDAR, so it will only work on devices that support these technologies (e.g., iPhone 12 and later).
- Make sure to enable camera and LiDAR usage permissions in the Info.plist file of the project.

## Future Enhancements
- Add ability to pause beeping when the car is stationary.
- Add GPS location integration for tracking where the user parks
- Implement customizable distance thresholds for the alert system
- Improve the beeping system to handle rapid changes in distance
- Improve the UI design for better user experience during parking
- Implement this into the actual vehicle by utilizing the OBDII port to detect gear selection

Let me know if you'd like to add or modify anything in this README! Feel free to contribute, this is my first iOS app and I'm definetly open to feedback.
