# Earbuds Testing

## Overview

This branch focuses on testing the functionality of the karaoke app to ensure that it can **play music** and **record voice** using Bluetooth and earbuds. The app allows users to sing along with background music, recording their voice via a Bluetooth headset while playing music through the earbuds.

## Features

- **Bluetooth Recording**: The app records the user's voice via a Bluetooth headset.
- **Music Playback**: Plays background music while recording.
- **Earbuds Support**: Testing playback and recording using Bluetooth earbuds.
- **Simultaneous Playback and Recording**: Ensures that both functionalities work seamlessly together.

## Testing Instructions

1. **Pair Bluetooth Device**:
    - Connect your Bluetooth headset or earbuds to your device.

2. **Play Background Music**:
    - Start the app and play any track from the karaoke library.
    - Ensure that the music is playing through the paired Bluetooth earbuds.

3. **Start Voice Recording**:
    - Tap the record button and start singing along with the music.
    - Confirm that the app is recording your voice through the Bluetooth headset while the music continues to play.

4. **Review Recording**:
    - After recording, playback the saved track and check the following:
        - The background music was properly recorded.
        - The user's voice was captured through the Bluetooth device.

## Known Issues

- **Bluetooth Latency**: Minor delays may be observed between voice recording and music playback.
- **Device Compatibility**: The functionality may vary depending on the brand/model of Bluetooth earbuds/headset used.

## How to Contribute

1. Clone the repository and switch to the `earbuds` branch:
   ```bash
   git clone <repository-url>
   git checkout earbuds
